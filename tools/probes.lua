-- probes.lua -- five one-shot probes that came out of reading the manuals.
--
--   $0400 (CP)  device status list, four bytes per port          (osref 7.1.5)
--   02E8  (DU)  OSFUNC1: bit7 chargen in software, bit6 1 = KBU 4143  (osref 10.1.2)
--   02C7  (DU)  MAXRAM: how much RWM the operating system found (osref 9.6.2)
--   F7D2  (DU)  DIA PIA B: does it write 0x11 or 0x41?  The operating system
--               reference prints 41, which would decode as 44 lines with video
--               inhibited; the machine actually writes 11.
--   FFE7  (DU)  PROMID, the unit type identifier                 (osref 9.6.1)
--
-- Usage: -autoboot_script probes.lua       AT=<frame> when to report (50 Hz)
local AT = tonumber(os.getenv("AT") or "3000")

local du = manager.machine.devices[":ducpu"]
local cp = manager.machine.devices[":cpcpu"]
local dmem = du and du.spaces["program"]
local cmem = cp and cp.spaces["program"]

diab = {}
if dmem then
	DIATAP = dmem:install_write_tap(0xf7d0, 0xf7d3, "diapia",
		function(offset, data, mask)
			if (offset & 3) == 2 then
				diab[#diab + 1] = { t = manager.machine.time:as_double(), d = data }
			end
			return data
		end)
end

local function bits(v)
	local s = ""
	for i = 7, 0, -1 do s = s .. (((v >> i) & 1) == 1 and "1" or "0") end
	return s
end

frames = 0
PSUB = emu.add_machine_frame_notifier(function()
	frames = frames + 1
	if frames ~= AT then return end
	print(string.format("\n===== PROBES  t=%.2f =====", manager.machine.time:as_double()))

	if dmem then
		local promid = dmem:read_u8(0xffe7)
		print(string.format("FFE7 PROMID  = %02X  (%s)", promid,
			({[0xff]="Single DTC + DTC-A, FD 4120", [0x01]="Cluster DTC + DTC-A",
			  [0x02]="DU 4111", [0x03]="DU 4112", [0x05]="DU 4113",
			  [0x06]="FD 4122"})[promid] or "?"))
		print(string.format("FFE8 FUNC    = %02X", dmem:read_u8(0xffe8)))

		local osf = dmem:read_u8(0x02e8)
		print(string.format("02E8 OSFUNC1 = %02X  %s  -> chargen %s, keyboard %s",
			osf, bits(osf),
			((osf & 0x80) ~= 0) and "IN SOFTWARE" or "in PROM",
			((osf & 0x40) ~= 0) and "KBU 4143" or "KBU 4140-XXX"))

		local mr = (dmem:read_u8(0x02c7) << 8) | dmem:read_u8(0x02c8)
		local tab = {[0x7ffc]="32 K, no MRW", [0xbffc]="32K + 16K MRW",
					 [0xcffc]="32K + 20K", [0xdffc]="32K + 24K",
					 [0xeffc]="32K + 28K", [0xf67c]="32K + 30K"}
		print(string.format("02C7 MAXRAM  = %04X  (%s)", mr, tab[mr] or "?"))
	end

	if cmem then
		print("$0400 device status list in the CP, four bytes per port:")
		print("  bit7 not connected on two-wire   bit6 device down (slow poll)")
		print("  bit5 IPL request   bit4 host reservation   bit3 session table full")
		print("  bit2 master lock   bit1 secondary host     bit0 primary host")
		for port = 0, 11 do
			local b = {}
			for i = 0, 3 do b[i] = cmem:read_u8(0x0400 + port * 4 + i) end
			if b[0] ~= 0 or b[1] ~= 0 or b[2] ~= 0 or b[3] ~= 0 then
				print(string.format("  port %2d   DU=%02X PU=%02X FD=%02X PCU=%02X   %s",
					port, b[0], b[1], b[2], b[3], bits(b[0])))
			end
		end
	end

	print("\nF7D2 writes to the display adapter PIA, register B:")
	if #diab == 0 then
		print("  none yet")
	else
		local seen = {}
		for _, w in ipairs(diab) do
			if not seen[w.d] then
				seen[w.d] = true
				local sw = ({[0]="16 sweeps (25 lines)", [1]="12 (33 lines)",
							 [2]="9 (44 lines)", [3]="22 (fewer than 25 lines)"})[(w.d >> 5) & 3]
				local pm = ({[0]="mode 3", [1]="mode 2", [2]="mode 1", [3]="mode 0"})[(w.d >> 1) & 3]
				print(string.format("  t=%8.4f  %02X  %s  cell=%s, video=%s, FAC=%s, presentation=%s, stop at line end=%s",
					w.t, w.d, bits(w.d), sw,
					((w.d & 0x10) ~= 0) and "CONNECTED" or "BLOCKED",
					((w.d & 0x08) ~= 0) and "UTS" or "IBM", pm,
					((w.d & 0x01) ~= 0) and "yes" or "no"))
			end
		end
	end
	io.flush()
end)
print("probes.lua: will report at frame " .. AT)

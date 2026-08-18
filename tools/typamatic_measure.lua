-- typamatic_measure.lua -- what the keyboard firmware ACTUALLY does.
--
-- The keyboard in this driver is not a model of ours: it runs the REAL KBU
-- firmware (kbc_e34066_0000_ic3.bin) on a genuine M6802.  So the 0.5 s
-- threshold and the repetition rate are decided by that firmware, not by the
-- driver.  Before "fixing" anything, measure what the ROM does.
--
-- The diskette asks for 12.5 Hz (EMLIB1/EADEMPA1 byte A = 01) and the service
-- manual gives the threshold as "more than 0.5 seconds".
--
-- This script holds a key down and timestamps every byte the keyboard hands to
-- the display (a read of the keyboard ACIA data register).
dofile("./run/keymap.lua")

local ports = manager.machine.ioport.ports
local KEY   = tonumber(os.getenv("KEY") or "1")
local AT    = tonumber(os.getenv("AT") or "3000")   -- frame at which the key goes down (50 Hz)
local HOLD  = tonumber(os.getenv("HOLD") or "250")  -- how many frames it is held (5 s)

local function field_of(tag, mask)
	local p = ports[":du_kbd:" .. tag]
	if p == nil then return nil end
	for _, f in pairs(p.fields) do
		if f.mask == mask then return f end
	end
	return nil
end

-- Tap on the display keyboard ACIA data register (F7C1).
-- Each non-zero read is a byte the keyboard has handed over.
local du    = manager.machine.devices[":ducpu"]
local dmem  = du.spaces["program"]
local marks = {}
local pressed_at = nil

TAP = dmem:install_read_tap(0xf7c1, 0xf7c1, "kbdata",
	function(offset, data, mask)
		local t = manager.machine.time:as_double()
		marks[#marks + 1] = { t = t, d = data }
		return data
	end)

frames = 0
SUB = emu.add_machine_frame_notifier(function()
	frames = frames + 1
	local e = keymap[KEY]
	if e == nil then return end
	if frames == AT then
		local f = field_of(e[1], e[2])
		if f then f:set_value(1) end
		pressed_at = manager.machine.time:as_double()
		print(string.format("--- HELD DOWN keynum %d (%s %04X %s) desde t=%.4f",
			KEY, e[1], e[2], e[3], pressed_at))
	elseif frames == AT + HOLD then
		local f = field_of(e[1], e[2])
		if f then f:set_value(0) end
		print(string.format("--- RELEASED at t=%.4f", manager.machine.time:as_double()))
		-- informe
		print("")
		print("=== bytes delivered by the keyboard to the display ===")
		local prev = nil
		local n = 0
		for _, m in ipairs(marks) do
			if m.t >= pressed_at - 0.05 and m.d ~= 0 then
				n = n + 1
				local dt = prev and (m.t - prev) or 0
				local since = m.t - pressed_at
				print(string.format("%3d  t=%.4f  +%.4f since key down  dt=%.4f  dato=%02X  rep=%s",
					n, m.t, since, dt, m.d, (m.d & 0x80) ~= 0 and "SI" or "no"))
				prev = m.t
				if n > 120 then print("   (truncated at 120)"); break end
			end
		end
		if n == 0 then print("   no bytes delivered") end
	end
end)

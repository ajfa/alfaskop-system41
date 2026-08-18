-- lamps.lua -- the boot semaphore the firmware already lights for you.
--
-- The maintenance manual documents what the front panel lamps mean, and they
-- are bits the driver already carries on the FDA PIA:
--
--   FD READY   (FDA PIA port A bit 2)
--       steady   -> the disk unit's IPL has completed
--       blinking -> THE COMMUNICATION PROCESSOR IS NOT POLLING THE DISK UNIT
--   FD ERROR 1/2/3  (FDA PIA port B bits 2/1/0)
--       fast blink (about 4 Hz) = status of drive 2
--       slow blink (about 1 Hz) = status of drive 1
--       STATUS 2 lit -> disk unit not ready
--
-- This script samples the PIA output registers, measures how fast each lamp is
-- toggling and translates the pattern into that documented meaning.  It does
-- not modify the driver.
--
-- Usage: -autoboot_script lamps.lua      LAMPWIN=<seconds> sets the report window
local fd = manager.machine.devices[":maincpu"]
if fd == nil then
	print("lamps.lua: cannot find :maincpu")
	return
end
local mem = fd.spaces["program"]

local WIN = tonumber(os.getenv("LAMPWIN") or "2.0")

local lamp = {}
local names = { "READY", "ERROR1", "ERROR2", "ERROR3" }
for _, n in ipairs(names) do lamp[n] = { last = nil, edges = {}, lastt = 0 } end

local function sample(n, state, t)
	local L = lamp[n]
	if L.last ~= nil and state ~= L.last then L.edges[#L.edges + 1] = t end
	L.last = state
	L.lastt = t
end

-- writes to the PIA land at F740-F747 (mirror 0x04)
LAMPTAP = mem:install_write_tap(0xf740, 0xf747, "lamps",
	function(offset, data, mask)
		local t = manager.machine.time:as_double()
		local reg = offset & 3
		if reg == 0 then
			sample("READY", (data & 0x04) ~= 0, t)
		elseif reg == 2 then
			sample("ERROR1", (data & 0x04) ~= 0, t)
			sample("ERROR2", (data & 0x02) ~= 0, t)
			sample("ERROR3", (data & 0x01) ~= 0, t)
		end
		return data
	end)

local function hz(edges, from, to)
	local n = 0
	for _, t in ipairs(edges) do if t >= from and t <= to then n = n + 1 end end
	return (n / 2) / (to - from), n   -- two edges make one cycle
end

local last_report = 0
LAMPSUB = emu.add_machine_frame_notifier(function()
	local t = manager.machine.time:as_double()
	if t - last_report < WIN then return end
	local from = last_report
	last_report = t
	local line = string.format("t=%6.2f ", t)
	for _, n in ipairs(names) do
		local L = lamp[n]
		local f, ne = hz(L.edges, from, t)
		local st
		if L.last == nil then st = "?"
		elseif ne == 0 then st = L.last and "STEADY" or "off"
		else st = string.format("%.1f Hz", f) end
		line = line .. string.format("%s=%-8s ", n, st)
	end
	local R = lamp["READY"]
	local _, neR = hz(R.edges, from, t)
	local msg
	if R.last == nil then msg = "(no PIA writes yet)"
	elseif neR == 0 and R.last then msg = "-> DISK UNIT IPL COMPLETE"
	elseif neR == 0 and not R.last then msg = "-> READY off: RWM/PROM test error, or not initialised yet"
	else msg = "-> READY BLINKING: the CP is not polling the disk unit" end
	print(line .. msg)
	io.flush()
end)
print("lamps.lua: disk unit lamp monitor active, window " .. WIN .. " s")

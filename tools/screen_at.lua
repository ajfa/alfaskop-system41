-- screen_at.lua -- print the display's screen at a few points in time and exit.
-- AT_LIST is a comma separated list of seconds, e.g. "40,55,70".
local du    = manager.machine.devices[":ducpu"]
local dmem  = du.spaces["program"]
local list  = {}
for s in (os.getenv("AT_LIST") or "60"):gmatch("[^,]+") do
	list[#list + 1] = math.floor(tonumber(s) * 50)
end
table.sort(list)

local function dump(tag)
	print(string.format("\n===== %s =====", tag))
	for r = 0, 25 do
		local s = ""
		for i = 0, 79 do
			local c = dmem:read_u8(0x7800 + ((r * 80 + i) % 0x800)) & 0x7f
			s = s .. ((c >= 0x20 and c < 0x7f) and string.char(c) or " ")
		end
		s = s:gsub("%s+$", "")
		if s ~= "" then print(string.format("%2d |%s", r, s)) end
	end
	io.flush()
end

local frames, i = 0, 1
SUB = emu.add_machine_frame_notifier(function()
	frames = frames + 1
	if i <= #list and frames >= list[i] then
		dump(string.format("t = %.1f s", frames / 50.0))
		i = i + 1
		if i > #list then manager.machine:exit() end
	end
end)

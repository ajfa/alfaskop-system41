-- shot.lua -- take a snapshot of the display at frame AT and exit.
local AT = tonumber(os.getenv("AT") or "3000")
local AT = tonumber(os.getenv("AT") or "3000")
frames = 0
SHOTSUB = emu.add_machine_frame_notifier(function()
	frames = frames + 1
	if frames == AT then
		for tag, s in pairs(manager.machine.screens) do
			print(string.format("%s -> snapshot (%dx%d, %.4f Hz)",
				tag, s.width, s.height, 1.0 / s.frame_period))
			s:snapshot()
		end
	end
end)

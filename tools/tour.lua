-- tour.lua -- Guided tour of the Ericsson Alfaskop System 41 (1983).
--
-- Runs unattended and narrates on the console while the machine does the work
-- in the window.  ACT=1 boots the original system diskette and shows the
-- terminal emulation; ACT=2 boots a copy whose autologon record points at the
-- console module instead, which brings up the system's own function menu.
local TOUR_DIR = os.getenv("TOUR_DIR") or "."
local ACT = tonumber(os.getenv("ACT") or "1")
dofile(TOUR_DIR .. "/keymap.lua")

local du    = manager.machine.devices[":ducpu"]
local dmem  = du.spaces["program"]

local frames, queue, qi = 0, {}, 1

local function say(...) print(string.format(...)); io.flush() end

local function show_screen(title)
	say("")
	say("    .-- %s", title)
	local n = 0
	for r = 0, 25 do
		local s = ""
		for i = 0, 79 do
			local c = dmem:read_u8(0x7800 + ((r * 80 + i) % 0x800)) & 0x7f
			s = s .. ((c >= 0x20 and c < 0x7f) and string.char(c) or " ")
		end
		s = s:gsub("%s+$", "")
		if s ~= "" then say("    |  %s", s); n = n + 1 end
	end
	if n == 0 then say("    |  (screen is blank)") end
	say("    '%s", string.rep("-", 60))
	say("")
end

local function at(sec, fn) queue[#queue + 1] = { math.floor(sec * 50), fn } end

-- ============================================================== ACT 1
if ACT == 1 then

at(0.1, function()
	say("")
	say("================================================================")
	say("   ERICSSON ALFASKOP SYSTEM 41   --   guided tour, part 1 of 2")
	say("================================================================")
	say("")
	say("  This is not one computer but THREE, each with its own")
	say("  Motorola 6800 and its own firmware:")
	say("")
	say("    DU 4110    display unit and keyboard")
	say("    CPR 4101   communication processor, talks to the host")
	say("    FD 4120    flexible disk unit, 8 inch, 77 tracks")
	say("")
	say("  They are joined by SS3: a 300 kbit/s synchronous two-wire bus")
	say("  carrying HDLC frames.  None of them can do anything alone.")
	say("  The display has only 2 kbytes of boot PROM and must be handed")
	say("  its operating system over the bus by the disk unit, with the")
	say("  communication processor acting as bus master.")
	say("")
	say("  The boot you are about to watch is a three-way conversation.")
	say("")
end)

at(12, function()
	say("[ 12 s ]  The disk unit has finished its own initial program")
	say("          load and the communication processor is polling it.")
	say("          The display is being sent its operating system in")
	say("          3.25 kbyte blocks, which is exactly one track of the")
	say("          diskette: 26 sectors of 128 bytes.")
end)

at(50, function()
	say("[ 50 s ]  Autologon.  The diskette carries a record saying which")
	say("          module each display should load; this one says EM3274,")
	say("          load map 001.")
	show_screen("autologon")
end)

at(66, function()
	say("[ 66 s ]  The system is up and the machine is now an IBM 3278")
	say("          terminal.")
	show_screen("terminal emulation")
	say("  The bottom line is the operator message line.  *EM* is the")
	say("  emulation's own indicator; the text beside it comes from the")
	say("  product name recorded on the diskette label.")
	say("")
	say("  Load map 001 was read straight off the medium with the")
	say("  manufacturer's own table.  It says: 24x80 screen, keyboard")
	say("  repeat 12.5 Hz, transparent cursor, no APL.")
end)

at(72, function()
	say("")
	say("================================================================")
	say("   VIDEO")
	say("================================================================")
	for tag, s in pairs(manager.machine.screens) do
		say("   %s: %d x %d visible, %.4f Hz", tag, s.width, s.height,
			1.0 / s.frame_period)
	end
	say("")
	say("   Not a guess.  The service manual states the raster in words:")
	say("   426 sweeps per frame, 100 character positions per sweep,")
	say("   9 dot positions per character, 50 Hz refresh.")
	say("   900 x 426 x 50 = 19170000, the crystal fitted on the board.")
	say("")
	say("   The cell is 9 dots wide but the character generator PROM")
	say("   carries only 7: column 0 is blank, column 8 is the gap")
	say("   between cells.  Checked against the ROM itself, where bit 7")
	say("   of the font byte is never a dot, not once in 2 kbytes.")
	say("")
	say("   End of part 1.  Part 2 follows with the service console.")
	say("")
	manager.machine:exit()
end)

-- ============================================================== ACT 2
else

at(0.1, function()
	say("")
	say("================================================================")
	say("   ALFASKOP SYSTEM 41   --   guided tour, part 2 of 2")
	say("================================================================")
	say("")
	say("  Same hardware, same diskette, one byte different: the")
	say("  autologon record now names the console module instead of the")
	say("  terminal emulation.  That is all it takes, because on this")
	say("  machine every program - the emulation, the service console,")
	say("  the word processor - is a module on the diskette that the")
	say("  display is sent over the bus.")
	say("")
end)

at(66, function()
	say("[ 66 s ]  The system's own function menu, straight from the")
	say("          diskette's MENUFILE.")
	show_screen("Alfaskop System 41 Functions")
	say("  Worth reading closely.  'rader' is Swedish for rows:")
	say("")
	say("    24R / 32R / 43R   IBM terminal, 24, 32 or 43 line screen")
	say("    APL               the APL character set variant")
	say("    HST               connect to the host computer")
	say("    AW                ALFAWORD, the word processor")
	say("    AWC               Alfaword customizing")
	say("    LOG               manual logon form")
	say("")
	say("  Alfaword is the interesting entry.  The logon table on this")
	say("  medium resolves it to volume 01702100, that is product")
	say("  4017-021, an application software diskette that would have to")
	say("  be inserted.  We do not have that diskette, so the menu can")
	say("  name the word processor but not start it.  The machine is")
	say("  telling us exactly which medium is missing, which is a fair")
	say("  answer from a 1983 terminal.")
	say("")
end)

at(74, function()
	say("================================================================")
	say("   END OF TOUR")
	say("================================================================")
	say("")
	say("   What you saw: a three processor cluster cold booting over a")
	say("   synchronous bus, loading its operating system from an 8 inch")
	say("   diskette, coming up as an IBM 3278 terminal, and presenting")
	say("   its own function menu from the medium.")
	say("")
	say("   Everything on screen was produced by the original 1983")
	say("   Ericsson firmware and the original diskette.  Nothing is")
	say("   scripted on the emulator side.")
	say("")
	manager.machine:exit()
end)

end

table.sort(queue, function(a, b) return a[1] < b[1] end)

TOURSUB = emu.add_machine_frame_notifier(function()
	frames = frames + 1
	while qi <= #queue and queue[qi][1] <= frames do
		local ok, err = pcall(queue[qi][2])
		if not ok then say("  (step %d: %s)", qi, tostring(err)) end
		qi = qi + 1
	end
end)

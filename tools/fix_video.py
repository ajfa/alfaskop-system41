#!/usr/bin/env python3
"""fix_video.py -- M26 A1: the DU raster, from the documentation.

techtext EE360-810C p.3 (DU 4110), p.401 (DU 4111/4112) and p.474 (DU 4113) all
say the same thing, and osref E90003145E ch.9 (the INITAB table) agrees for all
six screen formats:

    426 sweeps per frame, 100 character positions per sweep, 9 dot positions per
    character, 50 Hz refresh, 19.17 MHz dot rate.

    900 * 426 * 50 = 19'170'000 exactly.

Visible area: 80 characters * 9 dots = 720, 25 lines * 16 sweeps = 400.
The physical screen confirms it: 400 * 0.45 mm = 180 mm, 720 * 0.36 mm = 259 mm,
against the "180 by 258 mm" the manual gives.

The chargen byte holds only 8 of the 9 columns: bit 7 is column 0 and is never a
dot (verified: 0 occurrences over the whole 2 kbyte chargen), bits 6-0 are the
seven dot columns 1-7.  Column 8 has no bit in the ROM - it is the trailing gap.
"""
import io
import sys

P = "./mame/src/mame/ericsson/alfaskop41xx.cpp"
s = io.open(P, encoding="utf-8", errors="surrogateescape").read()
orig = s

ROW_COMMENT = """		// 9 dot positions per character cell (columns 0-8), techtext EE360-810C p.3:
		// "Each character position is divided into nine dot positions or columns
		// (col 0 to 8).  Seven columns (col 1 to 7) are used for character
		// presentation."  Bit 7 of the chargen byte is column 0 and is never a dot
		// (verified over the whole 2 kbyte chargen: 0 occurrences); bits 6-0 are
		// columns 1-7.  Column 8 has no bit in the ROM - it is the trailing gap.
"""

for member in ("m_chargen", "m_du_chargen"):
    old = ("\t\tu8 dots = %s[chr * 16 + ra];\n\n"
           "\t\tfor (int n = 8; n > 0; n--, dots <<= 1)\n"
           "\t\t\t*px++ = BIT(dots, 7) ? fg : bg;" % member)
    new = ("\t\tu8 dots = %s[chr * 16 + ra];\n\n" % member
           + ROW_COMMENT
           + "\t\tfor (int n = 8; n > 0; n--, dots <<= 1)\n"
             "\t\t\t*px++ = BIT(dots, 7) ? fg : bg;\n"
             "\t\t*px++ = bg; // column 8")
    if s.count(old) != 1:
        sys.exit("row callback for %s: %d matches" % (member, s.count(old)))
    s = s.replace(old, new)

for crtc in ("m_crtc", "m_du_crtc"):
    old = "\t%s->set_char_width(8);" % crtc
    if s.count(old) != 1:
        sys.exit("char_width for %s: %d matches" % (crtc, s.count(old)))
    s = s.replace(old, "\t%s->set_char_width(9);" % crtc)

RAW_COMMENT = (
    "\t// 100 character positions of 9 dots = 900 dots per sweep, 426 sweeps per\n"
    "\t// frame: 19.17 MHz / (900 * 426) = 50.000 Hz exactly.  techtext EE360-810C\n"
    "\t// p.3 and osref ch.9 INITAB (all six screen formats give 426 sweeps).\n"
    "\t// Visible: 80 * 9 = 720 by 25 lines * 16 sweeps = 400.\n")

DOT = "19" + chr(39) + "170" + chr(39) + "000"
for screen in ("m_screen", "m_du_screen"):
    old = "\t%s->set_raw(%s, 80 * 8, 0, 80 * 8, 400, 0, 400);" % (screen, DOT)
    if s.count(old) != 1:
        sys.exit("set_raw for %s: %d matches" % (screen, s.count(old)))
    new = RAW_COMMENT + "\t%s->set_raw(%s, 900, 0, 720, 426, 0, 400);" % (screen, DOT)
    s = s.replace(old, new)

io.open(P, "w", encoding="utf-8", errors="surrogateescape").write(s)
print("video: 6 cambios aplicados (2 row callbacks, 2 char_width, 2 set_raw)")

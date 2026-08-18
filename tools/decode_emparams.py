#!/usr/bin/env python3
"""decode_emparams.py [image] -- decode EMLIB1/EADEMPAx byte by byte.

Table: installation manual, "Customizing Data for IBM 3274/78 Emulation",
"Display Unit Parameter Description".  The BSC 3.x column applies to OS M305.

The interesting bytes: 5 is the screen size, 9 the keyboard type, A the key
repetition rate (00 = 25 Hz, 01 = 12.5 Hz), B the cursor and underline style,
and F the APL setting.

The CHR addresses below come from the LTOC of EMLIB1, NOT from the order of the
names: EADEMPA1 is the last member on the medium, A2 to AA run from sector 8
to 16.
"""
import io
import sys

SEC = 128
SPT = 26
IMG = sys.argv[1] if len(sys.argv) > 1 else "system-diskette.img"
d = io.open(IMG, "rb").read()

LTOC = [("EADEMPA1", 17), ("EADEMPA2", 8), ("EADEMPA3", 9), ("EADEMPA4", 10),
        ("EADEMPA5", 11), ("EADEMPA6", 12), ("EADEMPA7", 13), ("EADEMPA8", 14),
        ("EADEMPA9", 15), ("EADEMPAA", 16)]

SCREEN = {0x01: "12x40 / alternate 12x80", 0x02: "24x80 / alternate 24x80",
          0x03: "24x80 / alternate 32x80", 0x04: "24x80 / alternate 43x80"}
KBRATE = {0x00: "25 Hz", 0x01: "12.5 Hz"}
DISP = {0x00: "covering cursor, underlined space",
        0x10: "transparent cursor, underlined space",
        0x20: "covering cursor, underlined word",
        0x30: "transparent cursor, underlined word"}
APL = {0x00: "no APL in the display or the printer",
       0x01: "APL in the display, SE/FI, GB or US",
       0x02: "APL in the display, DK, NO, DE/AT, BE, FR or ES",
       0x80: "APL in the attached printer",
       0x81: "APL in display and printer, SE/FI, GB, US",
       0x82: "APL in display and printer, DK, NO, DE/AT, BE, FR, ES"}

print("image: %s\n" % IMG)
print("%-4s %-9s %-24s %-9s %-38s %-9s %s"
      % ("map", "member", "screen", "key rep", "cursor / underline", "data entry", "APL"))
for n, (name, sector) in enumerate(LTOC):
    off = ((16 * SPT) + (sector - 1)) * SEC
    b = d[off:off + 16]
    print("%03d  %-9s %-24s %-9s %-38s %-9s %s"
          % (n + 1, name,
             SCREEN.get(b[5], "%02X" % b[5]),
             KBRATE.get(b[0x0A], "%02X" % b[0x0A]),
             DISP.get(b[0x0B], "%02X" % b[0x0B]),
             "yes" if b[9] == 1 else "no",
             APL.get(b[0x0F], "%02X" % b[0x0F])))

print("\nraw bytes of each block:")
for n, (name, sector) in enumerate(LTOC):
    off = ((16 * SPT) + (sector - 1)) * SEC
    print("  %-9s (load map %03d, track 16 sector %2d)  %s"
          % (name, n + 1, sector,
             " ".join("%02X" % x for x in d[off:off + 16])))

#!/usr/bin/env python3
"""read_emparams.py [image] -- locate the emulation parameter blocks.

The installation manual, "Customizing Data for IBM 3274/78 Emulation", says:

    Library: EMLIB1.  Member: EADEMPA1 - EADEMPAA.  Type = A.
    Logon name: EM3274.  Load map numbers 001-010.

Each member is the parameter block of one load map.  This locates them on the
medium and prints the volume label.

Medium geometry: 77 tracks x 26 sectors x 128 bytes = 256256 bytes.

NOTE: take the addresses from the LTOC, not from the order of the names.
EADEMPA1 is the LAST one on the medium (track 16 sector 17), not the first.
"""
import io
import sys

SEC = 128
SPT = 26
IMG = sys.argv[1] if len(sys.argv) > 1 else "system-diskette.img"
d = io.open(IMG, "rb").read()
print("image %s  %d bytes  (%d tracks x %d sectors x %d B)"
      % (IMG, len(d), len(d) // (SPT * SEC), SPT, SEC))


def chr_at(off, n):
    return d[off:off + n].decode("latin-1")


print("\n=== volume label (track 0, sector 1) ===")
v = 0
print("  DTYPE   %s" % chr_at(v + 0, 1))
print("  DVOLNR  %s" % chr_at(v + 1, 8))
print("  DNAME   %s" % chr_at(v + 9, 8))
print("  DVERS   %s" % chr_at(v + 17, 2))
print("  DREVDT  %s" % chr_at(v + 19, 10))
print("  DUSER   %s" % chr_at(v + 29, 20))
print("  DVPTR   track %d sector %d" % (d[v + 52], d[v + 53]))
print("  DVSIZE  %d FDEs" % ((d[v + 54] << 8) | d[v + 55]))
print("  DFDBOT  %s" % chr_at(v + 56, 8))
print("  DNAT    %s" % chr_at(v + 64, 24).rstrip())

print("\n=== EADEMPA? members found in the image ===")
i = 0
while True:
    i = d.find(b"EADEMPA", i)
    if i < 0:
        break
    t, rem = divmod(i // SEC, SPT)
    print("  %-9s at offset 0x%05X  (track %2d sector %2d, +0x%02X)"
          % (chr_at(i, 8), i, t, rem + 1, i % SEC))
    i += 1

print("\n=== LTOC entries pointing at them ===")
i = 0
while True:
    i = d.find(b"EADEMPA", i)
    if i < 0:
        break
    ent = i - 1
    if ent >= 0 and chr(d[ent]) in "AFVDRT017":
        print("  %s type %s  BSIZE=%d RSIZE=%d  CHR=(track %d, side %d, sector %d)"
              % (chr_at(i, 8), chr(d[ent]),
                 (d[ent + 20] << 8) | d[ent + 21],
                 (d[ent + 22] << 8) | d[ent + 23],
                 d[ent + 16], d[ent + 17] >> 7, d[ent + 17] & 0x7F))
    i += 1

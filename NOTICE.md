# Notices and third-party material

## MAME

The patches in `patches/` apply to MAME and are licensed BSD-3-Clause, the same
as the files they modify.

`src/mame/ericsson/alfaskop41xx.cpp`, which the driver patch extends, is
`license:BSD-3-Clause` and its copyright holder is **Joakim Larsson Edström**,
who wrote the original Alfaskop driver in MAME. This work builds on it.

The device files touched by the fixes (`mc6844`, `mc6846`, `mc6852`, `mc6854`)
are likewise part of MAME and keep their own copyright holders and licence.

MAME itself is available at https://github.com/mamedev/mame

## Ericsson material

**No Ericsson firmware, ROM image, diskette image or documentation is included
in this repository.**

The Alfaskop System 41 hardware, its firmware and its system diskettes are the
work of Ericsson Information Systems AB, 1983. References to part numbers,
register layouts and documented behaviour in the README and in the tools are
descriptions of a historical system, made for interoperability and
preservation.

To run the emulation you need a ROM set and a system diskette image obtained
separately.

## Documentation index

`docs/DRAWINGS-INDEX.md` is an index of the Ericsson Technical Description
drawings: sheet numbers, board names and drawing numbers. It contains no
reproduction of the drawings themselves.

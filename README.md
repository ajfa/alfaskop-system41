# Ericsson Alfaskop System 41 in MAME

A 1983 Swedish terminal cluster, emulated: **three Motorola 6800 computers**
joined by SS3, a 300 kbit/s synchronous two-wire bus carrying HDLC frames.

| unit | what it is |
|---|---|
| **DU 4110** | display unit and keyboard |
| **CPR 4101** | communication processor, talks to the host |
| **FD 4120** | flexible disk unit, 8 inch, 77 tracks |

None of them can do anything alone. The display holds only 2 kbytes of IPL
PROM; its operating system is sent to it over the bus by the disk unit, one
3.25 kbyte block at a time, which is exactly one track of the diskette
(26 sectors of 128 bytes). Booting is a three-way conversation.

## What works

* Cold boot of all three processors, operating system loaded across the bus.
* The IBM 3278 terminal emulation in both directions.
* Console mode, the system's own service interface, with its function menu and
  its seven system functions.
* The machine reading and listing its own medium: volume label, VTOC, LTOC.
* Manual logon with password authorisation.
* Video at the documented raster: 720x400 visible in a 900x426 frame at exactly
  50.0000 Hz.

## Contents

```
patches/alfaskop-driver.patch   the driver, against MAME 0.288
patches/mc68*.patch             the device fixes, also submitted upstream
tools/                          measurement scripts (MAME Lua and Python)
docs/DRAWINGS-INDEX.md          index of the 277 schematic sheets by title block
```

No Ericsson firmware, ROM or diskette image is included.

## The device fixes

Emulating this machine exercised four MAME devices with real DMA for the first
time and turned up problems in all of them. They are independent of this driver
and have been submitted upstream:

| device | what was wrong | pull request |
|---|---|---|
| `mc6854` | status registers never refreshed on read; only the first byte of each frame transferred; AP not latched; transmit path never refreshed TDRA/TDSR; CTS interrupt under the wrong enable; receiver stalled forever if the drain died mid frame | [mame#15921](https://github.com/mamedev/mame/pull/15921) |
| `mc6844` | only arbitrated in one state, so a single channel could hold the controller for good; a channel with an exhausted byte count still won arbitration; memory to device direction not implemented | [mame#15922](https://github.com/mamedev/mame/pull/15922) |
| `mc6852` | the device never drove its interrupt output at all | [mame#15923](https://github.com/mamedev/mame/pull/15923) |
| `mc6846` | CP2 latched an interrupt edge only while configured as an output | [mame#15924](https://github.com/mamedev/mame/pull/15924) |

The `mc6844` byte count check is the one to know about if you touch disk
timing. Requiring a non-zero count in the arbitration took late requests from
4 in 123475 to 0 in 116358, and the worst wait from 34 us to 11 us. An FD1771
has one byte time, 32 us, so that is the difference between completing a
multi-sector read and reporting lost data.

## The video geometry

Documented rather than tuned by eye:

```c
m_crtc->set_char_width(9);
m_screen->set_raw(19'170'000, 900, 0, 720, 426, 0, 400);
```

The service manual states the raster in words: 426 sweeps per frame, 100
character positions per sweep, 9 dot positions per character, 50 Hz refresh.
900 x 426 x 50 = 19170000, the crystal fitted on the board. All six screen
formats in the operating system's own CRTC initialisation table give 426
sweeps, and the physical screen agrees: 400 sweeps at 0.45 mm is 180 mm and
720 dots at 0.36 mm is 259 mm, against the "180 by 258 mm" the manual quotes.

The character cell is 9 dots wide but the generator PROM holds only 7 of them.
Bit 7 of the font byte is column 0 and is never a dot, verified as zero
occurrences across the whole 2 kbyte generator; column 8 has no bit in the ROM
at all, being the gap between cells.

## Tools

Measurement, not scaffolding.

| tool | what it does |
|---|---|
| `probes.lua` | reads PROMID, OSFUNC1, MAXRAM, the CP's device status list at `$0400`, and logs writes to the display adapter PIA |
| `lamps.lua` | turns the front panel lamps into a boot semaphore using the meanings in the maintenance manual |
| `typamatic_measure.lua` | holds a key and times what the real keyboard firmware emits |
| `read_emparams.py`, `decode_emparams.py` | locate and decode the ten emulation parameter blocks on the medium using the manufacturer's table |
| `screen_at.lua`, `shot.lua` | dump or capture the display at given times |
| `tour.lua` | a narrated guided tour of the machine |
| `fix_video.py` | applies the video geometry change to a clean tree |

## Running it

MAME does not ship this driver's fixes, so build MAME 0.288 with the patch:

```sh
git clone https://github.com/mamedev/mame.git && cd mame
git checkout mame0288
patch -p1 < /path/to/patches/alfaskop-driver.patch
make SUBTARGET=alfaskop \
     SOURCES=src/mame/ericsson/alfaskop41xx.cpp,src/mame/skeleton/alfaskop_s41_kb.cpp -j4
```

Then, with the ROM set and an 8 inch system diskette image of your own:

```sh
./alfaskop alfaskop4120 -rompath roms -flop1 system-diskette.img \
           -video none -sound none -skip_gameinfo -seconds_to_run 70
```

Note that MAME shows two start-up screens for a driver marked not working, and
only the first can be suppressed with `-skip_gameinfo`. Anything automated
should run with `-video none`; `video:snapshot()` from Lua still writes a PNG of
the emulated screen without a window.

## What is left

1. **The SS3 line rhythm.** The frame path works but the timing is not the real
   one. The mechanism is the timed FIFO refill (`set_wire_rate` in `mc6854`),
   and making it work needs the receive path rebuilt in one piece. Documented
   constants: 300 kbit/s, 27 us per byte, RTS to CTS is 32 bit times (106.7 us),
   CTS is dropped by the DMAC's DEND, a poll is retried once after 10 ms.
2. **The port number is physical.** The bus is collapsed to a broadcast, so the
   display answers as port 0 while the diskette is customised for port 8. In
   real hardware the number comes from which two-wire connection on the CP's
   TUA boards the unit is plugged into.
3. **The TIA has a physical loopback.** Modulated transmit data is fed back into
   the demodulator and into the ADLC, and the ADLC must be programmed not to
   react to it. That is the normal signal path, not a test mode, and it is not
   modelled.
4. **DMA is not the same mechanism everywhere.** The FD 4120 uses the 6844 in
   TSC steal mode; the DU 4111/4112/4113 hard-wire TSC inactive and stall the
   CPU by stretching the clock.

## Documentation notes

The Ericsson documentation set for this machine runs to 2393 pages and was read
in full. Three things worth knowing if you go into it:

* A chapter map built from running headers is not exhaustive. The most useful
  chapter of all, the DU 4110 / DTC / DTC-A description, has no chapter heading.
* The OCR is useless for the schematics and for the form pages of the
  installation manuals, which are scanned rotated 90 degrees. Render them.
* Where two manuals disagree, the one that numbers the register bits wins. The
  operating system reference prints `DIAPRES2 = 41` for a value the machine
  actually writes as `11`, and has the IBM/UTS sense of one display adapter bit
  inverted.

## Licence

BSD-3-Clause, the same as MAME, whose driver and devices this extends.

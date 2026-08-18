# Index of the 277 sheets of the Technical Description Drawings

Built by reading the **rendered title block of all 277 sheets**, not the OCR:
`dw_titleblocks.sh` crops the bottom right corner of each sheet at 150 dpi and
tiles them into 9 contact sheets that can be read in a few passes.

**67 of the 277 pages are portrait (A4)**: section covers, Contents pages and
the reference sheets of the power supplies. They carry no title block in that
corner. They are listed at the end. The other **210 are schematic sheets** and
all have a legible title block.

Title block convention: `<board> <description> - <E number> - <total> BLAD/SHEET <n>`.
The `E34xxx yyyy z` numbers end in **`3` = Reference Sheet** (component list,
test points, power), **`2` = Block Diagram**, **`1` = Logic Diagram**. So for
addresses and signals go to the ones ending in `1`; to find out which chip an
IC is, go to the ones ending in `3`.

## Index by board

| sheets | board | description | E number |
|---|---|---|---|
| 0001-0004 | - | cover and **Contents**, Communication Processors | - |
| 0005-0009 | **CPB** | Communication Processor board | E34060 2000 (sh 1-5) |
| 0010-0014 | **CPB** | Communication Processor board | E34060 2010 (sh 1-5) |
| 0015-0019 | **CPB** | Communication Processor board | E34060 2011 (sh 1-5) |
| 0020-0022 | **TAB** | TUA Interconnection board | E34073 2000 (sh 1-3) |
| 0023-0025 | **TUA** | Terminal unit adapter | E34181 2001 (sh 1-3) |
| 0026-0028 | **TUA/T** | Terminal unit adapter / T | E34180 2000 (sh 1-3) |
| 0029-0031 | **TUA-T** | Terminal unit adapter - TAB | E34180 2001 (sh 1-3) |
| 0032-0034 | **TUA/E** | Terminal unit adapter / E | E34180 2010 (sh 1-3) |
| 0035 | **CIB** | CCC Interconnection Board | E34070 2000 3 |
| 0036-0040 | **CCC-1** | Channel Communication Controller 1 | E34071 2999 (sh 1-5) |
| 0041-0045 | **CCC-1** | Channel Communication Controller 1 | E34071 2000 (sh 1-5) |
| 0046-0050 | **CCC-2** | Channel Communication Controller 2 | E34072 2999 (sh 1-5) |
| 0051-0055 | **CCC-2** | Channel Communication Controller 2 | E34072 2000 (sh 1-5) |
| **0056-0060** | **DTC** | **Display Terminal Controller** | **E34062 2000 (sh 1-5)** |
| **0061-0065** | **DTC** | **Display Terminal Controller** | **E34062 2001 (sh 1-5)** |
| **0066-0071** | **DTC-A** | **Display Terminal controller - A** | **E34062 2100 (sh 1-5, sheet 4 in two PCB versions)** |
| **0072-0077** | **DTC-A** | **Display Terminal controller - A** | **E34062 2101 (sh 1-5, sheet 4 in two PCB versions)** |
| 0078-0083 | **DTC-B** | Display terminal controller - B (DU 4111) | E34062 2110 (sh 1-6) |
| 0084-0089 | **DTC-C** | Display terminal controller - C (DU 4112) | E34062 2120 (sh 1-6) |
| 0090-0095 | **DTC-D** | Display terminal controller - D (DU 4113) | E34062 2130 (sh 1-6) |
| 0097 | **ICBD** | Inter Connection Board | E34081 2100 3 |
| 0099 | **CHGB** | Character generator board | E34082 2000 1 |
| 0101 | **CHGB** | Character generator board | E34082 2010 1 |
| **0102-0104** | **TIA** | **Two Wire Interface Adapter** | **E34063 2000 (sh 1-3)** |
| 0105-0106 | **TIA-A** | Two Wire Interface Adapter | E34063 2100 (sh 1-2) |
| 0107-0108 | **TIA-A/B** | Two Wire Interface Adapter | E34063 2101 (sh 1-2) |
| 0109-0110 | **TIA-B** | Two Wire Interface Adapter | E34063 2120 (sh 1-2) |
| 0111-0112 | **TIA-S** | Two Wire Interface Adapter | E34063 2110 (sh 1-2) |
| 0115-0116 | **CRB** | CRT Unit Board (two PCB versions) | E34111 2000 1 sh 3a, 3b |
| 0119 | **CRB** | CRT Unit board | E34111 2010 1 |
| 0121 | **CRU** | Cathode Ray Tube Unit | E34112 2030 3 |
| 0122-0123 | **SPA** | Selector pen adapter | E34069 2000 (sh 1-2) |
| **0125-0127** | **KBC** | **Keyboard controller** | **E34066 2000 (sh 1-3)** |
| 0128-0129 | **KXB** | Keyboard expansion board | E34067 2000 (sh 1-2) |
| **0130-0164** | **KBLB / KBSB / MIA** | **Keyboard Logic Board, Keyboard Switch Board, MID Interface Adapter** - all portrait, drawing series `69 54 xxx` and `E34131 2100 4` | see the Contents page 0124 |
| 0165-0166 | - | **Contents**, Optional Units | - |
| 0167-0170 | **GPB** | General Processor Board | E34186 2000 (sh 1, 3-5) |
| 0171-0173 | **MRW** | Memory Board Read Write | E34191 2001 (sh 1-3) |
| 0174-0176 | **MRW-A** | Memory Board Read Write A, 16/32 K | E34191 2010 (sh 1-3) |
| 0177-0179 | **MRW-B** | Memory Board Read Write B, 32 K | E34191 2020 (sh 1-3) |
| 0180-0182 | **MRW-C** | Memory Board Read Write C, 32 KB | E34191 2021 (sh 1-3) |
| 0183-0187 | **MRO** | Memory board read only (sh 1a/1b and 3a/3b per PCB version) | E34192 2000 |
| 0188-0191 | **ACA** | Asynchronous Communication Adapter | E34193 2000 (sh 1-3, sheet 3 in a/b) |
| 0192-0195 | **ACA-A** | Asynchronous communication adapter | E34193 2010 (sh 1-4) |
| 0196-0198 | **ACA-B** | Asynchronous communication adapter | E34193 2100 (sh 1-3) |
| 0199-0202 | **ACA-D** | Asynchronous communication adapter | E34193 2110 (sh 1-4) |
| 0203-0205 | **SCA** | Synchronous communication adapter | E34194 2000 (sh 1-3) |
| 0206-0208 | **SCA-B** | Synchronous Communication Adapter | E34194 2002 (sh 1-3) |
| 0209-0211 | **SCA-D** | Synchronous communication adapter | E34194 2010 (sh 1-4) |
| 0212-0214 | **SCA-E** | Synchronous communication adapter | E34194 2020 (sh 1-4) |
| 0215-0218 | **SCC I** | Synchronous Communication Controller I | E34195 2000 (sh 1-4) |
| 0219-0222 | **SCC I** | Synchronous Communication Controller I | E34195 2001 (sh 1-4) |
| 0223-0225 | **SCC 2** | Synchronous Communication Controller 2 | E34196 2000 (sh 1-3) |
| 0227 | **BCRB** | Bar code reader board | E34161 2000 1 sh2 |
| 0230, 0232 | **FCA** | Fiber-optic Communication Adapter | E34074 2000 (sh 1, 3) |
| 0233 | **CAB** | CCTV Adapter board | E34197 2000 3 |
| 0234 | - | **Contents**, Flexible Disk Unit | - |
| **0235-0240** | **FDP** | **Flexible Disk Processor** | **E34064 2000 (sh 1-4)** plus **E34064 2001 1** circuit diagram, two PCB versions |
| **0241-0247** | **FDA** | **Flexible Disk Adapter** | **E34065 2001 (sh 1A-5A)** plus circuit diagram 1B/2B |
| **0248-0252** | **FDA** | **Flexible Disk Adapter** | **E34065 2002 (sh 1-5)** |
| 0254 | - | **Contents**, Power Supplies | - |
| 0256 | **CPS** | Communication Processor Power Supply | E34068 2001 2 sh2 |
| 0258 | **FPS** | Flexible Disk Unit Power Supply | E34068 2004 2 sh2 |
| 0260 | **DPS** | Display Terminal Power Supply | E34068 2005 2 sh2 |
| 0262 | **UPS** | Universal Power Supply | E34068 2010 2 sh2 |
| 0264 | **UPB** | Universal Power Board | E34068 2011 2 sh2 |
| 0266 | **UPB** | Universal power board (US) | E34068 2060 2 sh2 |
| 0268 | **DPB** | Display power board | E34068 2030 2 sh2 |
| 0270 | **DPB** | Display power board (US) | E34068 2040 2 sh2 |
| 0272 | **DPB** | Display power board | E34068 2050 2 sh2 |
| 0274-0277 | - | drawings `1911-ROA 117 202/1`, `202/2`, `203/1`, `203/2` | - |

## The sheets that matter for the DU 4110 + CPR 4101 + FD 4120 cluster

```
DTC   (the display)   0056-0065   two variants: E34062 2000 and E34062 2001
DTC-A (display -002)  0066-0077   two variants: E34062 2100 and E34062 2101
TIA   (the two-wire)  0102-0104
KBC   (the keyboard)  0125-0127   plus KBLB/KBSB 0130-0164, portrait
FDP   (the disk unit) 0235-0240
FDA   (the disk unit) 0241-0252
CPB   (the CP)        0005-0019   three variants
TAB/TUA (the SS3 bus) 0020-0034
```

## The 67 portrait pages (no title block in that corner)

```
001 002 003 004 096 098 100 113 114 117 118 120 124
130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149
150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166
226 228 229 231 234 253 254 255 257 259 261 263 265 267 269 271 273
```

Seven of them are **Contents** pages and do read well by OCR: **0003**
(Communication Processors), **0004** (Communication Processor, Local), **0124**
(Keyboards), **0165-0166** (Optional Units), **0234** (Flexible Disk Unit) and
**0254** (Power Supplies). The Display Units Contents page is **not in the
scan**; that section is identified from the title blocks instead, and starts at
sheet 0056.

The block **0130-0164** is the most interesting of the portrait pages: the
**Keyboard Logic Board (KBLB)** and **Keyboard Switch Board (KBSB)** drawings,
in a different drawing series (`69 54 129`, `69 54 163`, `69 54 174`,
`69 54 126`, `69 54 128`, of 8, 8, 8, 6 and 3 sheets), plus the **MIA**
(`E34131 2100 4`). Those are the real keyboard schematics and they need a
portrait crop geometry, which the title block sweep did not use.

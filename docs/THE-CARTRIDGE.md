# The tape

    file       trailblazer.cas
    size       38,458 bytes
    sha256     779b662747fdd04b641fbf898124611562d9913e570f5050b5d73580ce63cf50
    machine    MSX1
    publisher  Gremlin Graphics, 1986
    original   Mr Chip Software (Shaun Southern, Commodore 64)

## How it is made

A `.cas` does not store the modulation: it stores **the bytes the MSX would have
read**, and marks where each block starts with an eight-byte sentinel,
`1F A6 DE BA CC 13 7D 74`, always aligned to a multiple of 8. That alignment is
what makes the splitting reliable: the same sequence inside the data, if it
lands unaligned, is not a separator.

This tape has **two layers**, and that is where all the fun is.

**The outer one is the MSX's.** The first block is an ordinary BIN header — ten
`0xD0` bytes and six of name, `Trail!` — and the second its body, which loads at
`0xD800` and runs there. That is the only thing the BIOS loads its own way.

**The inner one the game invents.** The eight remaining blocks carry no MSX
header: they go in pairs, and the first of each pair is an eight-byte little
header:

    0xFE   load address (2, LE)   length (2, LE)   sum   00 00

And the second starts with another loose byte, `0xFF`, before the content.

## Those two bytes are not data: they are the sync

The loader enters its read routine **with the byte it expects already in the
accumulator** — `ld a,0feh` at `0xD80D` for the little header and `ld a,0ffh` at
`0xD81D` for the body — and stores nothing until it has seen it (`0xD87D`).
Besides, the little header is read by asking for **exactly four bytes** at
`0xD8ED` (`ld de,00004h`), so of the block's eight only the address and the
length count; the fifth is a checksum and the last two, padding.

It adds up perfectly, and that is what confirms the reading: every body block
measures **1 + length + padding**, and the padding is exactly what is needed for
the next sentinel to land on a multiple of eight.

    header               loads at           and takes      the block measures
    FE 00 90 01 01 6E    0x9000..0x9100       257 bytes     264 = 1+257+6
    FE 00 88 01 1C 6B    0x8800..0xA400      7169 bytes     7176
    FE 00 88 00 28 5E    0x8800..0xAFFF     10240 bytes     10248
    FE E8 80 18 4F C1    0x80E8..0xCFFF     20248 bytes     20250

Without discounting that byte, the first piece starts with an `rst 38h` that
does nothing sensible. Discounting it, it starts with `di`, which is what it
ought to do. **All four start with clean code under this reading and under no
other.**

## The five pieces

| piece | loads at | takes | what it is |
|---|---|---:|---|
| cargador | `0xD800` | 385 | the tape loader |
| slots | `0x9000` | 257 | hunts for RAM across the slots |
| portada | `0x8800` | 7,169 | the loading screen |
| datos | `0x8800` | 10,240 | the fourteen tracks |
| juego | `0x80E8` | 20,248 | the game |

**Two load at the same address**, and the fourth walks over both. It is not a
mistake: the loading screen is on show while the rest is read, and of the tracks
piece the only thing that survives is its top 0x2000 bytes, copied to `0x6000`
before anyone treads on them.

## The RAM finder

The second piece, the one at `0x9000`, is 82 bytes that do one thing: walk the
four slots and their four subslots **trying to write at `0x4000`** — read,
invert all eight bits, write and read back — and the moment they find RAM they
leave in `0xFFFE` the value to poke into the PPI to have it mapped in.

That `0xFFFE` is the first thing the other three pieces read: `ld a,(0fffeh) /
out (0a8h),a`. The game needs **RAM in every page**, so it cannot leave the BIOS
ROM visible.

## The VDP registers

Measured on the machine, not deduced: `make emulador` dumps all eight.

| reg | value | what it says |
|---|---|---|
| R0 | `0x02` | mode 2 (SCREEN 2) |
| R1 | `0xE2` | 16 KB, display on, interrupt enabled, 16x16 sprites |
| R2 | `0x06` | names at `0x1800` |
| R3 | `0xFF` | colour: base `0x2000`, mask `0x1FFF` |
| R4 | `0x03` | patterns: base `0x0000`, mask `0x1FFF` |
| R5 | `0x36` | sprite attributes at `0x1B00` |
| R6 | `0x07` | sprite patterns at `0x3800` |
| R7 | `0x01` | black border |

It is the ordinary SCREEN 2 geometry. Worth measuring rather than assuming: the
first reading of this disassembly took the dumps to `0x1800` for the colour
table, and they are the name table.

## How the 38,299 bytes break down

| |bytes|%|
|---|---:|---:|
|traced code|6,556|17.12|
|identified data|31,743|82.88|
|**unexplained**|**0**|**0.00**|
|**total**|**38,299**|**100.00**|

The file's other 159 bytes are the `.cas` wrapping: sentinels, headers, sync
bytes and alignment padding.

# Getting started

This repository holds the commented disassembly of Gremlin Graphics's
**Trailblazer** for the MSX (1986, tape). It does not hold the tape: the `.cas`
image is not distributed.

## What you need

- `pasmo` — the assembler that reproduces the tape
- `z80dasm` — the disassembler the listings are generated with
- `python3` — the tools under `tools/`
- `make`
- Your own copy of the tape, in the root and named `trailblazer.cas`

It is **exactly 38,458 bytes** and its fingerprint is:

    sha256  779b662747fdd04b641fbf898124611562d9913e570f5050b5d73580ce63cf50

To check it:

    make cinta

## Reproducing the whole thing

    make

That chains the four things that matter:

| step | what it does | what it proves |
|---|---|---|
| `make listados` | builds the five `.asm` from the trace and the notes | that the listings are not hand-written |
| `make verify` | reassembles the five pieces, wraps them back up and compares the sha256 | that the listing **is** the tape |
| `make sanity` | checks how the bytes are accounted for | that not one byte is left unexplained |
| `make test` | 40 checks | that what gets published holds up against the bytes |

The one that decides is `make verify`, and here it has **two steps**: first each
piece has to assemble and give exactly its bytes, and then, wrapping them the
way the `.cas` wraps them — the eight-byte sentinel aligned to a multiple of
eight, the MSX BIN header for the first, the loader's own little headers for
the other four, the sync byte and the alignment padding — the whole file has to
come out with its sha256.

The first step only says the listings are consistent with what we fed them. The
second says what we fed them is the tape.

## The five pieces

    piece      loads at   takes        what it is
    cargador   0xD800       385 bytes  the tape loader
    slots      0x9000       257 bytes  hunts for RAM across the slots
    portada    0x8800      7169 bytes  the loading screen
    datos      0x8800     10240 bytes  the fourteen tracks
    juego      0x80E8     20248 bytes  the game

`tools/cinta.py` pulls them out and puts them back together, and says so if the
model of the tape does not add up.

## The numbers

    make densidad

    0 routines below 10 %, out of 355
    in total: 3637 instructions, 1118 comments, 30.7 %

## The pictures

    make imagenes

Draws into `work/gfx/` the loading screen, **all fourteen tracks in full**, the
table of rows, the sprite patterns and the font. None of them is a capture:
they are built by running in Python the same steps the Z80 runs.

## The emulator

    make emulador

Loads the tape into openMSX, goes into the menu, starts a game, and dumps VRAM,
all 64 KB of RAM **and the eight VDP registers**. That is where the screen
geometry the pictures use came from — measured, not deduced.

There are three more tools for asking the machine things when static analysis
runs out of anything to look at:

    tools/omsx_quien_lee.tcl     who touches a memory area, and from where
    tools/omsx_quien_llama.tcl   who enters a routine
    tools/omsx_muestrea.tcl      which parts of the loader actually run

The first found who reads the perspective table, which is written in no
instruction anywhere. The third turned up a loader routine that **never runs**.

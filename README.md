# Trailblazer (Gremlin Graphics, MSX1) — a commented disassembly

*(También [en castellano](README.es.md).)* ·
**[Read it on the web](https://antxiko.github.io/Trailblazer-disassembly/)**

A complete, commented disassembly of Gremlin Graphics's **Trailblazer** for the
MSX (1986, tape). Every one of the 38,299 bytes of content is accounted for, and
reassembling the five pieces and wrapping them back up gives the `.cas`
**byte for byte**.

    explained          38,299 of 38,299   100 %
    comment density     1,118 of 3,637    30.7 %
    routines below 10 %       0 of 355
    tests                    40, green
    reassembly         same sha256 as the tape

## What is here

    src/trailblazer_*.asm    the five commented listings, generated
    src/*.notes              the comments and data blocks, with their measure
    src/*.entries            the entry points that cannot be deduced statically
    tools/                   trace, listing, pictures, and three emulator probes
    tests/                   40 checks that do not need the tape
    docs/                    the bilingual website

## The tape is not here

`trailblazer.cas` is not distributed. Put your own copy in the root; it is
exactly 38,458 bytes and

    sha256  779b662747fdd04b641fbf898124611562d9913e570f5050b5d73580ce63cf50

## Reproducing it

    make cinta         # checks your tape is the same one
    make               # listings, reassembly, sanity checks and tests
    make imagenes      # draws all fourteen tracks, and the rest, from the tape
    make emulador      # loads it in openMSX and dumps VRAM, RAM and the VDP

## Not one screen capture

Every picture in this repository is **drawn from the bytes of the tape**, by
running in Python the same steps the Z80 runs: stretching the compressed colour,
undoing the transposition of the patterns and walking the tracks row by row.

All **fourteen tracks** are drawn, whole.

## What turned up

- **The routine that draws the track rewrites itself.** The `ld a,000h` that
  push pixels out of the VDP port read nothing: an earlier routine writes the
  value into the instruction, row by row. Seven hand-written operands.
- **The loader does not read the tape**: it builds a six-instruction bridge on
  the stack — switch the slot, call the BIOS, switch it back — and rewrites it
  three times, into TAPION, TAPIN and STMOTR.
- **Five bands repainted at five different rates** make the perspective. No
  division, no table, not one multiply.
- **Fourteen tracks in 3,494 bytes**, because they store indices, not tiles.
- **One routine reads all eighty keys**, by manufacturing the `bit n,a` opcode
  and writing it into itself.
- **The loading bar is the screen border.**
- **Two kilobytes of stale memory** got recorded onto the tape by accident.

The lot, with its measurements, in
[Findings](https://antxiko.github.io/Trailblazer-disassembly/FINDINGS.html).

## Licence and credit

The tools, comments, analysis and documentation are MIT — see `LICENSE`. The
game is not ours: read [LEGAL-NOTICE.md](LEGAL-NOTICE.md).

The original is Mr Chip Software's, by **Shaun Southern**; this MSX version is
credited in the game itself to **Shaun Hollingworth, Colin Dooley, Peter Harrap,
Chris Kerry and Greg Holmes** of Gremlin Graphics, with design by **Terry
Lloyd**. The loading screen is signed **STEVE.**

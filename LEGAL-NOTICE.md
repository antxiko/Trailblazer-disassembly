# Legal notice and attribution

*(Tambien disponible [en castellano](AVISO-LEGAL.md).)*

## Who owns what

**The game is not ours.** *Trailblazer* was published by **Gremlin Graphics**
for the MSX in 1986, on tape: 38,458 bytes. The original is **Mr Chip
Software**'s and was written by **Shaun Southern** for the Commodore 64; this
version is credited to **Shaun Hollingworth, Colin Dooley, Peter Harrap, Chris
Kerry and Greg Holmes**, with design by **Terry Lloyd**. The game says so
itself, in the scroller on its title screen. All rights remain with their
holders.

**What is ours** are this repository's tools, the comments in the listing, the
analysis and the documentation. That is published under the licence in
`LICENSE`.

## What is in this repository

The five files `src/trailblazer_*.asm` are the commented disassembly of the
tape's five pieces. They are published for the **preservation, study and documentation** of a title that is
part of MSX software history.

The tape image (`.cas`) is **not** distributed here. Anyone who wants to
rebuild the listing has to supply their own, and the `Makefile` checks its
sha256 before doing anything.

The pictures produced by `tools/graficos.py` are not illustrations brought in
from outside: they are drawn by reading the tape's own blocks, at the
addresses the listing gives. They are part of the proof that the reading of the
binary is right: if it were wrong, they would come out as noise.

## What it rests on

Nobody else's work. Everything stated here comes from reading this binary or
from measuring it running, and each claim carries its evidence next to it: the
instruction that reads a datum, the table that ends exactly where it has to end,
or the measurement made in the emulator. What is not settled is said not to be.

Where something outside the tape is cited -the format of Gremlin Graphics's hidden
credits, which the game itself gives in its scroller- its source is named and the person who
found it is thanked.

## If you are one of the authors

If you worked on *Trailblazer* or hold rights over the game, and you would rather this
material were not published, **say so and it comes down, no argument**. The
intent of this work is the opposite of harming you: it is to put on record how
it was made.

# Open questions

All 38,299 bytes are explained and the five listings reproduce the tape byte for
byte. What follows are not gaps in the disassembly: they are things the game
does whose **why** has not been measured, or that could not be reached.

## How you get into the cheat mode

The banner is there: **FOOLED YOU!    YOU ARE NOW IN CHEAT MODE**, at `0x9CE6`.
And the scroller jokes that *there may be a Cheat mode but I doubt it*.

What has not been found is **what you have to do to make it come up**. The
string is pointed at by no traced instruction, so it is painted from code that
only runs down that path.

## Six routines nobody is known to call

`0x81A5`, `0x8CBE`, `0x93DC`, `0x9722`, `0x973F` and `0x9DAD` disassemble as
complete, coherent routines — they start on a valid instruction, touch the same
variables as the rest of the game and finish on a `ret` — but:

- they appear in no `call`, `jp`, `ld hl,` or bare word in the piece's 20,248
  bytes;
- no relative jump from traced code lands in them;
- and with breakpoints on the machine and the game running for ninety seconds
  **none of them is entered**.

Either they belong to screens the test never reached — game over, the high score
table, the cheat mode itself — or they are dead code. They are declared as code
because that is what they are; how you reach them is not known.

## The turbo loader that goes unused

`0xD8D5` reads the tape bit by hand through port `0xA2`, and it is measured that
**it does not run**. What is not known is whether it is another version's
loader, a leftover from testing, or an alternative path that turns on under some
condition we never met.

## The fifth byte of the little headers

Each piece is preceded by eight bytes: `0xFE`, the load address, the length,
**one more byte** and two zeroes. The loader reads only four (`ld de,00004h`),
so nobody looks at that fifth byte during loading.

The four values it takes are `0x6E`, `0x6B`, `0x5E` and `0xC1`. It looks like a
checksum — the loader keeps one in `b` while reading (`0xD8A5`) — but since it
is never compared against anything, it cannot be asserted.

## The 768 bytes of the row table that go unused

The row table takes 0x800 bytes, that is 409 rows of five. The highest index any
of the fourteen tracks uses is **173**. From 174 on there are rows sitting there
that no track names: are they from tracks that were dropped, or just padding?

## How much of each track is actually played

All fourteen are drawn in full, but it has not been measured whether the game
walks them to the end or the finish comes sooner. The `0xFF` that closes each
list is what makes `0x8B1B` flag the end of a track, so in principle yes, but it
has not been checked by running it.

## Who STEVE is

The loading screen carries that signature bottom right. No Steve appears in the
scroller's credits: the names there are Shaun Hollingworth, Colin Dooley, Peter
Harrap, Chris Kerry, Greg Holmes, Terry Lloyd and Shaun Southern.

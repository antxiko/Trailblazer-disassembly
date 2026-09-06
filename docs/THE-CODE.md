# The code

## The routine that draws the track rewrites itself

This is the heart of the game and deserves telling slowly.

The track in perspective is drawn nowhere at all. The engine that paints it —
`0x8C11` going up and `0x8C65` going down — is a run of identical blocks:

    ld a,e / out (099h),a      ; the VRAM address
    ld a,d / out (099h),a
    ld a,000h                  ; <- the pixel byte
    out (098h),a               ; and out it goes

That `ld a,000h` **does not read the byte from anywhere: it gets written into
it**. For each row, `0x8BAE` pulls five bytes out of the table at `0x7800`,
passes them through two 256-entry lookup tables — the ones `0x890F` and `0x8920`
build at `0xFB00` and `0xFC00` by repeating eight bytes thirty-two times — and
pokes the result into the six operands at `0x8C2D`, `0x8C42`, `0x8C56`,
`0x8C81`, `0x8C95` and `0xC8A9`.

There is a seventh hand-written operand, at `0x8C01`, choosing the page of the
perspective table. `0x8998` writes it when the track starts.

## The perspective table appears in no instruction

The 3,570 bytes from `0xC20E` to the end of the piece are pointed at by no
`ld hl,0Cxxxh`. The address is computed: `0x8C14` does

    ld a,e / and 007h / add a,a / or 0c0h / ld h,a

that is, **`0xC0` plus twice the low three bits of `e`**, which gives the eight
even pages `0xC0`, `0xC2` … `0xCE`.

Since static analysis had nothing left to look at, we asked the machine: an
openMSX watchpoint over `0xC20E..0xCFFF` with the game running
(`tools/omsx_quien_lee.tcl`) says it is read by **exactly seven places**,
`0x9632` and the six in the drawing routine.

And `0x9629` uses **those same eight even pages** for something else: it copies
them 256 at a time into RAM — skipping two pages at a time with the double
`inc h` at `0x9639` — and dumps the 0x800 into VRAM from there. The same bytes
serve as table and as patterns.

## Five bands at five rates

Advancing the track computes no projection at all. `0x8AD3` splits the screen
into five bands and repaints each at a different rate:

| band | rows | repainted |
|---|---:|---|
| the nearest | 32 | **twice** per step |
| the second | 16 | once |
| the third | 16 | one time in two |
| the fourth | 16 | one in four |
| the horizon | 16 | one in eight |

Five counters with their mask — `and 001h`, `and 003h`, `and 007h` — and the
road recedes. No division, no perspective table, not one multiply.

And the ball's height is turned into a track row by the same reasoning, in
reverse: `0x8E31` compares against `0xB3`, `0x8E`, `0x64` and `0x3E` and returns
4, 3, 2, 1 or 0.

## Fourteen tracks that store no tiles

The fourteen add up to **3,494 rows** of five tiles, which would be 17,470
bytes. They take **3,494**.

The tracks piece carries 0x2000 bytes into RAM at `0x6000`. Of those:

- the **last 0x800** are the table of rows: five tiles per row, one after
  another, and that is where `0x8BB9` goes looking with `row*5 + 0x7800`;
- the **first 0x1800** are the fourteen tracks, and each is a list of
  **indices** into that table, closed by `0xFF`. That is what the loop at
  `0x93A4` says, walking track by track looking for it.

A 219-row track takes 219 bytes because rows repeat and naming them is enough.

## The interrupt, in mode 2

`0x88E4` sets it up, and it is textbook with a neat detour:

1. `0xFD00..0xFDFF` is filled with `0xFE` — 257 bytes in one go, with the
   `ld (hl),0feh` and the overlapping LDIR at `0x88EE` — and `ld i,a` with `a` =
   `0xFD` puts the vector table there;
2. the vector that comes out of that table is the word at `0xFDFE`, which is
   `0xFEFE`;
3. and at `0xFEFE` it writes… `0xFB18`, which as an instruction is `jr $-5`;
4. and at `0xFEFB` it writes `0xC3` and behind it `0x9134`: `jp 09134h`.

The detour is the classic trick for making a 257-byte vector table out of **one
repeated byte**. The real destination is `0x9134`, and the whole game hangs off
it: the music, the controls, the ball's movement, the track's advance and the
painting.

## The stars

There are two kinds, and neither is drawn as a sprite.

The **background** ones are the whole screen shifting: `0x9BB1` moves a row one
pixel left with **thirty-two `rl (hl)` written one after another, no loop**,
with the carry passing from one byte to the next. Every eighth there is a
`dec hl` instead of a `dec l`, which is the jump to the band above. And they
only move one frame in eight.

The **foreground** ones are seven dots with their own speed and acceleration
(`0x8F65`), spreading towards the edges as if coming head-on: each has its
acceleration added every two frames, and when one goes off the edge it comes
back to the centre with fresh parameters.

**Each dot's colour comes from register R**, the DRAM refresh counter, shifted
into the high nibble (`0x90DE`). It is not decided: it is taken.

## The dice

`0x908E` has no table. It takes the seed, puts it in the high byte, subtracts
the same value from it twice, crosses the two bytes **and mixes in register R**.
Since R changes with every instruction executed, two games do not come out the
same even from an identical start.

## One routine for all eighty keys

`0xBF62` takes a key code. Out of its low three bits it pulls **the bit
number**, shifts it into place and ors in a `0x47`, which is the opcode for
`bit 0,a`. And then **it writes that into `0xBF85`**, the instruction it will
execute two lines later.

No table, no loop, no eight branches.

`0x9695` does the same with the colour of a line of text: it writes an `or` with
the colour over a `nop` (`0x9808`), so the same loop paints lit or unlit with no
comparison at all.

## The text

Every string carries **its end marked in bit 7** of the last letter. That is why
dumped raw they look glued together.

`(0xA41E)` is the pointer to the character sheet the painting routine uses
(`0x97D3`). The startup code leaves it at `0xBA2E`, the ordinary font, and
`0x9957` and `0x9973` swap it for another sheet for one caption and put it back.

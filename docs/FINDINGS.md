# Findings

## The loader does not read the tape: it builds a bridge on the stack

The MSX BIOS only loads the first piece, the one at `0xD800`. That piece reads
the other four itself, and it does it with a trick.

`0xD850` puts the stack at `0xFCA4` and pushes **five words that are not data
but instructions**: `0xC961`, `0xEDD9`, `0x00E1`, `0xCDD9` and `0x69ED`. What
ends up written at `0xFC9A` is this:

    FC9A  ED 69     out (c),l     ; c = 0xA8: switch the slot
    FC9C  D9        exx
    FC9D  CD E1 00  call 000E1h   ; the BIOS's TAPION
    FCA0  D9        exx
    FCA1  ED 61     out (c),h     ; and put the slot back
    FCA3  C9        ret

And then it calls it with `call 0fc9ah`.

**Why on the stack?** Because the game needs RAM in every page, but reading tape
needs the BIOS ROM. The bridge has to live somewhere visible under both
configurations, and page 3 is always RAM. Before building it, `0xD83D` saves
what was there — twelve words of BIOS variables — and `0xD8C1` puts them back
afterwards.

And the same bridge serves three different calls, because **it rewrites
itself**:

- it starts as `call 000E1h`, which is **TAPION**: turn on the motor and wait
  for the header tone;
- `0xD871` pokes an `0xE4` into the operand and turns it into **TAPIN**, to read
  the bytes;
- `0xD8B5` pokes an `0xF3` and turns it into **STMOTR** with `a` at zero, that
  is, stop the motor.

## There is a turbo loader that goes unused

At `0xD8D5` sits a routine that reads the tape bit **by hand**: it waits for the
edge on port `0xA2`, which is where the PSG hands back the cassette input, and
along the way pushes two bytes out of the PSG.

**It never runs.** And that is measured, not assumed: sampling the PC four
thousand times while the whole tape loads (`tools/omsx_muestrea.tcl`) turns up
only `0xD82E-0xD831`, `0xD883-0xD88C` and `0xD89A-0xD8AF`. Not one sample lands
in `0xD8D5`.

It is a turbo loader left inside, unused.

## The loading bar is the screen border

While it reads, `0xD8A7` pushes the low byte of what is left out of **VDP
register 7**. No bar drawn and no tiles to paint: the border colour just keeps
changing, and that is the whole progress indicator.

## The routine that draws the track rewrites itself

Told in full in [The code](THE-CODE.html). In short: the `ld a,000h` that push
the pixels out of the VDP port **read nothing**; an earlier routine writes the
value into the instruction, row by row.

That is **seven operands** hand-written in the drawing routine alone. And there
are two more elsewhere: the sound channel's volume (`0x81CF` over `0x81C6`) and
the colour of a line of text (`0x9695` over a `nop` at `0x9808`).

## One routine reads all eighty keys

`0xBF62` **manufactures the opcode**: out of the low three bits of the key code
it pulls the bit number, shifts it into place, ors in a `0x47` — which is
`bit 0,a` — and writes the result into `0xBF85`, the instruction it executes two
lines later.

## Fourteen tracks in 3,494 bytes

The fourteen add up to 3,494 rows of five tiles. They take 3,494 bytes, one per
row, because **they store no tiles but indices** into a table of rows living in
the last 0x800 bytes of the load.

All of them are on show, drawn from those bytes, in [The 14
tracks](THE-TRACKS.html).

## The loading screen's colour is compressed eight to one

In SCREEN 2 the colour table is 0x1800 bytes. The loading screen stores
**0x300**: one byte per pattern, because all eight rows carry the same colour,
and `0x889C` writes it eight times over.

And both colours fit inside that byte: **bits 0 to 2 are the ink** and **3 to 5
the paper**, indices into a palette of eight that sits there twice — once in the
high nibble and once in the low — so they can be joined with an `or`. Bits 6 and
7 go unused.

**The very same palette is in the game**, at `0x9593`, byte for byte, even
though they are different pieces of tape.

## The patterns are stored transposed

The loop that dumps patterns into VRAM reads eight bytes with `inc h`, not
`inc hl`: **jumping 256 at a time**. Only afterwards does it move on to the next
pattern.

So the byte `(base + row*0x100 + pattern)` is row `row` of pattern `pattern`,
not eight consecutive rows. Read the obvious way, the loading screen comes out
as noise. It happens in the loading screen (`0x8858`), in the game (`0x9522`)
and in the scroller's buffer (`0x961A`).

## The stars' colour comes from register R

`0x90DE` takes the DRAM refresh counter, shifts it into the high nibble and
writes it into the colour table. Each star comes out whatever colour it lands
on, without spending a byte on the decision. And the random number generator at
`0x908E` does the same: it mixes its seed with R, so two games do not come out
alike even from an identical start.

## The game says who made it

The scroller on the title screen — from `0x9E69` to `0xA29D` — gives the full
credits:

> Welcome to Trailblazer.......... (c) Mr Chip 1986........This amazing version
> written by SHAUN HOLLINGWORTH, COLIN DOOLEY, PETER HARRAP, CHRIS KERRY and
> GREG HOLMES (too pey?) of Gremlin Graphics Software Limited........Originally
> created by Shaun Southern on the Commodore.....Game play and some graphic
> bits by Terry LLoyd (yaki da!) and P.Harrap.

And it goes on with the keys — **Q-Left, W-right, P-Up, L-Down and Space to
jump** — with a grumble about how hard the levels are, with a *P.S don't forget
to read the P.S OK or you'll be sorry!* and with a **Hello Mum!** at the end.

## The tracks are named after the people who made them

The fourteen names, at `0xA4CB`:

EASY GOING · WOOLY JUMPER · **TERRY'S TEST** · **PETE STREET** · HACKERS EVIL
HOLES · **GREG THE NIPPER** · **SHAUN NOT SEAN!!** · JASON'S JUMPABOUT ·
MARK'S MOTOROLA · **CHRIS'S CUL-DE-SAC** · WELL I NEVER · SHRIGGLES'S SHRIGGLE
· BOING BOING SPLAT!! · LAST BUT NOT LEAST!

Terry Lloyd, Pete Harrap, Greg Holmes, Shaun Hollingworth and Chris Kerry all
appear in the credits.

## The cheat mode banner is there, and cannot be seen

The scroller jokes that *there may be a Cheat mode but I doubt it*. The banner is
there all right: at `0x9CE6`, **FOOLED YOU!    YOU ARE NOW IN CHEAT MODE**, right
against Gremlin's copyright, terminated by bit 7 like every string in the game.

**Nothing paints it.** In all 38,299 bytes there is not one instruction loading
anything from page `0x9C`: no `ld hl,09Cxxh`, no `ld h,09Ch`, not one stray word
pointing into the block.

On the Commodore 64 you enter the cheat mode with **Z+X+C**. Here you cannot: the
whole keyboard goes through a single routine, `mira_una_tecla` at `0xBF62`, which
builds its `bit n,a` inside the instruction itself; the binary holds **twelve**
calls to it, and among the codes handed to it — a key code is row×8+bit — there
is no Z (`0x2F`), no X (`0x2D`) and no C (`0x18`):

| code | key | what for |
|---|---|---|
| `0x22` | M | the music |
| `0x00` | row 0 | its bits 3 and 4: the menu's **3** and **4** |
| `0x26` `0x21` `0x2C` `0x25` | Q L W P | left, down, right, up |
| `0x40` | SPACE | jump |
| `0x31` + `0x3C` | CTRL + STOP | **quit the game in progress** |

And asked of the machine: with a read watchpoint over `0x9CC8..0x9D19` and the
three keys held down six seconds on the title, six on the options screen and
eight during play, **zero reads**. As a control, the combination that does
exist: with a breakpoint on `0x8AC1`, five seconds of play touching nothing
never reach it, and pressing CTRL+STOP does.

The text made the conversion; the trigger did not.

## Two kilobytes of stale memory, recorded onto the tape

The piece carrying the tracks is 10,240 bytes but **only the top half is used**:
all its code does is move the 0x2000 bytes at `0x9000` into RAM at `0x6000`, and
the game, loading afterwards, walks over `0x8800..0x9000` without anyone having
read it.

And we know where those two kilobytes came from: **231 consecutive bytes, from
`0x8815` to `0x88FC`, are identical to what the game carries for those very
addresses**, and the same startup code follows byte for byte. Of the 2,048,
exactly half match the game.

Whoever made the tape dumped `0x8800..0xB000` in one go because what mattered
was `0x9000..0xB000`, and got two kilobytes of the game thrown in.

The same thing happens, smaller, with the tails of the loader (143 bytes) and of
the RAM finder (175): no instruction reads them.

## The loading screen is signed

**STEVE.**, bottom right and in small type. It is the only thing on the whole
tape with a person's name on it that is not in the scroller.

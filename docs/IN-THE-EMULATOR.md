# In the emulator

Here the emulator is not decoration: it is a **measuring instrument**, and three
things in this disassembly would not have been settled without it.

## Loading the tape and dumping everything

    make emulador

Puts the tape into openMSX, types `BLOAD"CAS:",R`, waits until the PC has spent
eight seconds inside `0x80E8..0xCFFF` and dumps VRAM, all 64 KB of RAM **and the
eight VDP registers**. Then it goes into the menu, starts a game, and dumps
again.

It takes about 190 emulated seconds: that is 38 KB of tape at 1200 baud, though
emulated at full tilt.

## The keyboard is not read through the BIOS

And that matters for automating it. openMSX's `type` injects the keypress where
BASIC reads it, and this game **reads the keyboard by hand through the PPI**
(`0xBF17` and `0xBF62`). The keypress BASIC injects lasts less than its scan and
never registers.

The way out is to press the key **in the matrix** and hold it half a second:

    keymatrixdown 8 0x01          ; space
    after time 0.5 {keymatrixup 8 0x01}

The game itself says what to press: *Press any key for options* first, and once
in the menu, `3 : Play the game`.

## That is where the screen geometry came from

    R0 = 0x02   mode 2 (SCREEN 2)
    R1 = 0xE2   16 KB, display on, interrupt on, 16x16 sprites
    R2 = 0x06   names               at 0x1800
    R3 = 0xFF   colour    base 0x2000, mask 0x1FFF
    R4 = 0x03   patterns  base 0x0000, mask 0x1FFF
    R5 = 0x36   sprite attributes   at 0x1B00
    R6 = 0x07   sprite patterns     at 0x3800
    R7 = 0x01   black border

Measuring rather than assuming is not fussiness: the first reading of this
disassembly took the dumps to `0x1800` for the colour table, and they are **the
name table**. With the wrong geometry the pictures come out right in shape and
wrong in place, and you cannot see that by looking at them.

## Who touches a memory area

    tools/omsx_quien_lee.tcl

Puts a watchpoint over a range and notes the PC of every read or write. It is
for when static analysis runs out of anything to look at: when the address is
**computed** and appears in no instruction.

This is what settled the **perspective table**. The 3,570 bytes from `0xC20E` to
the end are pointed at by no `ld hl,0Cxxxh`, and there is no way to find them by
reading. Watching the area with the game running turned up **exactly seven
places**: `0x9632` and the six in the drawing routine.

## Who enters a routine

    tools/omsx_quien_llama.tcl

Breakpoint on the routine, then look at who has just left the return address on
the stack. It was used on six routines nobody visibly calls: they appear in no
`call`, `jp` or `ld hl,`, and no relative jump from traced code lands in them.

Of the six, **none ran** in ninety seconds of play. Either they belong to
screens the test never reached — game over, the high score table, the cheat mode
— or they are dead code. It is in [Open questions](OPEN-QUESTIONS.html).

It also served the opposite purpose: confirming that `0x8E4B` and `0x92D1`,
reached by a `ld hl,nn / push hl` rather than a `call`, **do run**.

## Which parts of the loader actually run

    tools/omsx_muestrea.tcl

Four thousand samples of the PC while the whole tape loads. Not as exact as a
breakpoint, but plenty for telling live code from code that is never touched.

This is how we found that the routine at `0xD8D5` — the one reading the tape bit
by hand through port `0xA2` — **never runs at any point**: the actual loading
calls the BIOS's TAPIN. It is a turbo loader left inside.

## And a claim that had to be withdrawn

Before that measurement, this disassembly said the loader "builds its own read
routine on the stack and pulls the bit off port 0xA2 by hand". Half of that was
true — the bridge on the stack is there — and the other half false: the bridge
does not read bits, **it calls the BIOS**, and the routine that does read bits
goes unused.

It was corrected as soon as the machine said so.

## Tcl traps already paid for in this series

- No brackets inside a `format`.
- Binary files with `-translation binary`.
- `debug read_block`, since `debug save_to_file` does not exist.
- And in a watchpoint handler, careful reading variables that may not exist: the
  exception is swallowed silently and the counter goes up without anything being
  written to the log.

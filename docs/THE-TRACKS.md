# The 14 tracks

Here are **all fourteen tracks** in the game, drawn from the bytes of the tape.
Not one capture.

Each is laid on its side: **the start on the left and the finish on the
right**, and top to bottom the five tiles the track is wide. The colours are
the eight kinds of tile the engine understands, not an interpretation: they
come from the dispatcher at `0x8E65`, which compares the tile against those
values and no others.

| colour | what it is | what it does |
|---|---|---|
| black | hole | the ball falls through |
| blue | track | nothing |
| green | speed up | pushes speed to 6 |
| red | slow down | drops it to 2 |
| white | bounce | starts one of the jump curves |
| yellow | controls reversed | left and right swap |

And what is stored on the tape is **not these tiles**: it is fourteen lists of
indices into a table of rows. How, is worked out in [The
code](THE-CODE.html).

The names come from the game itself, in the list at `0xA4CB`. And it is no
accident that they sound like people's names: **the tracks are named after the
people who made them**.

## 1. EASY GOING

![EASY GOING](imagenes/pista-01.png)

*219 rows. It carries 265 holes, 75 tiles that speed you up, 8 that slow you down, 58 that bounce and 0 that reverse the controls.*

## 2. WOOLY JUMPER

![WOOLY JUMPER](imagenes/pista-02.png)

*227 rows. It carries 327 holes, 50 tiles that speed you up, 48 that slow you down, 139 that bounce and 10 that reverse the controls.*

## 3. TERRY'S TEST

![TERRY'S TEST](imagenes/pista-03.png)

*220 rows. It carries 197 holes, 39 tiles that speed you up, 5 that slow you down, 165 that bounce and 17 that reverse the controls.*

## 4. PETE STREET

![PETE STREET](imagenes/pista-04.png)

*279 rows. It carries 521 holes, 39 tiles that speed you up, 7 that slow you down, 56 that bounce and 20 that reverse the controls.*

## 5. HACKERS EVIL HOLES

![HACKERS EVIL HOLES](imagenes/pista-05.png)

*326 rows. It carries 636 holes, 5 tiles that speed you up, 10 that slow you down, 78 that bounce and 195 that reverse the controls.*

## 6. GREG THE NIPPER

![GREG THE NIPPER](imagenes/pista-06.png)

*371 rows. It carries 1140 holes, 10 tiles that speed you up, 6 that slow you down, 232 that bounce and 0 that reverse the controls.*

## 7. SHAUN NOT SEAN!!

![SHAUN NOT SEAN!!](imagenes/pista-07.png)

*319 rows. It carries 681 holes, 103 tiles that speed you up, 29 that slow you down, 119 that bounce and 174 that reverse the controls.*

## 8. JASON'S JUMPABOUT

![JASON'S JUMPABOUT](imagenes/pista-08.png)

*335 rows. It carries 854 holes, 0 tiles that speed you up, 0 that slow you down, 262 that bounce and 31 that reverse the controls.*

## 9. MARK'S MOTOROLA

![MARK'S MOTOROLA](imagenes/pista-09.png)

*335 rows. It carries 506 holes, 5 tiles that speed you up, 0 that slow you down, 454 that bounce and 43 that reverse the controls.*

## 10. CHRIS'S CUL-DE-SAC

![CHRIS'S CUL-DE-SAC](imagenes/pista-10.png)

*155 rows. It carries 449 holes, 0 tiles that speed you up, 0 that slow you down, 46 that bounce and 59 that reverse the controls.*

## 11. WELL I NEVER

![WELL I NEVER](imagenes/pista-11.png)

*115 rows. It carries 286 holes, 25 tiles that speed you up, 4 that slow you down, 47 that bounce and 30 that reverse the controls.*

## 12. SHRIGGLES'S SHRIGGLE

![SHRIGGLES'S SHRIGGLE](imagenes/pista-12.png)

*175 rows. It carries 342 holes, 54 tiles that speed you up, 5 that slow you down, 172 that bounce and 116 that reverse the controls.*

## 13. BOING BOING SPLAT!!

![BOING BOING SPLAT!!](imagenes/pista-13.png)

*175 rows. It carries 538 holes, 9 tiles that speed you up, 13 that slow you down, 73 that bounce and 50 that reverse the controls.*

## 14. LAST BUT NOT LEAST!

![LAST BUT NOT LEAST!](imagenes/pista-14.png)

*239 rows. It carries 374 holes, 123 tiles that speed you up, 22 that slow you down, 193 that bounce and 38 that reverse the controls.*


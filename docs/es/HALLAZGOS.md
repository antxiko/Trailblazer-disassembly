# Hallazgos

## El cargador no lee la cinta: monta un puente en la pila

El BIOS del MSX solo carga la primera pieza, la de `0xD800`. Las otras cuatro
las lee ella, y lo hace con un truco.

`0xD850` pone la pila en `0xFCA4` y empuja **cinco words que no son datos sino
instrucciones**: `0xC961`, `0xEDD9`, `0x00E1`, `0xCDD9` y `0x69ED`. Lo que
queda escrito en `0xFC9A` es esto:

    FC9A  ED 69     out (c),l     ; c = 0xA8: conmuta la ranura
    FC9C  D9        exx
    FC9D  CD E1 00  call 000E1h   ; TAPION del BIOS
    FCA0  D9        exx
    FCA1  ED 61     out (c),h     ; y devuelve la ranura que había
    FCA3  C9        ret

Y luego lo llama con `call 0fc9ah`.

**¿Por qué en la pila?** Porque el juego necesita RAM en todas las páginas,
pero para leer cinta hace falta la ROM del BIOS. El puente tiene que vivir en
un sitio que esté visible con las dos configuraciones, y la página 3 es RAM
siempre. Antes de montarlo, `0xD83D` guarda lo que había ahí —doce words de
variables del BIOS— y `0xD8C1` las devuelve al acabar.

Y el mismo puente sirve para tres llamadas distintas, porque **se reescribe**:

- arranca con `call 000E1h`, que es **TAPION**: enciende el motor y espera el
  tono de cabecera;
- `0xD871` mete un `0xE4` en el operando y lo convierte en **TAPIN**, para leer
  los bytes;
- `0xD8B5` mete un `0xF3` y lo convierte en **STMOTR** con `a` a cero, o sea
  parar el motor.

## Hay un cargador rápido que no se usa

En `0xD8D5` hay una rutina que lee el bit de la cinta **a mano**: espera el
flanco del puerto `0xA2`, que es por donde el PSG devuelve la entrada de
casete, y de paso saca dos bytes por el PSG.

**No se ejecuta nunca.** Y eso está medido, no supuesto: muestreando el PC
cuatro mil veces mientras la cinta carga entera (`tools/omsx_muestrea.tcl`)
solo aparecen `0xD82E-0xD831`, `0xD883-0xD88C` y `0xD89A-0xD8AF`. En `0xD8D5`
no cae ni una muestra.

Es un cargador rápido que se quedó dentro sin usarse.

## La barra de carga es el borde de la pantalla

Mientras lee, `0xD8A7` saca el byte bajo de lo que queda por **el registro 7
del VDP**. No hay barra dibujada ni casillas que pintar: el color del borde va
cambiando solo, y eso es todo el indicador de progreso.

## La rutina que dibuja la pista se reescribe a sí misma

Contado entero en [El código](EL-CODIGO.html). En resumen: los `ld a,000h` que
sacan los píxeles por el puerto del VDP **no leen nada**; una rutina anterior
les escribe el valor dentro de la instrucción, fila a fila.

Son **siete operandos** escritos a mano en la misma rutina de dibujo. Y hay dos
más en otros sitios: el volumen del canal de sonido (`0x81CF` sobre `0x81C6`) y
el color de una línea de texto (`0x9695` sobre un `nop` de `0x9808`).

## Una sola rutina mira las ochenta teclas

`0xBF62` **fabrica el opcode**: de los tres bits bajos del código de tecla saca
el número de bit, lo sube al hueco que le toca, le pega un `0x47` —que es
`bit 0,a`— y escribe el resultado en `0xBF85`, la instrucción que ejecuta dos
líneas más abajo.

## Catorce pistas en 3.494 bytes

Las catorce suman 3.494 filas de cinco casillas. Ocupan 3.494 bytes, uno por
fila, porque **no guardan casillas sino índices** a una tabla de filas que vive
en los últimos 0x800 bytes de la carga.

Se ven todas, dibujadas desde esos bytes, en [Las 14
pistas](LAS-PISTAS.html).

## El color de la pantalla de carga va comprimido ocho a uno

En SCREEN 2 la tabla de color son 0x1800 bytes. La pantalla de carga guarda
**0x300**: un byte por patrón, porque las ocho filas llevan el mismo color, y
`0x889C` lo escribe ocho veces seguidas.

Y dentro de ese byte caben los dos colores: los **bits 0 a 2 son la tinta** y
los **3 a 5 el papel**, índices de una paleta de ocho que está dos veces —una
en el nibble alto y otra en el bajo— para poder pegarlos con un `or`. Los bits
6 y 7 no se usan.

**La misma paleta está en el juego**, en `0x9593`, byte por byte, aunque sean
piezas distintas de la cinta.

## Los patrones van transpuestos

El bucle que vuelca los patrones a la VRAM lee ocho bytes con `inc h`, no con
`inc hl`: **saltando de 256 en 256**. Y solo después pasa al patrón siguiente.

O sea que el byte `(base + fila*0x100 + patrón)` es la fila `fila` del patrón
`patrón`, y no las ocho filas seguidas. Leído del modo obvio, la pantalla de
carga sale a ruido. Pasa en la pantalla de carga (`0x8858`), en el juego
(`0x9522`) y en el búfer del rótulo que desfila (`0x961A`).

## El color de las estrellas sale del registro R

`0x90DE` toma el contador de refresco de la DRAM, lo sube al nibble alto y lo
escribe en la tabla de color. Cada estrella sale del color que toque, sin
gastar un byte en decidirlo. Y el generador de números al azar de `0x908E` hace
lo mismo: mezcla su semilla con R, así que dos partidas no salen iguales aunque
se arranque igual.

## El juego dice quién lo hizo

El rótulo que desfila en el título —de `0x9E69` a `0xA29D`— da los créditos
enteros:

> Welcome to Trailblazer.......... (c) Mr Chip 1986........This amazing version
> written by SHAUN HOLLINGWORTH, COLIN DOOLEY, PETER HARRAP, CHRIS KERRY and
> GREG HOLMES (too pey?) of Gremlin Graphics Software Limited........Originally
> created by Shaun Southern on the Commodore.....Game play and some graphic
> bits by Terry LLoyd (yaki da!) and P.Harrap.

Y sigue con las teclas —**Q-Left, W-right, P-Up, L-Down and Space to jump**—,
con una queja sobre lo difíciles que son los niveles, con un *P.S don't forget
to read the P.S OK or you'll be sorry!* y con un **Hello Mum!** al final.

## Las pistas llevan el nombre de quien las hizo

Los catorce nombres, en `0xA4CB`:

EASY GOING · WOOLY JUMPER · **TERRY'S TEST** · **PETE STREET** · HACKERS EVIL
HOLES · **GREG THE NIPPER** · **SHAUN NOT SEAN!!** · JASON'S JUMPABOUT ·
MARK'S MOTOROLA · **CHRIS'S CUL-DE-SAC** · WELL I NEVER · SHRIGGLES'S SHRIGGLE
· BOING BOING SPLAT!! · LAST BUT NOT LEAST!

Terry Lloyd, Pete Harrap, Greg Holmes, Shaun Hollingworth y Chris Kerry salen
todos en los créditos.

## El modo de trampas existe

El rótulo bromea con que *there may be a Cheat mode but I doubt it*. Lo hay: en
`0x9CE6` está su cartel, **FOOLED YOU!    YOU ARE NOW IN CHEAT MODE**, pegado
al copyright de Gremlin.

Cómo se entra es una [pregunta abierta](PREGUNTAS-ABIERTAS.html).

## Dos kilobytes de memoria vieja, grabados en la cinta

La pieza que trae las pistas mide 10.240 bytes pero **solo usa la mitad de
arriba**: lo único que hace su código es llevar los 0x2000 de `0x9000` a la RAM
en `0x6000`, y el juego, que se carga después, pisa `0x8800..0x9000` sin que
nadie lo haya leído.

Y se sabe de dónde salen esos dos kilobytes: **231 bytes seguidos, de `0x8815`
a `0x88FC`, son idénticos a los que el juego trae para esas mismas
direcciones**, y detrás sigue, byte a byte, el mismo código de arranque. De los
2.048, la mitad justa coinciden con el juego.

El que grabó la cinta volcó `0x8800..0xB000` de un tirón porque lo que le
importaba era `0x9000..0xB000`, y se llevó de propina dos kilobytes del juego
que ya estaban en memoria.

Lo mismo pasa, más pequeño, con las colas del cargador (143 bytes) y del
buscador de RAM (175): ninguna instrucción las lee.

## La pantalla de carga lleva firma

**STEVE.**, abajo a la derecha y en letra pequeña. Es lo único de toda la cinta
con nombre de persona que no esté en el rótulo que desfila.

# La cinta

    fichero    trailblazer.cas
    tamaño     38.458 bytes
    sha256     779b662747fdd04b641fbf898124611562d9913e570f5050b5d73580ce63cf50
    máquina    MSX1
    editor     Gremlin Graphics, 1986
    original   Mr Chip Software (Shaun Southern, Commodore 64)

## Cómo está hecha

Un `.cas` no guarda la modulación: guarda **los bytes que el MSX habría leído**,
y marca dónde empieza cada bloque con un centinela de ocho bytes,
`1F A6 DE BA CC 13 7D 74`, siempre alineado a múltiplo de 8. Esa alineación es
lo que hace fiable el troceo: la misma secuencia dentro de los datos, si cae
desalineada, no es un separador.

Esta cinta tiene **dos capas**, y ahí está toda la gracia.

**La de fuera es la del MSX.** El primer bloque es una cabecera BIN de las de
siempre —diez bytes `0xD0` y seis de nombre, `Trail!`— y el segundo su cuerpo,
que se carga en `0xD800` y se ejecuta ahí. Eso es lo único que el BIOS carga a
su manera.

**La de dentro se la inventa el juego.** Los ocho bloques que quedan no llevan
cabecera de MSX: van de dos en dos, y el primero de cada pareja es una
cabecerita de ocho bytes:

    0xFE   dirección de carga (2, LE)   longitud (2, LE)   suma   00 00

Y el segundo empieza por otro byte suelto, `0xFF`, antes del contenido.

## Esos dos bytes no son datos: son el sincronismo

El cargador entra en su rutina de lectura **con el byte que espera ya en el
acumulador** —`ld a,0feh` en `0xD80D` para la cabecerita y `ld a,0ffh` en
`0xD81D` para el cuerpo— y no guarda nada hasta haberlo visto (`0xD87D`).
Además la cabecerita se lee pidiendo **cuatro bytes exactos** a `0xD8ED`
(`ld de,00004h`), así que de los ocho del bloque solo cuentan la dirección y la
longitud; el quinto es la suma de control y los dos últimos, relleno.

Cuadra a la perfección, y es lo que confirma la lectura: cada bloque de cuerpo
mide **1 + longitud + relleno**, y el relleno es justo lo que hace falta para
que el centinela siguiente caiga en múltiplo de ocho.

    cabecera             se carga en        y ocupa        el bloque mide
    FE 00 90 01 01 6E    0x9000..0x9100       257 bytes    264 = 1+257+6
    FE 00 88 01 1C 6B    0x8800..0xA400      7169 bytes    7176
    FE 00 88 00 28 5E    0x8800..0xAFFF     10240 bytes    10248
    FE E8 80 18 4F C1    0x80E8..0xCFFF     20248 bytes    20250

Sin descontar ese byte, la primera pieza empieza por un `rst 38h` que no pinta
nada. Descontándolo empieza por `di`, que es lo que tiene que hacer. **Las
cuatro arrancan con código limpio con este reparto y con ningún otro.**

## Las cinco piezas

| pieza | carga en | ocupa | qué es |
|---|---|---:|---|
| cargador | `0xD800` | 385 | el cargador de cinta |
| slots | `0x9000` | 257 | busca la RAM por las ranuras |
| portada | `0x8800` | 7.169 | la pantalla de carga |
| datos | `0x8800` | 10.240 | las catorce pistas |
| juego | `0x80E8` | 20.248 | el juego |

**Dos cargan en la misma dirección**, y la cuarta pasa por encima de las dos.
No es un error: la pantalla de carga se ve mientras se lee el resto, y de la
pieza de las pistas lo único que sobrevive son sus 0x2000 bytes de arriba, que
se copian a `0x6000` antes de que nadie los pise.

## El buscador de RAM

La segunda pieza, la de `0x9000`, son 82 bytes que hacen una sola cosa:
recorrer las cuatro ranuras y sus cuatro subranuras **probando a escribir en
`0x4000`** —leer, invertir los ocho bits, escribir y volver a leer—, y en cuanto
encuentran RAM dejan en `0xFFFE` el valor que hay que meter en el PPI para
tenerla puesta.

Ese `0xFFFE` es lo primero que leen las otras tres piezas: `ld a,(0fffeh) /
out (0a8h),a`. El juego necesita **RAM en todas las páginas**, y por eso no
puede quedarse con la ROM del BIOS visible.

## Los registros del VDP

Medidos en la máquina, no deducidos: `make emulador` vuelca los ocho.

| reg | valor | qué dice |
|---|---|---|
| R0 | `0x02` | modo 2 (SCREEN 2) |
| R1 | `0xE2` | 16 KB, pantalla encendida, interrupción activa, sprites de 16x16 |
| R2 | `0x06` | nombres en `0x1800` |
| R3 | `0xFF` | color: base `0x2000`, máscara `0x1FFF` |
| R4 | `0x03` | patrones: base `0x0000`, máscara `0x1FFF` |
| R5 | `0x36` | atributos de sprite en `0x1B00` |
| R6 | `0x07` | patrones de sprite en `0x3800` |
| R7 | `0x01` | borde negro |

Es la geometría normal de SCREEN 2. Conviene medirla y no suponerla: la primera
lectura de este desensamblado daba los volcados a `0x1800` por tabla de color,
y son la tabla de nombres.

## El reparto de los 38.299 bytes

| |bytes|%|
|---|---:|---:|
|código trazado|6.556|17,12|
|datos identificados|31.743|82,88|
|**sin explicar**|**0**|**0,00**|
|**total**|**38.299**|**100,00**|

Los otros 159 bytes del fichero son el envoltorio del `.cas`: centinelas,
cabeceras, sincronismos y relleno de alineación.

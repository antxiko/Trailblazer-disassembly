# Empezar

Este repositorio contiene el desensamblado comentado de **Trailblazer** de
Gremlin Graphics para MSX (1986, cinta). No contiene la cinta: la imagen del
`.cas` no se distribuye.

## Lo que hace falta

- `pasmo` — el ensamblador que reproduce la cinta
- `z80dasm` — el desensamblador con el que se genera el listado
- `python3` — las herramientas de `tools/`
- `make`
- Tu propia copia de la cinta, en la raíz y con el nombre `trailblazer.cas`

Son **38.458 bytes exactos** y su huella es:

    sha256  779b662747fdd04b641fbf898124611562d9913e570f5050b5d73580ce63cf50

Para comprobarla:

    make cinta

## Reproducirlo entero

    make

Eso encadena las cuatro cosas que importan:

| orden | qué hace | qué demuestra |
|---|---|---|
| `make listados` | genera los cinco `.asm` desde el trazado y las notas | que los listados no están escritos a mano |
| `make verify` | reensambla las cinco piezas, las vuelve a envolver y compara el sha256 | que el listado **es** la cinta |
| `make sanity` | comprueba el reparto de bytes | que no queda ni un byte sin explicar |
| `make test` | 40 comprobaciones | que lo que se publica se sostiene sobre los bytes |

La prueba que decide es `make verify`, y aquí tiene **dos pasos**: primero cada
pieza tiene que ensamblar y dar exactamente sus bytes, y luego, envolviéndolas
como las envuelve el `.cas` —el centinela de ocho bytes alineado, la cabecera
BIN del MSX para la primera, las cabeceritas del cargador propio para las otras
cuatro, el byte de sincronismo y el relleno de alineación—, tiene que salir el
fichero entero con su sha256.

El primer paso solo dice que los listados son consistentes con lo que les hemos
dado de comer. El segundo dice que lo que les hemos dado de comer es la cinta.

## Las cinco piezas

    pieza      carga en   ocupa        qué es
    cargador   0xD800       385 bytes  el cargador de cinta
    slots      0x9000       257 bytes  busca la RAM por las ranuras
    portada    0x8800      7169 bytes  la pantalla de carga
    datos      0x8800     10240 bytes  las catorce pistas
    juego      0x80E8     20248 bytes  el juego

`tools/cinta.py` las saca y las vuelve a montar, y avisa si el modelo de la
cinta no cuadra.

## Las cifras

    make densidad

    0 rutinas por debajo del 10 %, de 355
    en total: 3637 instrucciones, 1119 comentarios, 30,8 %

## Las imágenes

    make imagenes

Dibuja en `work/gfx/` la pantalla de carga, **las catorce pistas enteras**, la
tabla de filas, los patrones de sprite y la fuente. Ninguna es una captura: se
montan ejecutando en Python los mismos pasos que ejecuta el Z80.

## El emulador

    make emulador

Carga la cinta en openMSX, entra en el menú y arranca una partida, y vuelca la
VRAM, los 64 KB de RAM **y los ocho registros del VDP**. De ahí salió la
geometría de pantalla que usan los dibujos, que no está deducida sino medida.

Hay dos herramientas más para preguntarle cosas a la máquina cuando el análisis
estático se queda sin nada que mirar:

    tools/omsx_quien_lee.tcl     quién toca una zona de memoria, y desde dónde
    tools/omsx_quien_llama.tcl   quién entra en una rutina
    tools/omsx_muestrea.tcl      qué trozos del cargador se ejecutan de verdad

Con la primera se encontró quién lee la tabla de la perspectiva, que no aparece
escrita en ninguna instrucción. Con la tercera se descubrió que hay una rutina
del cargador que **no se ejecuta nunca**.

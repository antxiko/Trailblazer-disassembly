#!/usr/bin/env python3
"""Escribe la pagina de las catorce pistas, en los dos idiomas.

Se genera y no se escribe a mano a proposito: debajo de cada pista va la cuenta
de lo que lleva -filas, agujeros, tramos que aceleran, que frenan y que hacen
rebotar-, y esa cuenta sale de recorrerla casilla a casilla con las mismas
reglas que el motor del juego. Escrita a mano seria una cifra sin medir, que es
justo lo que esta serie no publica.

Uso: pagina_pistas.py <dir_work> <docs>
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import graficos as G                                       # noqa: E402

CAB = {
    "es": """# Las 14 pistas

Aqui estan **las catorce pistas** del juego, dibujadas desde los bytes de la
cinta. Ni una captura.

Cada una va tumbada: **la salida a la izquierda y la meta a la derecha**, y de
arriba abajo las cinco casillas de ancho que tiene la pista. Los colores son
los ocho tipos de casilla que el motor entiende, y no una interpretacion: salen
del despachador de `0x8E65`, que compara la casilla contra esos valores y
contra ningun otro.

| color | que es | que hace |
|---|---|---|
| negro | agujero | la bola se cae |
| azul | pista | nada |
| verde | acelera | sube la velocidad a 6 |
| rojo | frena | la baja a 2 |
| blanco | rebota | arranca una de las curvas de salto |
| amarillo | mandos al reves | izquierda y derecha se cambian |

Y lo que hay guardado en la cinta **no son estas casillas**: son catorce listas
de indices a una tabla de filas. Como, esta contado en [El
codigo](EL-CODIGO.html).

Los nombres los da el propio juego, en la lista de `0xA4CB`. Y no es
casualidad que suenen a nombres de persona: **las pistas se llaman como quien
las hizo**.

""",
    "en": """# The 14 tracks

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

""",
}

PIE = {
    "es": ("*%d filas. Lleva %d agujeros, %d casillas que aceleran, %d que "
           "frenan, %d que hacen rebotar y %d que invierten los mandos.*\n\n"),
    "en": ("*%d rows. It carries %d holes, %d tiles that speed you up, %d that "
           "slow you down, %d that bounce and %d that reverse the controls.*\n\n"),
}


def cuenta(pista):
    c = {t: 0 for t in range(8)}
    for fila in pista:
        for t in fila:
            c[t] += 1
    return c


def pagina(pistas, nombres, idioma, prefijo):
    out = [CAB[idioma]]
    for n, pista in enumerate(pistas):
        c = cuenta(pista)
        out.append("## %d. %s\n\n" % (n + 1, nombres[n]))
        out.append("![%s](%spista-%02d.png)\n\n" % (nombres[n], prefijo, n + 1))
        out.append(PIE[idioma] % (len(pista), c[0], c[2], c[6], c[7],
                                  c[3] + c[4]))
    return "".join(out)


def main(argv):
    if len(argv) < 3:
        return print(__doc__) or 2
    work, docs = argv[1], argv[2]
    with open(os.path.join(work, "datos.bin"), "rb") as f:
        datos = f.read()[0x9000 - 0x8800:]
    with open(os.path.join(work, "juego.bin"), "rb") as f:
        juego = f.read()
    pistas = G.las_pistas(datos)
    nombres = G.nombres_de_las_pistas(juego)
    for idioma, carpeta, fich, prefijo in (
            ("en", docs, "THE-TRACKS.md", "imagenes/"),
            ("es", os.path.join(docs, "es"), "LAS-PISTAS.md", "../imagenes/")):
        ruta = os.path.join(carpeta, fich)
        with open(ruta, "w", encoding="utf-8") as f:
            f.write(pagina(pistas, nombres, idioma, prefijo))
        print("  %s" % ruta)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

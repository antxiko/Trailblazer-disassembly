#!/usr/bin/env python3
"""Compara lo que dibujamos con la VRAM que el emulador tiene DE VERDAD.

Mirar el dibujo no basta. Las imagenes de este repositorio se montan ejecutando
en Python los pasos de la cinta, y la unica forma de saber si el formato esta
bien leido es coger la VRAM de la maquina -volcada con tools/omsx_carga.tcl- y
restarle la nuestra.

Aqui hay una limitacion que conviene decir en voz alta: **la pista se dibuja
pixel a pixel en marcha**, y la rutina que la pinta se reescribe a si misma
cada fila, asi que la pantalla de juego no se puede montar en Python sin
reimplementar el motor entero. Lo que si se coteja es lo que la cinta trae
hecho y el juego vuelca tal cual: los patrones de sprite.

Uso: coteja.py <dir_work> <dir_volcados>
"""
import os
import sys


def main(argv):
    if len(argv) < 3:
        return print(__doc__) or 2
    work, omsx = argv[1], argv[2]
    with open(os.path.join(work, "juego.bin"), "rb") as f:
        juego = f.read()
    ORG = 0x80E8
    fallos = 0
    print("%-28s %s" % ("que", "bytes distintos"))
    print("-" * 52)
    for que in ("titulo", "juego"):
        ruta = os.path.join(omsx, "vram_%s.bin" % que)
        if not os.path.exists(ruta):
            print("  %-26s (no hay volcado)" % que)
            continue
        with open(ruta, "rb") as f:
            v = f.read()
        # los 0x400 bytes que el arranque vuelca a VRAM 0x3800 (0x80FC)
        d = sum(1 for i in range(0x400)
                if juego[0xBE0E - ORG + i] != v[0x3800 + i])
        print("  patrones de sprite (%-6s) %d/1024" % (que, d))
        fallos += d
    print("-" * 52)
    if fallos:
        print("  %d bytes distintos" % fallos)
        return 1
    print("  OK: cero bytes distintos")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

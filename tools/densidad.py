#!/usr/bin/env python3
"""Cuenta, rutina a rutina, cuantas instrucciones llevan comentario de linea.

Los dos numeros del liston de la serie: la densidad total y cuantas rutinas se
quedan por debajo del 10 %. La segunda pasada de comentarios no se hace a ojo:
primero se mide donde estan los huecos. Una rutina con nombre pero con cero
comentarios esta bautizada, no explicada.

Aqui hay CINCO listados, uno por pieza de cinta, y se miden los cinco juntos:
el liston es del desensamblado entero, no de la pieza que mejor salga.

Uso: densidad.py <dir_src> [minimo_instrucciones]
"""
import os
import re
import sys

PIEZAS = ["cargador", "slots", "portada", "datos", "juego"]


def mide(lineas, minimo):
    """Devuelve (bloques, instrucciones, comentarios, flojas)."""
    bloques, nombre, ini, n, c = [], "(cabecera)", 0, 0, 0
    for ln in lineas:
        m = re.match(r"^([A-Za-z_][A-Za-z_0-9]*):\s*(;.*)?$", ln)
        if m:
            if n:
                bloques.append((nombre, ini, n, c))
            nombre, ini, n, c = m.group(1), 0, 0, 0
            continue
        m = re.match(r"^\t.*;([0-9a-f]{4})(.*)$", ln)
        if not m:
            continue
        if not ini:
            ini = int(m.group(1), 16)
        n += 1
        if ";" in m.group(2):
            c += 1
    if n:
        bloques.append((nombre, ini, n, c))
    flojas = [b for b in bloques if b[2] >= minimo and b[3] * 100 // b[2] < 10]
    return bloques, sum(b[2] for b in bloques), sum(b[3] for b in bloques), flojas


def main(argv):
    src = argv[1] if len(argv) > 1 else "src"
    minimo = int(argv[2]) if len(argv) > 2 else 6
    t_n = t_c = 0
    t_bloques, t_flojas = 0, []
    print("%-10s %8s %8s %8s   %s"
          % ("pieza", "instr", "coment", "rutinas", "densidad"))
    print("-" * 55)
    for p in PIEZAS:
        ruta = os.path.join(src, "trailblazer_%s.asm" % p)
        if not os.path.exists(ruta):
            continue
        with open(ruta, encoding="utf-8") as f:
            bloques, n, c, flojas = mide(f.read().splitlines(), minimo)
        print("%-10s %8d %8d %8d   %6.1f %%"
              % (p, n, c, len(bloques), 100.0 * c / n if n else 0))
        t_n += n
        t_c += c
        t_bloques += len(bloques)
        t_flojas += flojas
    print("-" * 55)
    print("%-10s %8d %8d %8d   %6.1f %%"
          % ("TOTAL", t_n, t_c, t_bloques, 100.0 * t_c / t_n if t_n else 0))
    print()
    for nom, a, n, c in sorted(t_flojas, key=lambda b: -b[2])[:25]:
        print("  %-32s 0x%04X  %4d instr  %3d coment  %2d %%"
              % (nom, a, n, c, c * 100 // n))
    print("  ---- %d rutinas por debajo del 10 %%, de %d"
          % (len(t_flojas), t_bloques))
    print("  ---- en total: %d instrucciones, %d comentarios, %.1f %%"
          % (t_n, t_c, 100.0 * t_c / t_n if t_n else 0))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

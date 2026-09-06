#!/usr/bin/env python3
"""El presupuesto de la cinta: ni un byte sin explicar.

Recorre las cinco piezas y reparte cada byte en una de tres cestas:

  - **codigo**, el que el trazador alcanza desde los puntos de entrada;
  - **datos identificados**, el que cae dentro de una directiva `D` de un
    .notes -o sea, un bloque con nombre y con la medida de la que sale-;
  - **sin explicar**, todo lo demas.

La tercera tiene que llegar a cero. Mientras no llegue, el desensamblado esta
a medias por mucho que el reensamblado cuadre: que los bytes vuelvan a salir no
quiere decir que sepamos que son.

Y ademas cuadra la cuenta con el fichero .cas: los bytes de las cinco piezas
mas los envoltorios -centinelas, cabeceras, sincronismos y relleno- tienen que
dar exactamente el tamano del fichero.

Uso: presupuesto.py <dir_work> <dir_src> <cinta.cas>
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import cinta as C                                          # noqa: E402


def rangos_declarados(notes):
    """Los rangos de las directivas D del .notes, que son los datos con nombre."""
    fuera = []
    if not os.path.exists(notes):
        return fuera
    with open(notes, encoding="utf-8") as f:
        for ln in f:
            m = re.match(r"D\s+(0x[0-9a-fA-F]+)\s+(0x[0-9a-fA-F]+)\s", ln)
            if m:
                fuera.append((int(m.group(1), 16), int(m.group(2), 16)))
    return fuera


def main(argv):
    if len(argv) != 4:
        return print(__doc__) or 2
    work, src, cas = argv[1], argv[2], argv[3]
    _, piezas, _ = C.lee(cas)

    print("%-10s %7s %8s %8s %8s   %s"
          % ("pieza", "bytes", "codigo", "datos", "sin expl", "explicado"))
    print("-" * 70)
    t_bytes = t_cod = t_dat = t_sin = 0
    for n, p in enumerate(piezas):
        nombre = C.NOMBRES[n]
        org, largo = p["carga"], len(p["datos"])
        tr_path = os.path.join(work, "%s.trace.json" % nombre)
        cod = set()
        if os.path.exists(tr_path):
            with open(tr_path, encoding="utf-8") as f:
                tr = json.load(f)
            for k, a, b in tr["blocks"]:
                if k == "c":
                    cod.update(range(a, b))
        dat = set()
        for a, b in rangos_declarados(os.path.join(src, "%s.notes" % nombre)):
            dat.update(range(a, b))
        todos = set(range(org, org + largo))
        ncod = len(todos & cod)
        ndat = len(todos & dat - cod)
        nsin = largo - ncod - ndat
        print("%-10s %7d %8d %8d %8d   %6.2f %%"
              % (nombre, largo, ncod, ndat, nsin,
                 100.0 * (ncod + ndat) / largo))
        t_bytes += largo
        t_cod += ncod
        t_dat += ndat
        t_sin += nsin
    print("-" * 70)
    print("%-10s %7d %8d %8d %8d   %6.2f %%"
          % ("TOTAL", t_bytes, t_cod, t_dat, t_sin,
             100.0 * (t_cod + t_dat) / t_bytes))

    with open(cas, "rb") as f:
        entero = len(f.read())
    envoltorio = entero - t_bytes
    print()
    print("  la cinta son %d bytes: %d de contenido y %d de envoltorio"
          % (entero, t_bytes, envoltorio))
    print("  (centinelas de bloque, cabeceras, sincronismos y relleno)")

    if t_sin:
        print("\n  FALTAN %d bytes por explicar" % t_sin)
        return 1
    print("\n  OK: ni un byte de la cinta sin asignar")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

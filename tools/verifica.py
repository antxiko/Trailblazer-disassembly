#!/usr/bin/env python3
"""Reproducibilidad: ensamblar los listados tiene que devolver la cinta exacta.

Es el criterio que decide si el desensamblado vale. Mientras esto no este en
verde, cualquier cosa que se afirme del juego se afirma a ciegas.

Se hace en dos tiempos:

  1. cada listado ensambla y da exactamente la pieza de cinta que le toca;
  2. envolviendo esas piezas como las envuelve el .cas -el centinela de ocho
     bytes alineado, la cabecera BIN del MSX para la primera, las cabeceritas
     de ocho del cargador propio para las otras cuatro, el byte 0xFF de
     sincronismo y el relleno de alineacion- sale el .cas ENTERO, con su
     sha256.

El segundo paso es el que cierra el circulo: el primero solo dice que los
listados son consistentes con lo que les hemos dado de comer, y el segundo que
lo que les hemos dado de comer es la cinta.

Uso: verifica.py <dir_src> <dir_work> <cinta.cas>
"""
import hashlib
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import cinta as C                                          # noqa: E402

PASMO = r"C:/Users/Antxiko/AppData/Local/Programs/pasmo/pasmo.exe"


def ensambla(asm, out, work):
    """pasmo, con TMP dentro del proyecto: el de Windows no le vale."""
    exe = PASMO if os.path.exists(PASMO) else "pasmo"
    env = dict(os.environ, TMP=work, TEMP=work)
    r = subprocess.run([exe, "--bin", asm, out], capture_output=True,
                       text=True, env=env)
    return r.returncode, (r.stderr or r.stdout)


def main(argv):
    if len(argv) != 4:
        return print(__doc__) or 2
    src, work, cas = argv[1], argv[2], argv[3]
    os.makedirs(work, exist_ok=True)
    with open(cas, "rb") as f:
        original = f.read()
    _, piezas, _ = C.lee(cas)
    fallos = 0

    print("=" * 70)
    print(" 1) cada listado ensambla y da su pieza de cinta, byte a byte")
    print("=" * 70)
    for n, p in enumerate(piezas):
        nombre = C.NOMBRES[n]
        asm = os.path.join(src, "trailblazer_%s.asm" % nombre)
        if not os.path.exists(asm):
            print("  %-10s (aun no hay listado)" % nombre)
            fallos += 1
            continue
        out = os.path.join(work, "%s.pasmo.bin" % nombre)
        rc, err = ensambla(asm, out, work)
        if rc:
            print("  %-10s FALLO: pasmo no ensambla" % nombre)
            for ln in err.splitlines()[:8]:
                print("      %s" % ln)
            fallos += 1
            continue
        with open(out, "rb") as f:
            hecho = f.read()
        ref = p["datos"]
        if hecho == ref:
            print("  %-10s OK  %6d bytes  carga 0x%04X"
                  % (nombre, len(ref), p["carga"]))
            p["datos"] = hecho
        else:
            print("  %-10s DISTINTO: %d bytes ensamblados, %d esperados"
                  % (nombre, len(hecho), len(ref)))
            for k in range(min(len(hecho), len(ref))):
                if hecho[k] != ref[k]:
                    print("      primera diferencia en +0x%04X (0x%04X): "
                          "%02X vs %02X"
                          % (k, p["carga"] + k, hecho[k], ref[k]))
                    break
            fallos += 1

    print()
    print("=" * 70)
    print(" 2) y envolviendolas como las envuelve el .cas, sale la cinta")
    print("=" * 70)
    rehecha = C.monta(piezas)
    sha = hashlib.sha256(rehecha).hexdigest()
    print("  rehecha   %6d bytes  %s" % (len(rehecha), sha))
    print("  original  %6d bytes  %s"
          % (len(original), hashlib.sha256(original).hexdigest()))
    if rehecha == original:
        print("\n  OK: la cinta se reproduce byte a byte")
    else:
        print("\n  FALLO: la cinta rehecha no es la original")
        fallos += 1
    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

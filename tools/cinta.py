#!/usr/bin/env python3
"""La cinta de Trailblazer: como esta hecha y como se vuelve a montar.

Un `.cas` no guarda la modulacion: guarda los BYTES que el MSX habria leido, y
marca donde empieza cada bloque con un centinela de ocho bytes,
`1F A6 DE BA CC 13 7D 74`, SIEMPRE alineado a multiplo de 8.

Esta cinta tiene DOS capas, y esa es toda la gracia:

  1. La de fuera es la del MSX: el primer bloque es una cabecera BIN de las de
     siempre -diez bytes 0xD0 y seis de nombre, 'Trail!'- y el segundo su
     cuerpo, que se carga en 0xD800 y se ejecuta ahi. Eso es lo unico que carga
     el BIOS a su manera.
  2. La de dentro se la inventa el juego. Los ocho bloques que quedan NO llevan
     cabecera de MSX: van de dos en dos, y el primero de cada pareja es una
     cabecerita de ocho bytes que se lee asi:

         0xFE  direccion de carga (2, LE)  longitud (2, LE)  suma  00 00

     Y el segundo empieza por otro byte suelto, 0xFF, antes del contenido.

**ESOS DOS BYTES NO SON DATOS: SON EL SINCRONISMO.** El cargador de 0xD800
entra en su rutina de lectura con el byte que espera ya en el acumulador -`ld
a,0feh` en 0xD80D para la cabecerita y `ld a,0ffh` en 0xD81D para el cuerpo- y
no empieza a guardar hasta haberlo visto (0xD87D). Ademas la cabecerita se lee
pidiendo CUATRO bytes exactos a 0xD8ED (`ld de,00004h`), asi que de los ocho
del bloque solo cuentan la direccion y la longitud; el quinto es la suma de
control y los dos ultimos, relleno.

Cuadra a la perfeccion, y es lo que confirma la lectura: cada bloque de cuerpo
mide **1 + longitud + relleno**, y el relleno es justo lo que hace falta para
que el centinela siguiente caiga en multiplo de ocho.

    cabecera            se carga en        y ocupa
    FE 00 90 01 01 6E   0x9000..0x9100       257 bytes   (payload 264 = 1+257+6)
    FE 00 88 01 1C 6B   0x8800..0xA400      7169 bytes   (payload 7176)
    FE 00 88 00 28 5E   0x8800..0xAFFF     10240 bytes   (payload 10248)
    FE E8 80 18 4F C1   0x80E8..0xCFFF     20248 bytes   (payload 20250)

Sin descontar ese byte, la primera pieza empieza por un `rst 38h` que no pinta
nada; descontandolo empieza por `di`, que es lo que tiene que hacer.

Uso:  cinta.py <cinta.cas> [directorio_salida]
"""
import hashlib
import json
import os
import struct
import sys

MARCA = bytes.fromhex("1FA6DEBACC137D74")
MSX_HDR = {0xD3: "BASIC", 0xD0: "BIN", 0xEA: "ASCII"}
SINCRO = 0xFE

# El nombre de cada pieza, en el orden en que estan en la cinta. No es una
# etiqueta: es lo que cada una hace, medido leyendola.
#
#   cargador  el que carga las otras cuatro. No se hace su propia lectura de
#             cinta: monta en la PILA un puente de seis instrucciones que
#             conmuta la ranura, llama a TAPIN del BIOS y la devuelve
#   slots     recorre los slots probando a escribir en 0x4000 hasta dar con la
#             RAM, y deja el que sirve en 0xFFFE
#   portada   la pantalla que se ve mientras carga el resto
#   datos     los textos y las pistas; se copia a si mismo 8 KB a 0x6000
#   juego     el juego, que arranca en 0x80E8
NOMBRES = ["cargador", "slots", "portada", "datos", "juego"]


def u16(b, o):
    return struct.unpack_from("<H", b, o)[0]


def trocea(d):
    """Corta el .cas por el centinela alineado a 8: (offset, payload)."""
    pos, sueltas = [], 0
    i = 0
    while True:
        i = d.find(MARCA, i)
        if i < 0:
            break
        if i % 8 == 0:
            pos.append(i)
        else:
            sueltas += 1          # la misma secuencia dentro de los datos
        i += 1
    if not pos:
        sys.exit("no es un .cas: no aparece el centinela de bloque")
    trozos = []
    for k, p in enumerate(pos):
        fin = pos[k + 1] if k + 1 < len(pos) else len(d)
        trozos.append((p, d[p + 8:fin]))
    return trozos, sueltas


def lee(path):
    """El inventario de la cinta, con las dos capas ya separadas."""
    with open(path, "rb") as f:
        d = f.read()
    trozos, sueltas = trocea(d)
    piezas, i = [], 0
    while i < len(trozos):
        off, pl = trozos[i]
        if (len(pl) >= 16 and pl[0] in MSX_HDR
                and pl[:10] == bytes([pl[0]]) * 10):
            # la capa del MSX: cabecera + cuerpo
            nombre = pl[10:16].decode("latin-1")
            off2, cuerpo = trozos[i + 1]
            ld, end, exe = u16(cuerpo, 0), u16(cuerpo, 2), u16(cuerpo, 4)
            largo = end - ld + 1
            piezas.append(dict(clase="MSX", nombre=nombre, bloques=[i, i + 1],
                               off=off, off_cuerpo=off2, carga=ld, fin=end,
                               ejecuta=exe, largo=largo,
                               datos=cuerpo[6:6 + largo],
                               relleno=cuerpo[6 + largo:]))
            i += 2
        elif len(pl) == 8 and pl[0] == SINCRO:
            # la capa del juego: cabecerita de ocho + cuerpo
            carga, largo, suma = u16(pl, 1), u16(pl, 3), pl[5]
            off2, cuerpo = trozos[i + 1]
            # cuerpo[0] es el 0xFF de sincronismo, y NO es dato
            piezas.append(dict(clase="JUEGO", nombre="%04X" % carga,
                               bloques=[i, i + 1], off=off, off_cuerpo=off2,
                               carga=carga, largo=largo, suma=suma,
                               cabecera=pl, sincro=cuerpo[:1],
                               datos=cuerpo[1:1 + largo],
                               relleno=cuerpo[1 + largo:]))
            i += 2
        else:
            piezas.append(dict(clase="SUELTO", nombre="blk%02d" % i,
                               bloques=[i], off=off, datos=pl, relleno=b""))
            i += 1
    return d, piezas, sueltas


def monta(piezas):
    """Rehace el .cas entero desde las piezas. Es la prueba de que el modelo
    de la cinta es el bueno: si sobra o falta un byte, el sha256 no cuadra."""
    fuera = bytearray()
    for p in piezas:
        if p["clase"] == "MSX":
            fuera += MARCA
            fuera += bytes([0xD0]) * 10 + p["nombre"].encode("latin-1")
            fuera += MARCA
            fuera += struct.pack("<HHH", p["carga"], p["fin"], p["ejecuta"])
            fuera += p["datos"] + p["relleno"]
        elif p["clase"] == "JUEGO":
            fuera += MARCA + p["cabecera"]
            fuera += MARCA + p["sincro"] + p["datos"] + p["relleno"]
        else:
            fuera += MARCA + p["datos"] + p["relleno"]
    return bytes(fuera)


def main(argv):
    if len(argv) < 2:
        return print(__doc__) or 2
    d, piezas, sueltas = lee(argv[1])
    print("# CAS  %s  %d bytes" % (os.path.basename(argv[1]), len(d)))
    if sueltas:
        print("# %d apariciones del centinela DESALINEADAS: son datos, no "
              "separadores" % sueltas)
    print()
    print("%-6s %-8s %-8s %8s %8s  %s"
          % ("capa", "nombre", "carga", "bytes", "relleno", "bloques"))
    print("-" * 66)
    total = 0
    for p in piezas:
        print("%-6s %-8s %-8s %8d %8d  %s"
              % (p["clase"], p["nombre"],
                 "0x%04X" % p["carga"] if "carga" in p else "-",
                 len(p["datos"]), len(p["relleno"]),
                 ",".join(str(b) for b in p["bloques"])))
        total += len(p["datos"])
    print("-" * 66)
    print("  %d bytes de contenido en %d piezas" % (total, len(piezas)))

    rehecha = monta(piezas)
    igual = rehecha == d
    print("\n  se vuelve a montar: %s" % ("SI, byte a byte" if igual else "NO"))
    if not igual:
        print("    original %d bytes  sha %s" % (len(d),
                                                 hashlib.sha256(d).hexdigest()[:16]))
        print("    rehecha  %d bytes  sha %s"
              % (len(rehecha), hashlib.sha256(rehecha).hexdigest()[:16]))
        for k in range(min(len(d), len(rehecha))):
            if d[k] != rehecha[k]:
                print("    primera diferencia en 0x%04X: %02X vs %02X"
                      % (k, d[k], rehecha[k]))
                break
        return 1

    if len(argv) > 2:
        out = argv[2]
        os.makedirs(out, exist_ok=True)
        inv = []
        # cada pieza sale con SU nombre. Hace falta: dos de ellas cargan en la
        # misma direccion, 0x8800, y por direccion se pisarian el fichero
        for n, p in enumerate(piezas):
            fn = "%s.bin" % NOMBRES[n]
            with open(os.path.join(out, fn), "wb") as f:
                f.write(p["datos"])
            e = {k: v for k, v in p.items()
                 if k not in ("datos", "relleno", "cabecera", "sincro")}
            e["fichero"] = fn
            e["relleno"] = len(p["relleno"])
            inv.append(e)
            print("  -> %s/%s  (%d bytes)" % (out, fn, len(p["datos"])))
        with open(os.path.join(out, "inventario.json"), "w",
                  encoding="utf-8") as f:
            json.dump(inv, f, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

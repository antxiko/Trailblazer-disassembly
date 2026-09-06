#!/usr/bin/env python3
"""Dibuja las pantallas de Trailblazer ejecutando los pasos del propio juego.

En este repositorio no hay ni una captura de pantalla. Todo lo que se ve sale
de aqui: se monta la VRAM haciendo lo mismo que hace el Z80 -descomprimir los
guiones, estirar el color, volcar los patrones- y luego se pinta lo que esa
VRAM dice.

La geometria es la normal de SCREEN 2, y no esta supuesta: se leyo de los
registros del VDP de la maquina (tools/omsx_carga.tcl vuelca los ocho).

    R2 = 0x06   nombres             en 0x1800
    R3 = 0xFF   colores   base 0x2000, mascara 0x1FFF
    R4 = 0x03   patrones  base 0x0000, mascara 0x1FFF
    R5 = 0x36   atributos de sprite en 0x1B00
    R6 = 0x07   patrones de sprite  en 0x3800

Uso: graficos.py <dir_work> <dir_salida>
"""
import os
import struct
import sys
import zlib

# Los quince colores del MSX1 mas el transparente, en RGB, tal como los da la
# documentacion del TMS9918 de Texas Instruments.
PALETA = [
    (0, 0, 0), (0, 0, 0), (33, 200, 66), (94, 220, 120),
    (84, 85, 237), (125, 118, 252), (212, 82, 77), (66, 235, 245),
    (252, 85, 84), (255, 121, 120), (212, 193, 84), (230, 206, 128),
    (33, 176, 59), (201, 91, 186), (204, 204, 204), (255, 255, 255),
]

PATRONES, NOMBRES, COLORES, SPR_PAT = 0x0000, 0x1800, 0x2000, 0x3800


def png(ruta, px, escala=2):
    """Escribe un PNG sin depender de ninguna biblioteca."""
    alto, ancho = len(px) * escala, len(px[0]) * escala
    crudo = bytearray()
    for f in px:
        fila = bytearray()
        for p in f:
            fila += bytes(p) * escala
        for _ in range(escala):
            crudo += b"\x00" + fila

    def trozo(tipo, datos):
        return (struct.pack(">I", len(datos)) + tipo + datos
                + struct.pack(">I", zlib.crc32(tipo + datos) & 0xFFFFFFFF))

    with open(ruta, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        f.write(trozo(b"IHDR",
                      struct.pack(">IIBBBBB", ancho, alto, 8, 2, 0, 0, 0)))
        f.write(trozo(b"IDAT", zlib.compress(bytes(crudo), 9)))
        f.write(trozo(b"IEND", b""))


def pinta(v, fondo=(0, 0, 0)):
    """Las 24x32 casillas de la pantalla, con sus tres bancos de color."""
    px = [[fondo] * 256 for _ in range(192)]
    for f in range(24):
        b = f // 8
        for c in range(32):
            t = v[NOMBRES + f * 32 + c]
            for y in range(8):
                forma = v[PATRONES + b * 0x800 + t * 8 + y]
                col = v[COLORES + b * 0x800 + t * 8 + y]
                tinta = PALETA[col >> 4] if col >> 4 else fondo
                papel = PALETA[col & 0x0F] if col & 0x0F else fondo
                for x in range(8):
                    px[f * 8 + y][c * 8 + x] = (tinta if forma & (0x80 >> x)
                                                else papel)
    return px


# ---------------------------------------------------------------- la portada
# 0x88AC y 0x88B4: la paleta de ocho colores, una copia en el nibble alto para
# la tinta y otra en el bajo para el papel.
def monta_la_portada(portada):
    """Traduce 0x8800 y 0x8831: la pantalla que se ve mientras carga el resto.

    Los 0x1800 bytes de patrones van literales, y los 0x300 de color se
    ESTIRAN: cada byte vale para las ocho filas de un patron, y lleva dentro
    los dos colores en tres bits cada uno. Ocho a uno.
    """
    ORG = 0x8800
    v = bytearray(0x4000)
    # LOS PATRONES VAN TRANSPUESTOS. El bucle de 0x8855 lee ocho bytes con
    # `inc h`, o sea saltando de 256 en 256, y luego `pop hl / inc l` pasa al
    # patron siguiente. Asi que en la RAM el byte (0x4000 + fila*0x100 + patron)
    # es la fila `fila` del patron `patron`, no las ocho filas seguidas. Y cada
    # 0x800 empieza otra banda de la pantalla (`add a,008h` de 0x8866).
    for banda in range(3):
        for p in range(256):
            for y in range(8):
                v[PATRONES + banda * 0x800 + p * 8 + y] = \
                    portada[0x8900 - ORG + banda * 0x800 + y * 0x100 + p]
    tinta = portada[0x88AC - ORG:0x88B4 - ORG]      # nibble alto
    papel = portada[0x88B4 - ORG:0x88BC - ORG]      # nibble bajo
    for i in range(0x300):
        b = portada[0xA100 - ORG + i]
        col = tinta[b & 0x07] | papel[(b >> 3) & 0x07]
        for y in range(8):
            v[COLORES + i * 8 + y] = col
    # La tabla de nombres de la portada no viene en la pieza: la pantalla es la
    # rejilla entera, casilla 0 arriba a la izquierda y de ahi seguido, que es
    # lo que hace el recorrido de 0x8852 (`inc l` por columnas, `add a,008h`
    # por bandas de ocho).
    for f in range(24):
        for c in range(32):
            v[NOMBRES + f * 32 + c] = (f % 8) * 32 + c
    return v


# ------------------------------------------------------------------ la pista
# Los ocho tipos de casilla, con lo que hace cada uno. No es una interpretacion:
# sale del despachador de 0x8E65, que compara la casilla contra estos valores.
TIPOS = {
    0: ("agujero", (0, 0, 0)),
    1: ("pista", (84, 85, 237)),
    2: ("acelera", (33, 200, 66)),
    3: ("mandos al reves", (212, 193, 84)),
    4: ("mandos al reves", (230, 206, 128)),
    5: ("pista", (125, 118, 252)),
    6: ("frena", (212, 82, 77)),
    7: ("rebota", (255, 255, 255)),
}


def las_pistas(datos):
    """Las catorce pistas, cada una como una lista de filas de cinco casillas.

    El formato, sacado del codigo y comprobado contra la RAM del emulador:

      - la pieza `datos` de la cinta lleva 0x2000 bytes a la RAM en 0x6000;
      - **los ultimos 0x800 son la tabla de FILAS**: cinco casillas por fila,
        una detras de otra, y ahi es donde 0x8BB9 va a buscar con
        `fila*5 + 0x7800`;
      - **los 0x1800 primeros son las catorce pistas**, y cada una es una lista
        de INDICES a esa tabla, cerrada con 0xFF. Lo dice el bucle de 0x93A4,
        que avanza pista a pista buscando el 0xFF.

    O sea que una pista de 219 filas ocupa 219 bytes, no 1095: las filas se
    repiten y basta con nombrarlas.
    """
    tabla = datos[0x1800:]
    pistas, cur = [], []
    for b in datos[:0x1800]:
        if b == 0xFF:
            if cur:
                pistas.append(cur)
            cur = []
        else:
            cur.append(b)
    if cur:
        pistas.append(cur)
    # la ultima es el relleno de ceros que queda detras de la catorce
    pistas = pistas[:14]
    return [[[tabla[i * 5 + c] & 7 for c in range(5)] for i in p]
            for p in pistas]


def dibuja_una_pista(pista, ancho=3, alto=8):
    """La pista TUMBADA: la salida a la izquierda y la meta a la derecha.

    En el juego se recorre de abajo arriba, pero puesta asi -219 filas de
    largo por cinco casillas de ancho- se lee de un vistazo y cabe en una
    pagina. Cada columna de la imagen es una fila de la pista.
    """
    px = [[(0, 0, 0)] * (ancho * len(pista)) for _ in range(alto * 5)]
    for f, fila in enumerate(pista):
        for c, t in enumerate(fila):
            col = TIPOS[t][1]
            for y in range(alto):
                for x in range(ancho):
                    px[c * alto + y][f * ancho + x] = col
    return px


# Los catorce nombres, sacados del propio cartucho: la lista de 0xA4CB, con el
# final de cada cadena marcado en el bit 7.
def nombres_de_las_pistas(juego, org=0x80E8):
    fuera, cur, a = [], "", 0xA4CB
    while a < 0xA5AF:
        b = juego[a - org]
        cur += chr(b & 0x7F)
        if b & 0x80:
            fuera.append(cur.strip())
            cur = ""
        a += 1
    return fuera


def hoja_de_caracteres(juego, org=0x80E8, cols=32):
    """La fuente del juego: 0xBB25..0xBE0E, ocho bytes por caracter.

    Es la hoja que el arranque deja en (0xA41E), el puntero que usa la rutina
    de texto de 0x97D3.
    """
    d = juego[0xBB25 - org:0xBE0E - org]
    n = len(d) // 8
    filas = (n + cols - 1) // cols
    px = [[(0, 0, 0)] * (cols * 8) for _ in range(filas * 8)]
    for c in range(n):
        r, k = c // cols, c % cols
        for y in range(8):
            b = d[c * 8 + y]
            for x in range(8):
                if b & (0x80 >> x):
                    px[r * 8 + y][k * 8 + x] = (255, 255, 255)
    return px


def patrones_de_sprite(juego, org=0x80E8, cols=8):
    """Los 0x400 bytes que el arranque vuelca a VRAM 0x3800 (0x80FC).

    Con sprites de 16x16 -lo dice el registro 1, que vale 0xE2- son treinta y
    dos figuras de 32 bytes. Cotejadas contra la VRAM de openMSX: CERO bytes
    distintos.
    """
    d = juego[0xBE0E - org:0xC20E - org]
    n = len(d) // 32
    filas = (n + cols - 1) // cols
    px = [[(0, 0, 0)] * (cols * 17) for _ in range(filas * 17)]
    for s in range(n):
        r, k = s // cols, s % cols
        for y in range(16):
            for mitad in range(2):
                b = d[s * 32 + mitad * 16 + y]
                for x in range(8):
                    if b & (0x80 >> x):
                        px[r * 17 + y][k * 17 + mitad * 8 + x] = (255, 255, 255)
    return px


def hoja_de_filas(datos, cuantas=176, ancho=6, alto=6):
    """Las filas de pista distintas que hay en la tabla de 0x7800.

    Las catorce pistas no guardan casillas: guardan INDICES a esta tabla. Aqui
    estan las que se usan, una debajo de otra, con los mismos colores que los
    mapas.
    """
    tabla = datos[0x1800:]
    px = [[(0, 0, 0)] * (ancho * 5) for _ in range(alto * cuantas)]
    for f in range(cuantas):
        for c in range(5):
            col = TIPOS[tabla[f * 5 + c] & 7][1]
            for y in range(alto):
                for x in range(ancho):
                    px[f * alto + y][c * ancho + x] = col
    return px


def main(argv):
    if len(argv) < 3:
        return print(__doc__) or 2
    work, salida = argv[1], argv[2]
    os.makedirs(salida, exist_ok=True)
    with open(os.path.join(work, "portada.bin"), "rb") as f:
        portada = f.read()
    png(os.path.join(salida, "portada.png"), pinta(monta_la_portada(portada)))
    print("  portada.png")

    with open(os.path.join(work, "datos.bin"), "rb") as f:
        datos = f.read()[0x9000 - 0x8800:]      # los 0x2000 que van a 0x6000
    with open(os.path.join(work, "juego.bin"), "rb") as f:
        juego = f.read()
    png(os.path.join(salida, "fuente.png"), hoja_de_caracteres(juego))
    png(os.path.join(salida, "sprites.png"), patrones_de_sprite(juego))
    png(os.path.join(salida, "filas.png"), hoja_de_filas(datos), escala=1)
    print("  fuente.png, sprites.png y filas.png")
    nombres = nombres_de_las_pistas(juego)
    for n, pista in enumerate(las_pistas(datos)):
        png(os.path.join(salida, "pista-%02d.png" % (n + 1)),
            dibuja_una_pista(pista), escala=1)
        print("  pista-%02d.png  %4d filas  %s"
              % (n + 1, len(pista), nombres[n] if n < len(nombres) else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))

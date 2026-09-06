#!/usr/bin/env python3
"""Comprobaciones sobre el desensamblado de Trailblazer, y sobre lo que afirma.

Ninguna necesita la cinta. Las que miran bytes los sacan de los `defb` de los
propios listados, que es lo mismo que hay en el .cas -eso lo garantiza
`make verify`, que reensambla las cinco piezas, las vuelve a envolver y compara
el sha256-.

Lo que se vigila:

  - que el listado no se degrade sin que nadie se entere: densidad, rutinas sin
    explicar, bloques de datos sin descripcion;
  - que las afirmaciones que se publican SE COMPRUEBEN sobre los bytes. Los
    creditos tienen que decir lo que decimos que dicen; los catorce nombres de
    pista tienen que estar; las catorce pistas tienen que recorrerse enteras y
    cerrar por el 0xFF; sus indices tienen que caber en la tabla de filas; las
    curvas de salto tienen que bajar y volver a subir; y la paleta del juego
    tiene que ser la misma que la de la pantalla de carga;
  - que no se cuele el nombre de otro juego de la serie, que ya ha pasado.
"""
import os
import re
import sys
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCS = os.path.join(RAIZ, "docs")
PIEZAS = ("cargador", "slots", "portada", "datos", "juego")
ORG = {"cargador": 0xD800, "slots": 0x9000, "portada": 0x8800,
       "datos": 0x8800, "juego": 0x80E8}

sys.path.insert(0, os.path.join(RAIZ, "tools"))

# Los demas juegos de la serie. Que el nombre de otro salga en una pagina de
# este es casi siempre un copia y pega: ya paso con cinco ficheros LICENSE, con
# el pie de catorce paginas de otro proyecto, con los tests de Hyper Sports 3
# -que llegaron apuntando a src/soccer.asm- y con un `src/tennis.asm` que se
# colo en los dos avisos legales de The Goonies.
OTROS_JUEGOS = (
    "Tennis", "Pitfall", "Temptations", "Stardust", "Ale Hop", "Colt 36",
    "Antarctic", "Athletic Land", "Monkey Academy", "F-1 Spirit", "Pippols",
    "Billiards", "Mahjong", "Super Cobra", "Frogger", "Hyper Olympic",
    "Demonia", "Hyper Rally", "Nemesis", "Sky Jaguar", "Cabbage Patch",
    "Hyper Sports", "Baseball", "Yie Ar Kung-Fu", "Mopi Ranger", "Time Pilot",
    "King's Valley", "Road Fighter", "Ping Pong", "Soccer", "Football",
    "The Goonies", "Goonies", "Hole in One", "Casio World Open", "3D Golf",
    "War in Middle Earth", "El Descubrimiento",
)
OTROS_FICHEROS = ("soccer", "hypersports", "roadfighter", "pingpong",
                  "mopiranger", "tennis", "baseball", "nemesis", "pippols",
                  "antarctic", "goonies", "golf", "frogger", "kingsvalley",
                  "descubrimiento")


def lee(ruta):
    with open(ruta, encoding="utf-8") as f:
        return f.read()


def asm(pieza):
    return os.path.join(RAIZ, "src", "trailblazer_%s.asm" % pieza)


def bytes_de_los_defb(pieza):
    """Reconstruye los datos de una pieza leyendo los `defb` de su listado.

    Cada linea de datos acaba en un comentario con su direccion, asi que se
    puede volver a montar el trozo de cinta sin tenerla delante.
    """
    fuera = {}
    for ln in lee(asm(pieza)).splitlines():
        m = re.match(r"^\tdef[bw] (.*?)\t*; ?([0-9a-f]{4})", ln)
        if not m:
            continue
        dire = int(m.group(2), 16)
        vals = []
        for tr in m.group(1).split(","):
            tr = tr.strip()
            if not tr:
                continue
            v = int(tr[:-1], 16) if tr.endswith("h") else int(tr, 0)
            if ln.lstrip().startswith("defw"):
                vals += [v & 0xFF, v >> 8]
            else:
                vals.append(v & 0xFF)
        for i, v in enumerate(vals):
            fuera[dire + i] = v
    return fuera


DATOS = {p: bytes_de_los_defb(p) for p in PIEZAS}


def trozo(pieza, dire, n):
    """n bytes seguidos desde una direccion, sacados de los `defb`."""
    fuera = []
    for k in range(n):
        if dire + k not in DATOS[pieza]:
            raise AssertionError("0x%04X no esta en los datos de %s"
                                 % (dire + k, pieza))
        fuera.append(DATOS[pieza][dire + k])
    return fuera


def texto(bs):
    """Las cadenas del juego llevan el final en el bit 7 de la ultima letra."""
    return "".join(chr(b & 0x7F) for b in bs)


class TestListado(unittest.TestCase):
    """Que el listado siga siendo el que se publica."""

    def test_las_cinco_piezas_tienen_listado(self):
        for p in PIEZAS:
            self.assertTrue(os.path.exists(asm(p)), "falta el listado de %s" % p)

    def test_cada_listado_declara_su_direccion_de_carga(self):
        for p in PIEZAS:
            m = re.search(r"^\torg 0x0?([0-9a-f]{4})", lee(asm(p)), re.M)
            self.assertIsNotNone(m, "el listado de %s no declara org" % p)
            self.assertEqual(int(m.group(1), 16), ORG[p])

    def test_todas_las_instrucciones_llevan_su_direccion(self):
        for p in PIEZAS:
            for ln in lee(asm(p)).splitlines():
                s = ln.lstrip()
                if ln.startswith("\t") and not s.startswith(("def", ";", "org")):
                    self.assertRegex(ln, r";[0-9a-f]{4}",
                                     "en %s: %r" % (p, ln))

    def test_densidad_por_encima_del_liston(self):
        import subprocess
        r = subprocess.run([sys.executable,
                            os.path.join(RAIZ, "tools", "densidad.py"),
                            os.path.join(RAIZ, "src")],
                           capture_output=True, text=True, check=True)
        m = re.search(r"(\d+) instrucciones, (\d+) comentarios", r.stdout)
        self.assertIsNotNone(m, r.stdout)
        n, c = int(m.group(1)), int(m.group(2))
        self.assertGreaterEqual(100.0 * c / n, 30.0,
                                "la densidad ha bajado del 30 %%")

    def test_ninguna_rutina_por_debajo_del_diez_por_ciento(self):
        import subprocess
        r = subprocess.run([sys.executable,
                            os.path.join(RAIZ, "tools", "densidad.py"),
                            os.path.join(RAIZ, "src")],
                           capture_output=True, text=True, check=True)
        m = re.search(r"(\d+) rutinas por debajo del 10 %", r.stdout)
        self.assertIsNotNone(m)
        self.assertEqual(int(m.group(1)), 0, "han vuelto a salir rutinas flojas")

    def test_todos_los_bloques_llevan_nombre_y_explicacion(self):
        for p in PIEZAS:
            for m in re.finditer(r"^D (0x[0-9a-f]+) (0x[0-9a-f]+) (\S+)(.*)$",
                                 lee(os.path.join(RAIZ, "src", "%s.notes" % p)),
                                 re.M):
                self.assertGreater(len(m.group(4).strip()), 20,
                                   "el bloque %s de %s no esta explicado"
                                   % (m.group(3), p))

    def test_ningun_bloque_se_llama_por_su_direccion(self):
        for p in PIEZAS:
            for m in re.finditer(r"^D 0x[0-9a-f]+ 0x[0-9a-f]+ (\S+)",
                                 lee(os.path.join(RAIZ, "src", "%s.notes" % p)),
                                 re.M):
                self.assertNotRegex(m.group(1), r"^(DATA_|tabla_de_)?[0-9a-fA-F]{4}$",
                                    "en %s" % p)


class TestLaCinta(unittest.TestCase):
    """El modelo de la cinta, que es lo que hace posible todo lo demas."""

    def test_las_cabeceritas_dicen_las_direcciones_de_carga(self):
        """Los ocho bytes de cada cabecerita: 0xFE, carga, largo, suma, 00 00."""
        esperado = [(0x9000, 257), (0x8800, 7169), (0x8800, 10240),
                    (0x80E8, 20248)]
        for carga, largo in esperado:
            self.assertGreater(largo, 0)
            self.assertLessEqual(carga + largo, 0x10000,
                                 "la pieza de 0x%04X se sale de la memoria"
                                 % carga)

    def test_las_piezas_no_se_pisan_lo_que_les_importa(self):
        """`portada` y `datos` cargan las dos en 0x8800, y el juego encima.

        Lo que sobrevive de `datos` son sus 0x2000 bytes de arriba, que se
        copian a 0x6000 antes de que nadie los pise.
        """
        self.assertEqual(ORG["portada"], ORG["datos"])
        self.assertLess(ORG["juego"], 0x8800)
        self.assertGreater(ORG["juego"] + 20248, 0x9000)


class TestLosCreditos(unittest.TestCase):
    """El rotulo que desfila da los creditos, y se publican. Se comprueban."""

    def setUp(self):
        self.rotulo = texto(trozo("juego", 0x9E69, 0xA29E - 0x9E69))

    def test_dice_de_quien_es_el_original(self):
        self.assertIn("(c) Mr Chip 1986", self.rotulo)
        self.assertIn("Originally created by Shaun Southern on the Commodore",
                      self.rotulo)

    def test_da_los_cinco_nombres_de_gremlin(self):
        for quien in ("SHAUN HOLLINGWORTH", "COLIN DOOLEY", "PETER HARRAP",
                      "CHRIS KERRY", "GREG HOLMES"):
            self.assertIn(quien, self.rotulo)
        self.assertIn("Gremlin Graphics Software Limited", self.rotulo)

    def test_da_las_teclas(self):
        self.assertIn("Q-Left,W-right,P-Up,L-Down and Space to jump",
                      self.rotulo)

    def test_cierra_con_0xff(self):
        self.assertEqual(trozo("juego", 0xA29D, 1), [0xFF])


class TestLasPistas(unittest.TestCase):
    """Catorce pistas, y cada una una lista de indices a la tabla de filas."""

    def setUp(self):
        # los 0x2000 bytes que la pieza `datos` lleva a 0x6000
        crudo = bytes(trozo("datos", 0x9000, 0x2000))
        self.tabla = crudo[0x1800:]
        self.pistas, cur = [], []
        for b in crudo[:0x1800]:
            if b == 0xFF:
                if cur:
                    self.pistas.append(cur)
                cur = []
            else:
                cur.append(b)
        if cur:
            self.pistas.append(cur)

    def test_son_catorce_pistas(self):
        """Detras de la catorce queda el relleno, que no es una pista: son
        miles de bytes de un solo valor repetido."""
        buenas = [p for p in self.pistas if 100 < len(p) < 1000]
        self.assertEqual(len(buenas), 14)

    def test_ningun_indice_se_sale_de_la_tabla_de_filas(self):
        """La tabla son 0x800 bytes de cinco en cinco: 409 filas."""
        for n, p in enumerate(self.pistas[:14]):
            for i in p:
                self.assertLess(i * 5 + 4, len(self.tabla),
                                "la pista %d apunta a la fila %d, que no existe"
                                % (n + 1, i))

    def test_todas_las_casillas_son_de_los_ocho_tipos(self):
        """El despachador de 0x8E65 solo entiende los valores 0 a 7."""
        for n, p in enumerate(self.pistas[:14]):
            for i in p:
                for c in range(5):
                    self.assertLess(self.tabla[i * 5 + c], 8,
                                    "la pista %d trae una casilla que el "
                                    "motor no sabe leer" % (n + 1))

    def test_ninguna_pista_esta_vacia(self):
        for n, p in enumerate(self.pistas[:14]):
            self.assertGreater(len(p), 100,
                               "la pista %d tiene %d filas" % (n + 1, len(p)))

    def test_las_pistas_van_de_mas_facil_a_mas_dificil(self):
        """No en longitud, pero SI en agujeros: la primera casi no tiene."""
        def agujeros(p):
            return sum(1 for i in p for c in range(5)
                       if self.tabla[i * 5 + c] == 0)
        primera = agujeros(self.pistas[0]) / len(self.pistas[0])
        ultima = agujeros(self.pistas[13]) / len(self.pistas[13])
        self.assertLess(primera, ultima,
                        "la primera pista tiene mas agujeros por fila que la "
                        "ultima, y se publica lo contrario")


class TestLosNombresDeLasPistas(unittest.TestCase):
    """Catorce nombres, y llevan el nombre de los programadores."""

    def setUp(self):
        self.nombres, cur = [], ""
        for a in range(0xA4CB, 0xA5AF):
            b = trozo("juego", a, 1)[0]
            cur += chr(b & 0x7F)
            if b & 0x80:
                self.nombres.append(cur.strip())
                cur = ""

    def test_son_catorce(self):
        self.assertEqual(len(self.nombres), 14)

    def test_el_primero_es_easy_going(self):
        self.assertEqual(self.nombres[0], "EASY GOING")

    def test_el_ultimo_es_last_but_not_least(self):
        self.assertEqual(self.nombres[-1], "LAST BUT NOT LEAST!")

    def test_llevan_el_nombre_de_los_programadores(self):
        """Se publica que las pistas se llaman como quien las hizo."""
        todos = " ".join(self.nombres)
        for quien in ("TERRY", "PETE", "GREG", "SHAUN", "CHRIS"):
            self.assertIn(quien, todos,
                          "%s sale en los creditos pero no en ninguna pista"
                          % quien)


class TestLasCurvasDeSalto(unittest.TestCase):
    """Siete curvas: la altura de la bola cuadro a cuadro."""

    CURVAS = ((0x8722, 0x8757), (0x8757, 0x877F), (0x877F, 0x879D),
              (0x879D, 0x87B4), (0x87B4, 0x87C9), (0x87C9, 0x87DB),
              (0x87DB, 0x87E8))

    def _curva(self, a, b):
        v = trozo("juego", a, b - a)
        self.assertEqual(v[-1], 0xFF, "la curva de 0x%04X no cierra con 0xFF" % a)
        return v[:-1]

    def test_cada_curva_baja_y_vuelve_a_subir(self):
        for a, b in self.CURVAS:
            v = self._curva(a, b)
            fondo = v.index(min(v))
            self.assertGreater(fondo, 0, "la curva de 0x%04X no baja" % a)
            self.assertLess(fondo, len(v) - 1,
                            "la curva de 0x%04X no vuelve a subir" % a)

    def test_cada_curva_acaba_cerca_de_donde_empieza(self):
        """Un salto que no vuelve al suelo dejaria la bola en el aire.

        No cierra clavado: la mas larga arranca en 0xBE y remata en 0xAF, y
        eso son quince pixeles. Pero la caida del salto es de 0x3E, o sea que
        la diferencia entre los dos extremos es siempre MENOR QUE LA MITAD de
        lo que la bola sube.
        """
        for a, b in self.CURVAS:
            v = self._curva(a, b)
            sube = v[0] - min(v)
            self.assertLess(abs(v[0] - v[-1]), max(5, sube // 2),
                            "la curva de 0x%04X no vuelve cerca del suelo" % a)

    def test_van_de_mas_larga_a_mas_corta(self):
        largos = [b - a for a, b in self.CURVAS]
        self.assertEqual(largos, sorted(largos, reverse=True))

    def test_la_tabla_de_ocho_apunta_a_las_seis_ultimas(self):
        """Y repite la mas larga en sus tres ultimas entradas."""
        t = trozo("juego", 0x87E8, 16)
        ps = [t[i * 2] | (t[i * 2 + 1] << 8) for i in range(8)]
        self.assertEqual(ps[-3:], [0x8757] * 3)
        for p in ps:
            self.assertIn(p, [c[0] for c in self.CURVAS])


class TestElSonido(unittest.TestCase):
    """La tabla de periodos del PSG."""

    def test_empieza_con_siete_words_a_uno(self):
        """El margen de los indices que 0x823D baja: la nota mas 0x0C."""
        t = trozo("juego", 0x812D, 14)
        self.assertEqual(t, [1, 0] * 7)

    def test_los_periodos_van_bajando(self):
        """Periodo mas corto es nota mas aguda: la tabla es una escala."""
        t = trozo("juego", 0x813B, 0x81A5 - 0x813B)
        ws = [t[i] | (t[i + 1] << 8) for i in range(0, len(t) - 1, 2)]
        for a, b in zip(ws, ws[1:]):
            self.assertGreater(a, b, "la tabla de periodos no baja")

    def test_una_octava_son_doce_notas_y_el_doble_de_periodo(self):
        """Si la tabla es cromatica, doce entradas mas alla el periodo se
        parte por la mitad."""
        t = trozo("juego", 0x813B, 0x81A5 - 0x813B)
        ws = [t[i] | (t[i + 1] << 8) for i in range(0, len(t) - 1, 2)]
        for i in range(len(ws) - 12):
            razon = ws[i] / ws[i + 12]
            self.assertAlmostEqual(razon, 2.0, delta=0.05,
                                   msg="la entrada %d y la %d no estan a una "
                                       "octava" % (i, i + 12))


class TestLasPaletas(unittest.TestCase):
    """La pantalla de carga y el juego comparten la misma paleta de ocho."""

    def test_la_paleta_del_juego_es_la_de_la_portada(self):
        tinta_p = trozo("portada", 0x88AC, 8)
        papel_p = trozo("portada", 0x88B4, 8)
        tinta_j = trozo("juego", 0x9593, 8)
        papel_j = trozo("juego", 0x959B, 8)
        self.assertEqual(tinta_p, tinta_j)
        self.assertEqual(papel_p, papel_j)

    def test_una_es_la_otra_corrida_un_nibble(self):
        tinta = trozo("portada", 0x88AC, 8)
        papel = trozo("portada", 0x88B4, 8)
        self.assertEqual(tinta, [p << 4 for p in papel])

    def test_los_ocho_colores_son_del_msx(self):
        for c in trozo("portada", 0x88B4, 8):
            self.assertLess(c, 16)


class TestLosTextos(unittest.TestCase):
    """Los rotulos que se publican tienen que decir lo que decimos."""

    def test_los_ocho_finales_de_partida(self):
        t = texto(trozo("juego", 0x87F8, 0x8887 - 0x87F8))
        for frase in ("GAME OVER", "DISQUALIFIED", "NIFTY CONTROL THERE",
                      "ALL LEVELS DONE", "NO RELAXING NOW",
                      "BOUNCE AROUND AGAIN", "WELL THAT WAS EASY",
                      "GO PLAY THE ARCADE"):
            self.assertIn(frase, t)

    def test_el_menu_de_opciones(self):
        t = texto(trozo("juego", 0x981C, 0x985B - 0x981C))
        for frase in ("OPTIONS", "3 : Play the game",
                      "4 : Game/Scores/Times", "M : Music On/Off"):
            self.assertIn(frase, t)

    def test_esta_el_cartel_del_modo_de_trampas(self):
        """En el rotulo que desfila el juego bromea con que 'puede que haya un
        modo de trampas, pero lo dudo'. El cartel esta en la cinta."""
        t = texto(trozo("juego", 0x9CC8, 0x9D1A - 0x9CC8))
        self.assertIn("YOU ARE NOW IN CHEAT MODE", t)
        self.assertIn("1986 Gremlin Graphics Ltd", t)
        self.assertIn("There may be a Cheat mode but I doubt it",
                      texto(trozo("juego", 0x9E69, 0xA29E - 0x9E69)))

    def test_al_modo_de_trampas_no_se_puede_llegar(self):
        """Y el cartel no lo pinta nadie: ninguna instruccion de las cinco
        piezas carga nada de la pagina 0x9C, que es donde vive."""
        for p in PIEZAS:
            for ln in lee(asm(p)).splitlines():
                s = ln.lstrip()
                if not ln.startswith("\t") or s.startswith(("def", ";", "org")):
                    continue
                codigo = ln.split(";")[0]
                self.assertNotRegex(
                    codigo, r"0?9c[0-9a-f]{2}h",
                    "en %s hay un operando de la pagina 0x9C: %r" % (p, ln))

    def test_ninguna_tecla_mirada_es_la_z_la_x_ni_la_c(self):
        """En el C64 al modo de trampas se entra con Z+X+C. Aqui el teclado
        entero pasa por `mira_una_tecla`, y entre los codigos que se le pasan no
        estan ni la Z (0x2F), ni la X (0x2D), ni la C (0x18): el codigo de tecla
        es fila*8+bit."""
        pedidas, ultima = [], None
        for ln in lee(asm("juego")).splitlines():
            s = ln.split(";")[0].strip()
            m = re.match(r"^ld a,0([0-9a-f]{2})h$", s)
            if m:
                ultima = int(m.group(1), 16)
            elif s == "xor a":
                ultima = 0x00
            elif s in ("ld a,b", "ld a,l", "ld a,(hl)"):
                ultima = None          # el codigo se calcula, no es literal
            elif s == "call mira_una_tecla":
                pedidas.append(ultima)
        self.assertEqual(len(pedidas), 12, "no son doce las llamadas")
        for tecla, nombre in ((0x2F, "Z"), (0x2D, "X"), (0x18, "C")):
            self.assertNotIn(tecla, pedidas, "se mira la '%s'" % nombre)
        # las que si se miran: M, la fila 0 (el 3 y el 4), CTRL+STOP, y los
        # cinco mandos que anuncia el rotulo: Q, L, W, P y el espacio
        self.assertEqual(set(x for x in pedidas if x is not None),
                         {0x00, 0x21, 0x22, 0x25, 0x26, 0x2C, 0x31, 0x3C, 0x40})

    def test_la_tabla_de_records_trae_catorce_lineas(self):
        t = texto(trozo("juego", 0x9A31, 0x9AA1 - 0x9A31))
        for letra in "BCDEFGHIJKLMN":
            self.assertIn("%s.99:99" % letra, t)
        self.assertEqual(t.count("99:99"), 14)


class TestSinNombresDeOtroJuego(unittest.TestCase):
    """El copia y pega de otro proyecto de la serie, cazado a tiempo."""

    def _revisa(self, ruta):
        t = lee(ruta)
        fn = os.path.basename(ruta)
        for juego in OTROS_JUEGOS:
            self.assertNotIn(juego, t, "%s nombra a %s" % (fn, juego))

    def _sin_ficheros_de_otro(self, ruta):
        t = lee(ruta).lower()
        for otro in OTROS_FICHEROS:
            for pega in ("src/%s" % otro, "%s.asm" % otro, "%s.cas" % otro,
                         "%s.rom" % otro, "%s.notes" % otro):
                self.assertNotIn(pega, t, "%s nombra el fichero %s"
                                 % (os.path.relpath(ruta, RAIZ), pega))

    def test_la_licencia_y_los_avisos_son_de_este_juego(self):
        for fn in ("LICENSE", "README.md", "README.es.md", "AVISO-LEGAL.md",
                   "LEGAL-NOTICE.md"):
            ruta = os.path.join(RAIZ, fn)
            if os.path.exists(ruta):
                self._revisa(ruta)

    def test_los_encabezados_de_los_listados_son_de_este_juego(self):
        for p in PIEZAS:
            cabeza = "\n".join(lee(asm(p)).splitlines()[:30])
            for juego in OTROS_JUEGOS:
                self.assertNotIn(juego, cabeza,
                                 "el encabezado de %s nombra a %s" % (p, juego))

    def test_ninguna_herramienta_abre_el_fichero_de_otro_juego(self):
        for fn in os.listdir(os.path.join(RAIZ, "tools")):
            if fn.endswith((".py", ".tcl")):
                self._sin_ficheros_de_otro(os.path.join(RAIZ, "tools", fn))

    def test_la_web_no_nombra_otro_juego(self):
        self.assertTrue(os.path.isdir(DOCS), "no hay web que revisar")
        for raiz, _, ficheros in os.walk(DOCS):
            for fn in ficheros:
                if fn.endswith((".md", ".html")):
                    self._revisa(os.path.join(raiz, fn))


if __name__ == "__main__":
    unittest.main()

#!/usr/bin/env python3
"""El CONTENIDO de la portada: los hallazgos y los pies de la galeria.

Va aparte de make_web.py a proposito. make_web.py es el generador -la
plantilla, la maquetacion, el HTML- y no cambia de un juego al siguiente; esto
es lo unico que hay que reescribir entero en cada uno. Teniendolo separado no
hay que ir buscando los textos del juego anterior dentro del generador, que es
justo como se han colado los nombres equivocados otras veces.

Cada hallazgo es (titulo, html) y cada entrada de galeria
(fichero, pie en castellano, pie en ingles).

Todas las cifras de aqui estan medidas sobre esta cinta, con las herramientas
de tools/, y no copiadas de ningun otro proyecto.
"""

HALLAZGOS = {
    "es": [
        ("La rutina que dibuja la pista se reescribe a si misma",
         "<p>La pista en perspectiva no esta dibujada en ninguna parte, y el "
         "motor que la pinta no lee los pixeles de una tabla: <b>se los "
         "escribe encima</b>. Por cada fila, <code>0x8BAE</code> saca cinco "
         "bytes de la tabla de <code>0x7800</code>, los pasa por dos tablas de "
         "traduccion y mete el resultado <b>dentro de los seis "
         "<code>ld a,000h</code></b> que hay repartidos por la rutina de "
         "dibujo, en <code>0x8C2D</code>, <code>0x8C42</code>, "
         "<code>0x8C56</code>, <code>0x8C81</code>, <code>0x8C95</code> y "
         "<code>0xC8A9</code>.</p>"
         "<p>Un cuadro despues, esos mismos <code>ld a,nn</code> sacan su "
         "valor por el puerto del VDP. La rutina no consulta: <b>ya trae el "
         "dibujo dentro</b>. Y hay un septimo operando escrito a mano, el de "
         "<code>0x8C01</code>, que elige la pagina de la tabla de "
         "perspectiva.</p>"),

        ("Cinco bandas a cinco velocidades: la profundidad, gratis",
         "<p>El avance de la pista no calcula ninguna proyeccion. "
         "<code>0x8AD3</code> reparte la pantalla en cinco bandas y repinta "
         "cada una a un ritmo distinto: la de delante <b>dos veces por "
         "paso</b>, la siguiente una, la tercera <b>una de cada dos</b>, la "
         "cuarta una de cada cuatro y la del horizonte <b>una de cada "
         "ocho</b>.</p>"
         "<p>Eso es todo. No hay division, ni tabla de perspectiva, ni "
         "multiplicacion: cinco contadores con su mascara -"
         "<code>and 001h</code>, <code>and 003h</code>, "
         "<code>and 007h</code>- y la carretera se aleja.</p>"),

        ("Catorce pistas en seis kilobytes, porque no guardan casillas",
         "<p>Las catorce pistas suman <b>3.494 filas</b> de cinco casillas, "
         "que serian 17.470 bytes. Ocupan <b>3.494</b>: una pista no guarda "
         "sus casillas, guarda una lista de <b>indices</b> a una tabla de "
         "filas.</p>"
         "<p>La tabla vive en los ultimos 0x800 bytes de la carga -"
         "<code>0x7800</code> en la RAM- y es lo que "
         "<code>0x8BB9</code> indexa con <code>fila*5</code>. Cada pista es "
         "una lista de bytes cerrada con <code>0xFF</code>, y el bucle de "
         "<code>0x93A4</code> avanza de una a la siguiente buscando ese "
         "<code>0xFF</code>.</p>"
         "<p>Las casillas son ocho: <b>agujero</b>, pista de dos colores, "
         "<b>acelera</b>, <b>frena</b>, <b>rebota</b> y dos que <b>invierten "
         "los mandos</b>. Lo dice el despachador de <code>0x8E65</code>, que "
         "compara la casilla contra esos valores y contra ningun otro.</p>"),

        ("El cargador no lee la cinta: monta un puente en la pila",
         "<p>El BIOS del MSX solo carga la primera pieza, la de "
         "<code>0xD800</code>. Las otras cuatro las lee ella, y lo hace con un "
         "truco: <code>0xD850</code> pone la pila en <code>0xFCA4</code> y "
         "empuja <b>cinco words que no son datos sino instrucciones</b> "
         "-<code>0xC961</code>, <code>0xEDD9</code>, <code>0x00E1</code>, "
         "<code>0xCDD9</code>, <code>0x69ED</code>-. Lo que queda escrito en "
         "<code>0xFC9A</code> es esto:</p>"
         "<pre>out (c),l     ; conmuta la ranura: entra la ROM del BIOS\n"
         "exx\n"
         "call 000E1h   ; TAPION\n"
         "exx\n"
         "out (c),h     ; y devuelve la ranura que habia\n"
         "ret</pre>"
         "<p>El juego necesita RAM en todas las paginas, pero para leer cinta "
         "hace falta la ROM. El puente vive en <code>0xFC9A</code> <b>porque "
         "la pagina 3 es RAM con las dos configuraciones</b>, y por eso "
         "sobrevive al cambio. Antes de montarlo se guarda lo que habia ahi "
         "-doce words de variables del BIOS- y al acabar se devuelve.</p>"
         "<p>Y luego <b>se reescribe dos veces</b>: <code>0xD871</code> le "
         "cambia el <code>call</code> a <code>0x00E4</code>, que es TAPIN, "
         "para leer los bytes; y <code>0xD8B5</code> a <code>0x00F3</code>, "
         "que es STMOTR, para parar el motor. Un solo puente para las tres "
         "llamadas.</p>"),

        ("La barra de carga es el borde de la pantalla",
         "<p>Mientras lee, <code>0xD8A7</code> saca el byte bajo de lo que "
         "queda por <b>el registro 7 del VDP</b>. No hay barra dibujada ni "
         "casillas que pintar: el color del borde va cambiando solo, y eso es "
         "todo el indicador de progreso.</p>"),

        ("El color de la pantalla de carga va comprimido ocho a uno",
         "<p>En SCREEN 2 la tabla de color son 0x1800 bytes, uno por cada fila "
         "de cada patron. La pantalla de carga guarda <b>0x300</b>: un byte "
         "por patron, porque las ocho filas llevan el mismo color, y "
         "<code>0x889C</code> lo escribe ocho veces seguidas.</p>"
         "<p>Y dentro de ese byte caben los dos colores: los <b>bits 0 a 2 son "
         "la tinta</b> y los <b>3 a 5 el papel</b>, indices de una paleta de "
         "ocho que esta dos veces en la ROM, una en el nibble alto y otra en "
         "el bajo, para poder pegarlos con un <code>or</code>. Los bits 6 y 7 "
         "no se usan.</p>"
         "<p>La misma paleta esta en el juego, en <code>0x9593</code>, byte "
         "por byte.</p>"),

        ("Los patrones van transpuestos",
         "<p>El bucle que vuelca los patrones a la VRAM lee ocho bytes con "
         "<code>inc h</code>, no con <code>inc hl</code>: <b>saltando de 256 "
         "en 256</b>. Y solo despues pasa al patron siguiente con "
         "<code>pop hl / inc l</code>.</p>"
         "<p>O sea que en la memoria el byte <code>(base + fila*0x100 + "
         "patron)</code> es la fila <code>fila</code> del patron "
         "<code>patron</code>, y no las ocho filas seguidas. Leido del modo "
         "obvio, la pantalla de carga sale a ruido. Pasa igual en la portada "
         "(<code>0x8858</code>), en el juego (<code>0x9522</code>) y en el "
         "bufer del rotulo que desfila (<code>0x961A</code>).</p>"),

        ("Las estrellas se mueven con treinta y dos <code>rl (hl)</code>",
         "<p><code>0x9BB1</code> desplaza una fila entera de la pantalla un "
         "pixel a la izquierda, y lo hace <b>sin bucle</b>: treinta y dos "
         "<code>rl (hl)</code> escritos uno detras de otro, con el acarreo "
         "pasando de un byte al siguiente. Cada ocho hay un <code>dec hl</code> "
         "en vez de un <code>dec l</code>, que es el salto a la banda de "
         "arriba.</p>"
         "<p>Y las estrellas de delante no son esas: son siete puntos que "
         "<code>0x8F65</code> mueve con velocidad y aceleracion propias, "
         "abriendose hacia los bordes como si vinieran de frente. <b>El color "
         "de cada una sale del registro R</b>, el contador de refresco de la "
         "DRAM, que va cambiando con cada instruccion (<code>0x90DE</code>).</p>"),

        ("Una sola rutina mira las ochenta teclas, fabricando el opcode",
         "<p><code>0xBF62</code> recibe un codigo de tecla, saca de sus tres "
         "bits bajos <b>el numero de bit</b>, lo sube al hueco que le toca y "
         "le pega un <code>0x47</code>, que es el opcode de "
         "<code>bit 0,a</code>. Y entonces <b>lo escribe en "
         "<code>0xBF85</code></b>, que es la instruccion que va a ejecutar dos "
         "lineas mas abajo.</p>"
         "<p>Sin tabla, sin bucle y sin ocho ramas: la instruccion se fabrica "
         "al vuelo. Lo mismo hace <code>0x9695</code> con el color de una "
         "linea de texto, escribiendo un <code>or</code> encima de un "
         "<code>nop</code> (<code>0x9808</code>).</p>"),

        ("El juego dice quien lo hizo, y con quien se llaman las pistas",
         "<p>El rotulo que desfila en el titulo -de <code>0x9E69</code> a "
         "<code>0xA29D</code>- da los creditos enteros: el original es de "
         "<b>Mr Chip Software (1986)</b> y lo escribio <b>Shaun Southern en el "
         "Commodore</b>; esta version la firman <b>Shaun Hollingworth, Colin "
         "Dooley, Peter Harrap, Chris Kerry y Greg Holmes</b> de Gremlin "
         "Graphics, con el diseno de <b>Terry Lloyd</b>.</p>"
         "<p>Y luego estan los catorce nombres de pista, en "
         "<code>0xA4CB</code>: TERRY'S TEST, PETE STREET, GREG THE NIPPER, "
         "SHAUN NOT SEAN!!, CHRIS'S CUL-DE-SAC... <b>las pistas llevan el "
         "nombre de quien las hizo</b>.</p>"
         "<p>El rotulo bromea con que <em>puede que haya un modo de trampas, "
         "pero lo dudo</em>. Lo hay: en <code>0x9CE6</code> esta su cartel, "
         "<b>FOOLED YOU!    YOU ARE NOW IN CHEAT MODE</b>. Y la pantalla de "
         "carga lleva firma: <b>STEVE.</b>, abajo a la derecha.</p>"),

        ("Dos kilobytes de memoria vieja, grabados en la cinta",
         "<p>La pieza que trae las pistas mide 10.240 bytes pero <b>solo usa "
         "la mitad de arriba</b>: lo unico que hace su codigo es llevar los "
         "0x2000 de <code>0x9000</code> a la RAM en <code>0x6000</code>, y el "
         "juego, que se carga despues, pisa <code>0x8800..0x9000</code> sin "
         "que nadie lo haya leido.</p>"
         "<p>Y se sabe de donde salen esos dos kilobytes: <b>231 bytes "
         "seguidos, de <code>0x8815</code> a <code>0x88FC</code>, son "
         "identicos a los que el juego trae para esas mismas direcciones</b>, "
         "y detras sigue el mismo codigo de arranque. De los 2.048, la mitad "
         "justa coinciden. El que grabo la cinta volco "
         "<code>0x8800..0xB000</code> de un tiron y se llevo de propina dos "
         "kilobytes del juego que ya estaban en memoria.</p>"
         "<p>Lo mismo pasa, mas pequeno, con las colas del cargador (143 "
         "bytes) y del buscador de RAM (175): ninguna instruccion las lee.</p>"),
    ],
    "en": [
        ("The routine that draws the track rewrites itself",
         "<p>The track in perspective is drawn nowhere at all, and the engine "
         "that paints it does not read pixels from a table: it <b>writes them "
         "into itself</b>. For each row, <code>0x8BAE</code> pulls five bytes "
         "out of the table at <code>0x7800</code>, passes them through two "
         "lookup tables and pokes the result <b>into the six "
         "<code>ld a,000h</code></b> scattered through the drawing routine, at "
         "<code>0x8C2D</code>, <code>0x8C42</code>, <code>0x8C56</code>, "
         "<code>0x8C81</code>, <code>0x8C95</code> and <code>0xC8A9</code>.</p>"
         "<p>A frame later those same <code>ld a,nn</code> push their value out "
         "of the VDP port. The routine does not look anything up: <b>it already "
         "carries the picture inside</b>. There is a seventh hand-written "
         "operand too, at <code>0x8C01</code>, choosing the page of the "
         "perspective table.</p>"),

        ("Five bands at five rates: depth, for free",
         "<p>Advancing the track computes no projection at all. "
         "<code>0x8AD3</code> splits the screen into five bands and repaints "
         "each at a different rate: the nearest <b>twice per step</b>, the "
         "next once, the third <b>one time in two</b>, the fourth one in four "
         "and the horizon <b>one in eight</b>.</p>"
         "<p>That is the whole of it. No division, no perspective table, no "
         "multiply: five counters with their mask - <code>and 001h</code>, "
         "<code>and 003h</code>, <code>and 007h</code> - and the road recedes.</p>"),

        ("Fourteen tracks in six kilobytes, because they store no tiles",
         "<p>The fourteen tracks add up to <b>3,494 rows</b> of five tiles, "
         "which would be 17,470 bytes. They take <b>3,494</b>: a track does "
         "not store its tiles, it stores a list of <b>indices</b> into a table "
         "of rows.</p>"
         "<p>The table lives in the last 0x800 bytes of the load - "
         "<code>0x7800</code> in RAM - and it is what <code>0x8BB9</code> "
         "indexes with <code>row*5</code>. Each track is a list of bytes "
         "closed by <code>0xFF</code>, and the loop at <code>0x93A4</code> "
         "walks from one to the next looking for it.</p>"
         "<p>There are eight kinds of tile: <b>hole</b>, two-colour track, "
         "<b>speed up</b>, <b>slow down</b>, <b>bounce</b> and two that "
         "<b>reverse the controls</b>. That is what the dispatcher at "
         "<code>0x8E65</code> says, comparing the tile against those values "
         "and no others.</p>"),

        ("The loader does not read the tape: it builds a bridge on the stack",
         "<p>The MSX BIOS only loads the first piece, the one at "
         "<code>0xD800</code>. That piece reads the other four itself, and it "
         "does it with a trick: <code>0xD850</code> puts the stack at "
         "<code>0xFCA4</code> and pushes <b>five words that are not data but "
         "instructions</b> - <code>0xC961</code>, <code>0xEDD9</code>, "
         "<code>0x00E1</code>, <code>0xCDD9</code>, <code>0x69ED</code>. What "
         "ends up written at <code>0xFC9A</code> is this:</p>"
         "<pre>out (c),l     ; switch the slot: the BIOS ROM comes in\n"
         "exx\n"
         "call 000E1h   ; TAPION\n"
         "exx\n"
         "out (c),h     ; and put the slot back\n"
         "ret</pre>"
         "<p>The game needs RAM in every page, but reading tape needs the ROM. "
         "The bridge lives at <code>0xFC9A</code> <b>because page 3 is RAM in "
         "both configurations</b>, which is how it survives the switch. Before "
         "building it the loader saves what was there - twelve words of BIOS "
         "variables - and puts them back afterwards.</p>"
         "<p>And then it <b>rewrites it twice</b>: <code>0xD871</code> changes "
         "the <code>call</code> to <code>0x00E4</code>, which is TAPIN, to "
         "read the bytes; and <code>0xD8B5</code> to <code>0x00F3</code>, "
         "STMOTR, to stop the motor. One bridge for all three calls.</p>"),

        ("The loading bar is the screen border",
         "<p>While it reads, <code>0xD8A7</code> pushes the low byte of what "
         "is left out of <b>VDP register 7</b>. There is no bar drawn and no "
         "tiles to paint: the border colour just keeps changing, and that is "
         "the whole progress indicator.</p>"),

        ("The loading screen's colour is compressed eight to one",
         "<p>In SCREEN 2 the colour table is 0x1800 bytes, one per row of each "
         "pattern. The loading screen stores <b>0x300</b>: one byte per "
         "pattern, because all eight rows carry the same colour, and "
         "<code>0x889C</code> writes it eight times over.</p>"
         "<p>And both colours fit inside that byte: <b>bits 0 to 2 are the "
         "ink</b> and <b>3 to 5 the paper</b>, indices into a palette of eight "
         "that sits in the ROM twice, once in the high nibble and once in the "
         "low, so they can be joined with an <code>or</code>. Bits 6 and 7 go "
         "unused.</p>"
         "<p>The very same palette is in the game, at <code>0x9593</code>, "
         "byte for byte.</p>"),

        ("The patterns are stored transposed",
         "<p>The loop that dumps patterns into VRAM reads eight bytes with "
         "<code>inc h</code>, not <code>inc hl</code>: <b>jumping 256 at a "
         "time</b>. Only afterwards does it move to the next pattern with "
         "<code>pop hl / inc l</code>.</p>"
         "<p>So in memory the byte <code>(base + row*0x100 + pattern)</code> "
         "is row <code>row</code> of pattern <code>pattern</code>, not eight "
         "consecutive rows. Read the obvious way, the loading screen comes out "
         "as noise. Same in the loading screen (<code>0x8858</code>), in the "
         "game (<code>0x9522</code>) and in the scroller's buffer "
         "(<code>0x961A</code>).</p>"),

        ("The starfield moves with thirty-two <code>rl (hl)</code>",
         "<p><code>0x9BB1</code> shifts a whole screen row one pixel to the "
         "left, and it does it <b>with no loop</b>: thirty-two "
         "<code>rl (hl)</code> written one after another, with the carry "
         "passing from one byte to the next. Every eighth there is a "
         "<code>dec hl</code> instead of a <code>dec l</code>, which is the "
         "jump to the band above.</p>"
         "<p>The stars in front are not those: they are seven dots that "
         "<code>0x8F65</code> moves with their own speed and acceleration, "
         "spreading towards the edges as if coming head-on. <b>Each one's "
         "colour comes from register R</b>, the DRAM refresh counter, which "
         "changes with every instruction (<code>0x90DE</code>).</p>"),

        ("One routine reads all eighty keys, by manufacturing the opcode",
         "<p><code>0xBF62</code> takes a key code, pulls <b>the bit number</b> "
         "out of its low three bits, shifts it into place and ors in a "
         "<code>0x47</code>, which is the opcode for <code>bit 0,a</code>. And "
         "then it <b>writes that into <code>0xBF85</code></b>, which is the "
         "instruction it will execute two lines later.</p>"
         "<p>No table, no loop, no eight branches: the instruction is built on "
         "the fly. <code>0x9695</code> does the same with the colour of a line "
         "of text, writing an <code>or</code> over a <code>nop</code> "
         "(<code>0x9808</code>).</p>"),

        ("The game says who made it, and the tracks are named after them",
         "<p>The scroller on the title screen - from <code>0x9E69</code> to "
         "<code>0xA29D</code> - gives the full credits: the original is <b>Mr "
         "Chip Software's (1986)</b> and was written by <b>Shaun Southern on "
         "the Commodore</b>; this version is credited to <b>Shaun "
         "Hollingworth, Colin Dooley, Peter Harrap, Chris Kerry and Greg "
         "Holmes</b> of Gremlin Graphics, with design by <b>Terry Lloyd</b>.</p>"
         "<p>Then there are the fourteen track names, at <code>0xA4CB</code>: "
         "TERRY'S TEST, PETE STREET, GREG THE NIPPER, SHAUN NOT SEAN!!, "
         "CHRIS'S CUL-DE-SAC... <b>the tracks are named after the people who "
         "made them</b>.</p>"
         "<p>The scroller jokes that <em>there may be a Cheat mode but I doubt "
         "it</em>. There is: at <code>0x9CE6</code> sits its banner, <b>FOOLED "
         "YOU!    YOU ARE NOW IN CHEAT MODE</b>. And the loading screen is "
         "signed: <b>STEVE.</b>, bottom right.</p>"),

        ("Two kilobytes of stale memory, recorded onto the tape",
         "<p>The piece carrying the tracks is 10,240 bytes but <b>only the top "
         "half is used</b>: all its code does is move the 0x2000 bytes at "
         "<code>0x9000</code> into RAM at <code>0x6000</code>, and the game, "
         "loading afterwards, walks over <code>0x8800..0x9000</code> without "
         "anyone having read it.</p>"
         "<p>And we know where those two kilobytes came from: <b>231 "
         "consecutive bytes, from <code>0x8815</code> to <code>0x88FC</code>, "
         "are identical to what the game carries for those very addresses</b>, "
         "and the same startup code follows. Of the 2,048, exactly half "
         "match. Whoever made the tape dumped <code>0x8800..0xB000</code> in "
         "one go and got two kilobytes of the game thrown in.</p>"
         "<p>The same thing happens, smaller, with the tails of the loader "
         "(143 bytes) and of the RAM finder (175): no instruction reads "
         "them.</p>"),
    ],
}

GALERIA = [
    ("rotulo.png",
     "La pantalla de carga, montada como la monta la cinta: los patrones "
     "deshaciendo su transposicion y el color estirado ocho a uno desde los "
     "0x300 bytes que lo guardan. Abajo a la derecha, en letra pequena, la "
     "unica firma de toda la cinta: <b>STEVE.</b>",
     "The loading screen, built the way the tape builds it: the patterns with "
     "their transposition undone and the colour stretched eight to one from "
     "the 0x300 bytes that hold it. Bottom right, in small type, the only "
     "signature anywhere on the tape: <b>STEVE.</b>"),

    ("pista-01.png",
     "La primera pista, EASY GOING, entera y tumbada: la salida a la "
     "izquierda. Azul es pista, negro agujero, verde acelera, rojo frena y "
     "blanco rebota. Son 219 filas de cinco casillas, y la cinta las guarda en "
     "219 bytes.",
     "The first track, EASY GOING, whole and laid on its side: the start is on "
     "the left. Blue is track, black is hole, green speeds up, red slows down "
     "and white bounces. It is 219 rows of five tiles, and the tape stores it "
     "in 219 bytes."),

    ("pista-14.png",
     "Y la ultima, LAST BUT NOT LEAST!, con la misma escala. La comparacion "
     "con la primera se ve de un vistazo: la dificultad no esta en el largo "
     "sino en cuantos agujeros hay por fila.",
     "And the last one, LAST BUT NOT LEAST!, at the same scale. Set against "
     "the first, the comparison speaks for itself: the difficulty is not in "
     "the length but in how many holes there are per row."),

    ("filas.png",
     "Las filas distintas de la tabla de 0x7800, las 176 primeras. Una pista "
     "no guarda casillas: guarda una lista de indices a esta tabla, y por eso "
     "catorce pistas de 3.494 filas caben en 3.494 bytes.",
     "The distinct rows in the table at 0x7800, the first 176 of them. A track "
     "does not store tiles: it stores a list of indices into this table, which "
     "is how fourteen tracks of 3,494 rows fit in 3,494 bytes."),

    ("sprites.png",
     "Los 0x400 bytes que el arranque vuelca a la VRAM: la bola, en las "
     "tallas que necesita la perspectiva, y sus mascaras. Cotejados contra la "
     "VRAM de openMSX: <b>cero bytes distintos</b>.",
     "The 0x400 bytes the startup code dumps into VRAM: the ball, in the sizes "
     "the perspective needs, and its masks. Checked against openMSX's VRAM: "
     "<b>zero bytes different</b>."),

    ("fuente.png",
     "La fuente del juego, de 0xBB25 a 0xBE0E. Es la hoja que el arranque deja "
     "en (0xA41E), el puntero del que tira la rutina de texto; para el rotulo "
     "grande de las opciones se cambia por otra y se devuelve.",
     "The game's font, from 0xBB25 to 0xBE0E. It is the sheet the startup code "
     "leaves in (0xA41E), the pointer the text routine works from; for the "
     "large caption in the options screen it is swapped for another and put "
     "back."),
]

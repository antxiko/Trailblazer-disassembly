# Trailblazer (Gremlin Graphics, MSX1) — desensamblado comentado

*(Also [in English](README.md).)* ·
**[Leerlo en la web](https://antxiko.github.io/Trailblazer-disassembly/es/)**

Desensamblado completo y comentado de **Trailblazer** de Gremlin Graphics para
MSX (1986, cinta). Los 38.299 bytes de contenido están explicados, y
reensamblar las cinco piezas y volver a envolverlas devuelve el `.cas`
**byte a byte**.

    explicado          38.299 de 38.299   100 %
    densidad            1.119 de 3.637    30,8 %
    rutinas bajo el 10 %      0 de 355
    tests                    43, en verde
    reensamblado       el mismo sha256 que la cinta

## Qué hay aquí

    src/trailblazer_*.asm    los cinco listados comentados, generados
    src/*.notes              los comentarios y los bloques de datos, con su medida
    src/*.entries            los puntos de entrada que no se deducen solos
    tools/                   trazado, listados, dibujos y tres sondas de emulador
    tests/                   43 comprobaciones que no necesitan la cinta
    docs/                    la web bilingüe

## La cinta no está aquí

`trailblazer.cas` no se distribuye. Pon tu propia copia en la raíz; son 38.458
bytes exactos y

    sha256  779b662747fdd04b641fbf898124611562d9913e570f5050b5d73580ce63cf50

## Reproducirlo

    make cinta         # comprueba que tu cinta es la misma
    make               # listados, reensamblado, comprobaciones y tests
    make imagenes      # dibuja las catorce pistas, y lo demás, desde la cinta
    make emulador      # la carga en openMSX y vuelca VRAM, RAM y el VDP

## Ni una captura de pantalla

Todas las imágenes de este repositorio están **dibujadas desde los bytes de la
cinta**, ejecutando en Python los mismos pasos que hace el Z80: estirar el color
comprimido, deshacer la transposición de los patrones y recorrer las pistas fila
a fila.

Están dibujadas **las catorce pistas** enteras.

## Lo que apareció

- **La rutina que dibuja la pista se reescribe a sí misma.** Los `ld a,000h`
  que sacan los píxeles por el puerto del VDP no leen nada: una rutina anterior
  les escribe el valor dentro de la instrucción, fila a fila. Siete operandos
  escritos a mano.
- **El cargador no lee la cinta**: monta en la pila un puente de seis
  instrucciones —conmutar la ranura, llamar al BIOS, devolverla— y se lo
  reescribe tres veces, en TAPION, TAPIN y STMOTR.
- **Cinco bandas repintadas a cinco ritmos distintos** hacen la perspectiva. Sin
  división, sin tabla y sin una sola multiplicación.
- **Catorce pistas en 3.494 bytes**, porque guardan índices y no casillas.
- **Una sola rutina mira las ochenta teclas**, fabricando el opcode de
  `bit n,a` y escribiéndoselo encima.
- **La barra de carga es el borde de la pantalla.**
- **Dos kilobytes de memoria vieja** se grabaron en la cinta por accidente.

Todo, con su medida, en
[Hallazgos](https://antxiko.github.io/Trailblazer-disassembly/es/HALLAZGOS.html).

## Licencia y crédito

Las herramientas, los comentarios, el análisis y la documentación son MIT —ver
`LICENSE`—. El juego no es nuestro: lee [AVISO-LEGAL.md](AVISO-LEGAL.md).

El original es de Mr Chip Software, de **Shaun Southern**; esta versión de MSX
la acredita el propio juego a **Shaun Hollingworth, Colin Dooley, Peter Harrap,
Chris Kerry y Greg Holmes** de Gremlin Graphics, con el diseño de **Terry
Lloyd**. La pantalla de carga va firmada **STEVE.**

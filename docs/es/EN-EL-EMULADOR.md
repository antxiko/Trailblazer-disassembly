# En el emulador

Aquí el emulador no es un adorno: es una **herramienta de medida**, y tres
cosas de este desensamblado no se habrían cerrado sin él.

## Cargar la cinta y volcarlo todo

    make emulador

Mete la cinta en openMSX, teclea `BLOAD"CAS:",R`, espera a que el PC lleve ocho
segundos dentro de `0x80E8..0xCFFF` y vuelca la VRAM, los 64 KB de RAM **y los
ocho registros del VDP**. Después entra en el menú y arranca una partida, y
vuelve a volcar.

Tarda unos 190 segundos emulados: son 38 KB de cinta a 1200 baudios, aunque
emulados a toda velocidad.

## El teclado no se lee con la BIOS

Y eso importa para automatizarlo. El `type` de openMSX inyecta la pulsación por
donde la lee el BASIC, y este juego **lee el teclado a mano por el PPI**
(`0xBF17` y `0xBF62`). La tecla que inyecta el BASIC dura menos que su barrido y
no se entera.

La salida es apretar la tecla **en la matriz** y mantenerla medio segundo:

    keymatrixdown 8 0x01          ; espacio
    after time 0.5 {keymatrixup 8 0x01}

El propio juego dice qué hay que pulsar: *Press any key for options* primero, y
ya en el menú, `3 : Play the game`.

## De ahí salió la geometría de pantalla

    R0 = 0x02   modo 2 (SCREEN 2)
    R1 = 0xE2   16 KB, pantalla on, interrupción on, sprites 16x16
    R2 = 0x06   nombres             en 0x1800
    R3 = 0xFF   colores   base 0x2000, máscara 0x1FFF
    R4 = 0x03   patrones  base 0x0000, máscara 0x1FFF
    R5 = 0x36   atributos de sprite en 0x1B00
    R6 = 0x07   patrones de sprite  en 0x3800
    R7 = 0x01   borde negro

Medirla y no suponerla no es manía: la primera lectura de este desensamblado
daba los volcados a `0x1800` por tabla de color, y son **la tabla de nombres**.
Con la geometría equivocada, los dibujos salen bien de forma y mal de sitio, y
eso no se ve mirándolos.

## Quién toca una zona de memoria

    tools/omsx_quien_lee.tcl

Pone un punto de vigilancia sobre un rango y anota el PC de cada lectura o
escritura. Se usa cuando el análisis estático se queda sin nada que mirar:
cuando la dirección **se calcula** y no aparece escrita en ninguna instrucción.

Con esto se cerró la **tabla de la perspectiva**. Los 3.570 bytes que van de
`0xC20E` al final no los apunta ningún `ld hl,0Cxxxh`, y no hay forma de
encontrarlos leyendo. Vigilando la zona con el juego en marcha salieron
**exactamente siete sitios**: `0x9632` y los seis de la rutina de dibujo.

## Quién entra en una rutina

    tools/omsx_quien_llama.tcl

Punto de ruptura en la rutina y a ver quién ha dejado la dirección de vuelta en
la pila. Se usó con seis rutinas a las que no llama nadie de forma visible: no
aparecen en ningún `call`, `jp` ni `ld hl,`, ni hay saltos relativos del código
trazado que caigan en ellas.

De las seis, **ninguna se ejecutó** en noventa segundos de partida. O son de
pantallas que la prueba no llegó a tocar —el fin de partida, la tabla de
récords— o son código muerto. El modo de trampas ya no vale como explicación:
no se puede alcanzar, y está medido en [Hallazgos](HALLAZGOS.html). Las seis
están en [Preguntas abiertas](PREGUNTAS-ABIERTAS.html).

También sirvió para lo contrario: confirmar que `0x8E4B` y `0x92D1`, a las que
se llega por un `ld hl,nn / push hl` y no por un `call`, **sí se ejecutan**.

## Qué trozos del cargador corren de verdad

    tools/omsx_muestrea.tcl

Cuatro mil muestras del PC mientras la cinta carga entera. No es tan exacto
como un punto de ruptura, pero para separar el código vivo del que no se toca
nunca sobra.

Con esto se descubrió que la rutina de `0xD8D5` —la que lee el bit de la cinta
a mano por el puerto `0xA2`— **no se ejecuta en ningún momento**: la carga de
verdad llama a TAPIN del BIOS. Es un cargador rápido que se quedó dentro.

## Y una afirmación que hubo que retirar

Antes de esa medida, este desensamblado decía que el cargador «se fabrica su
rutina de lectura en la pila y saca el bit del puerto 0xA2 a mano». Media
afirmación era cierta —el puente en la pila está ahí— y la otra media, falsa: el
puente no lee bits, **llama al BIOS**, y la rutina que lee bits no se usa.

Se corrigió en cuanto la máquina lo dijo.

## Trampas de Tcl ya pagadas en esta serie

- Nada de corchetes dentro de un `format`.
- El fichero binario, con `-translation binary`.
- `debug read_block`, que `debug save_to_file` no existe.
- Y en un manejador de punto de vigilancia, cuidado con leer variables que
  quizá no existan: la excepción se traga en silencio y el contador sube sin
  que se escriba nada en el registro.

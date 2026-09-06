# Preguntas abiertas

Los 38.299 bytes están explicados y los cinco listados reproducen la cinta byte
a byte. Lo que sigue no son huecos del desensamblado: son cosas que el juego
hace y de las que no se ha medido el **porqué**, o que no se han podido
alcanzar.

## Cómo se entra en el modo de trampas

El cartel está: **FOOLED YOU!    YOU ARE NOW IN CHEAT MODE**, en `0x9CE6`. Y el
rótulo que desfila bromea con que *puede que haya un modo de trampas, pero lo
dudo*.

Lo que no se ha encontrado es **qué hay que hacer para que salga**. La cadena no
la apunta ninguna instrucción trazada, así que se pinta desde código que solo
corre por ese camino.

## Seis rutinas a las que no se sabe cómo se llega

`0x81A5`, `0x8CBE`, `0x93DC`, `0x9722`, `0x973F` y `0x9DAD` desensamblan como
rutinas completas y coherentes —empiezan por una instrucción válida, tocan las
mismas variables que el resto del juego y rematan en `ret`—, pero:

- no aparecen en ningún `call`, `jp`, `ld hl,` ni como word suelta en los 20.248
  bytes de la pieza;
- no hay ningún salto relativo del código trazado que caiga en ellas;
- y con puntos de ruptura en la máquina y el juego en marcha noventa segundos
  **no se entra en ninguna**.

O son de pantallas que la prueba no llegó a tocar —el fin de partida, la tabla
de récords, el propio modo de trampas— o son código muerto. Se declaran como
código porque lo son; de dónde se llega a ellas, no se sabe.

## El cargador rápido que no se usa

`0xD8D5` lee el bit de la cinta a mano por el puerto `0xA2`, y está medido que
**no se ejecuta**. Lo que no se sabe es si es el cargador de otra versión del
juego, un resto de las pruebas, o un camino alternativo que se activa en alguna
condición que no hemos dado.

## El quinto byte de las cabeceritas

Cada pieza va precedida de ocho bytes: `0xFE`, la dirección de carga, la
longitud, **un byte más** y dos ceros. El cargador solo lee cuatro (`ld
de,00004h`), así que ese quinto byte no lo mira nadie durante la carga.

Los cuatro valores que toma son `0x6E`, `0x6B`, `0x5E` y `0xC1`. Tiene pinta de
suma de control —el cargador lleva una en `b` mientras lee (`0xD8A5`)—, pero
como no se compara con nada, no se puede afirmar.

## Los 768 bytes de la tabla de filas que no se usan

La tabla de filas ocupa 0x800 bytes, o sea 409 filas de cinco. El índice más
alto que usa cualquiera de las catorce pistas es **173**. De la 174 en adelante
hay filas montadas que ninguna pista nombra: ¿son de pistas que se cayeron, o
simplemente relleno?

## Cuánto se juega de verdad de cada pista

Las catorce están dibujadas enteras, pero no se ha medido si el juego las
recorre completas o si el final llega antes. El `0xFF` que cierra cada lista es
lo que hace que `0x8B1B` marque el final de pista, así que en principio sí, pero
no se ha comprobado corriendo.

## Quién es STEVE

La pantalla de carga lleva esa firma abajo a la derecha. En los créditos del
rótulo que desfila no aparece ningún Steve: los que salen son Shaun
Hollingworth, Colin Dooley, Peter Harrap, Chris Kerry, Greg Holmes, Terry Lloyd
y Shaun Southern.

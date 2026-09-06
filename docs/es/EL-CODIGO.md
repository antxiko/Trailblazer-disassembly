# El código

## La rutina que dibuja la pista se reescribe a sí misma

Es el corazón del juego y merece contarse despacio.

La pista en perspectiva no está dibujada en ninguna parte. El motor que la
pinta —`0x8C11` hacia arriba y `0x8C65` hacia abajo— es una tira de bloques
iguales:

    ld a,e / out (099h),a      ; la dirección de VRAM
    ld a,d / out (099h),a
    ld a,000h                  ; <- el byte de píxeles
    out (098h),a               ; y fuera

Ese `ld a,000h` **no lee el byte de ninguna parte: se lo escriben encima**. Por
cada fila, `0x8BAE` saca cinco bytes de la tabla de `0x7800`, los pasa por dos
tablas de traducción de 256 entradas —las que `0x890F` y `0x8920` montan en
`0xFB00` y `0xFC00` repitiendo ocho bytes treinta y dos veces— y mete el
resultado en los seis operandos de `0x8C2D`, `0x8C42`, `0x8C56`, `0x8C81`,
`0x8C95` y `0xC8A9`.

Hay un séptimo operando escrito a mano, el de `0x8C01`, que elige la página de
la tabla de perspectiva. Lo escribe `0x8998` al empezar la pista.

## La tabla de la perspectiva no aparece en ninguna instrucción

Los 3.570 bytes que van de `0xC20E` al final de la pieza no los apunta ningún
`ld hl,0Cxxxh`. La dirección se calcula: `0x8C14` hace

    ld a,e / and 007h / add a,a / or 0c0h / ld h,a

o sea **`0xC0` más el doble de los tres bits bajos de `e`**, que da las ocho
páginas pares `0xC0`, `0xC2` … `0xCE`.

Como el análisis estático se quedaba sin nada que mirar, se le preguntó a la
máquina: un punto de vigilancia de openMSX sobre `0xC20E..0xCFFF` con el juego
en marcha (`tools/omsx_quien_lee.tcl`) dice que la leen **exactamente siete
sitios**, `0x9632` y los seis de la rutina de dibujo.

Y `0x9629` usa **las mismas ocho páginas pares** para otra cosa: las copia de
256 en 256 a la RAM —saltando de dos en dos páginas con el doble `inc h` de
`0x9639`— y de ahí vuelca los 0x800 a la VRAM. Los mismos bytes sirven de tabla
y de patrones.

## Cinco bandas a cinco velocidades

El avance de la pista no calcula ninguna proyección. `0x8AD3` reparte la
pantalla en cinco bandas y repinta cada una a un ritmo distinto:

| banda | filas | se repinta |
|---|---:|---|
| la de delante | 32 | **dos veces** por paso |
| la segunda | 16 | una |
| la tercera | 16 | una de cada dos |
| la cuarta | 16 | una de cada cuatro |
| el horizonte | 16 | una de cada ocho |

Cinco contadores con su máscara —`and 001h`, `and 003h`, `and 007h`— y la
carretera se aleja. No hay división, ni tabla de perspectiva, ni una sola
multiplicación.

Y la altura de la bola se traduce a fila de pista con el mismo criterio, al
revés: `0x8E31` compara contra `0xB3`, `0x8E`, `0x64` y `0x3E` y devuelve 4, 3,
2, 1 o 0.

## Catorce pistas que no guardan casillas

Las catorce suman **3.494 filas** de cinco casillas, que serían 17.470 bytes.
Ocupan **3.494**.

La pieza de las pistas lleva 0x2000 bytes a la RAM en `0x6000`. De esos:

- los **últimos 0x800** son la tabla de filas: cinco casillas por fila, una
  detrás de otra, y ahí es donde `0x8BB9` va a buscar con `fila*5 + 0x7800`;
- los **0x1800 primeros** son las catorce pistas, y cada una es una lista de
  **índices** a esa tabla, cerrada con `0xFF`. Lo dice el bucle de `0x93A4`,
  que avanza pista a pista buscando ese `0xFF`.

Una pista de 219 filas ocupa 219 bytes porque las filas se repiten y basta con
nombrarlas.

## La interrupción, en modo 2

`0x88E4` la monta, y es de manual con un rodeo bonito:

1. `0xFD00..0xFDFF` se llena con `0xFE` —257 bytes de un golpe, con el
   `ld (hl),0feh` y el LDIR solapado de `0x88EE`—, y `ld i,a` con `a` = `0xFD`
   pone ahí la tabla de vectores;
2. el vector que sale de esa tabla es la word de `0xFDFE`, que vale `0xFEFE`;
3. y en `0xFEFE` se escribe… `0xFB18`, que como instrucción es `jr $-5`;
4. y en `0xFEFB` se escribe `0xC3` y detrás `0x9134`: `jp 09134h`.

El rodeo es el truco clásico para que la tabla de 257 bytes sea **un solo byte
repetido**. El destino de verdad es `0x9134`, y de ahí cuelga todo el juego: la
música, los mandos, el movimiento de la bola, el avance de la pista y el
pintado.

## Las estrellas

Hay dos clases, y ninguna se dibuja como un sprite.

Las del **fondo** son la pantalla entera desplazándose: `0x9BB1` mueve una fila
un píxel a la izquierda con **treinta y dos `rl (hl)` escritos uno detrás de
otro, sin bucle**, con el acarreo pasando de un byte al siguiente. Cada ocho
hay un `dec hl` en vez de un `dec l`, que es el salto a la banda de arriba. Y
solo se mueven una vez de cada ocho cuadros.

Las de **delante** son siete puntos con velocidad y aceleración propias
(`0x8F65`), que se abren hacia los bordes como si vinieran de frente: a cada
una se le suma su aceleración cada dos cuadros, y cuando se sale por el borde
vuelve al centro con parámetros nuevos.

**El color de cada punto sale del registro R**, el contador de refresco de la
DRAM, subido al nibble alto (`0x90DE`). No se decide: se toma.

## El dado

`0x908E` no tiene tabla. Coge la semilla, la pone en el byte alto, le resta dos
veces el mismo valor, cruza los dos bytes **y lo mezcla con el registro R**.
Como R va cambiando con cada instrucción que se ejecuta, dos partidas no salen
iguales aunque se arranque igual.

## Una rutina para las ochenta teclas

`0xBF62` recibe un código de tecla. De sus tres bits bajos saca **el número de
bit**, lo sube al hueco que le toca y le pega un `0x47`, que es el opcode de
`bit 0,a`. Y entonces **lo escribe en `0xBF85`**, que es la instrucción que va a
ejecutar dos líneas más abajo.

Sin tabla, sin bucle y sin ocho ramas.

Lo mismo hace `0x9695` con el color de una línea de texto: escribe un `or` con
el color encima de un `nop` (`0x9808`), y así el mismo bucle pinta encendido o
apagado sin ninguna comparación.

## El texto

Todas las cadenas llevan **el final marcado en el bit 7** de la última letra.
Por eso volcadas en crudo se ven pegadas unas a otras.

`(0xA41E)` es el puntero a la hoja de caracteres que usa la rutina de pintar
(`0x97D3`). El arranque lo deja en `0xBA2E`, que es la fuente normal, y
`0x9957` y `0x9973` lo cambian a otra hoja para un rótulo y lo devuelven.

# Aviso legal y atribucion

*(Also available [in English](LEGAL-NOTICE.md).)*

## De quien es cada cosa

**El juego no es nuestro.** *Trailblazer* lo publico **Gremlin Graphics** para
MSX en 1986, en cinta: 38.458 bytes. El original es de **Mr Chip Software** y
lo escribio **Shaun Southern** para el Commodore 64; esta version la firman
**Shaun Hollingworth, Colin Dooley, Peter Harrap, Chris Kerry y Greg Holmes**,
con el diseno de **Terry Lloyd**. Lo dice el propio juego, en el rotulo que
desfila por la pantalla del titulo. Todos los derechos siguen siendo de sus
titulares.

**Lo que si es nuestro** son las herramientas de este repositorio, los
comentarios del listado, el analisis y la documentacion. Eso se publica con la
licencia de `LICENSE`.

## Que hay en este repositorio

Los cinco ficheros `src/trailblazer_*.asm` son el desensamblado comentado de
las cinco piezas de la cinta. Se publican
para la **preservacion, el estudio y la documentacion** de un titulo que es
parte de la historia del software del MSX.

La imagen de la cinta (`.cas`) **no** se distribuye aqui. Quien quiera volver a
montar el listado tiene que poner la suya, y el `Makefile` comprueba su sha256
antes de hacer nada.

Las imagenes que produce `tools/graficos.py` no son ilustraciones traidas de
fuera: se dibujan leyendo los propios bloques de la cinta, en las direcciones
que dice el listado. Son parte de la prueba de que la lectura del binario es
correcta: si estuviera mal, saldria ruido.

## En que se apoya

En nada de nadie. Todo lo que se afirma aqui sale de leer este binario o de
medirlo corriendo, y cada afirmacion lleva su evidencia al lado: la instruccion
que lee un dato, la tabla que cierra exactamente donde tiene que cerrar, o la
medida hecha en el emulador. Lo que no esta cerrado se dice que no lo esta.

Donde se cita algo de fuera de la cinta -el formato de los creditos, que los da el propio juego en su rotulo- se dice de donde sale y se da las gracias a
quien lo hallo.

## Si eres uno de los autores

Si trabajaste en *Trailblazer* o tienes derechos sobre el juego, y preferirias que este
material no estuviera publicado, **dilo y se retira, sin discusion**. La
intencion de este trabajo es justo la contraria de perjudicarte: es dejar
constancia de como se hizo.

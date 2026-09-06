; ==========================================================================
; TRAILBLAZER - Gremlin Graphics 1986 - MSX1 - el juego
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x080e8


; ----------------------------------------------------------------------
; Direcciones que solo aparecen como VALOR -en un `ld`, no en
; un salto-: son punteros que el codigo se pasa o numeros que
; casualmente coinciden con una direccion. No hay nada que
; trazar en ellas; el equ existe para que el listado ensamble.
; ----------------------------------------------------------------------
l83b5h:	equ 0x083b5
l9808h:	equ 0x09808

; ======================================================================
; CODIGO 0x80e8..0x812d  (69 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL ARRANQUE DEL JUEGO
; ----------------------------------------------------------------------
arranca_el_juego:
	ld a,(0fffeh)		;80e8   ; lo que dejo el buscador de RAM: la configuracion que pone RAM en todas las paginas
	out (0a8h),a		;80eb   ; puesta, y ya no se vuelve a tocar
	ld hl,0ba2eh		;80ed   ; la fuente normal
	ld (0a41eh),hl		;80f0   ; al puntero que usa la rutina de texto
	ld hl,07800h		;80f3   ; VRAM 0x3800 -el 0x4000 de mas es la marca de escritura-, que es donde el VDP quiere los patrones de sprite
	ld a,l			;80f6   ; la direccion, byte a byte
	out (099h),a		;80f7
	ld a,h			;80f9
	out (099h),a		;80fa
	ld hl,0be0eh		;80fc   ; los 64 patrones de sprite
	ld bc,00400h		;80ff   ; 0x400 bytes
vuelca_los_sprites:
	ld a,(hl)			;8102   ; uno a uno por el puerto de datos
	out (098h),a		;8103
	inc hl			;8105
	dec bc			;8106
	ld a,b			;8107
	or c			;8108
	jr nz,vuelca_los_sprites		;8109
	ld a,001h		;810b   ; el registro 7 a 0x01: borde y fondo negros
	out (099h),a		;810d
	ld a,087h		;810f
	out (099h),a		;8111
	ld a,(0f3e0h)		;8113   ; RG1SAV, la copia que el BIOS guarda del registro 1
	res 0,a		;8116   ; se le quita el bit 0 y se le pone el 1: sprites de 16x16 sin ampliar
	set 1,a		;8118
	out (099h),a		;811a   ; y se escribe en el registro 1
	ld a,081h		;811c
	out (099h),a		;811e
	jp el_bucle_principal		;8120   ; y al bucle principal, del que ya no se vuelve

; ----------------------------------------------------------------------
; EL SONIDO
; ----------------------------------------------------------------------
escribe_en_el_psg:
	push bc			;8123   ; c es el registro del PSG y a el valor
	ld b,a			;8124
	ld a,c			;8125
	out (0a0h),a		;8126   ; primero el numero de registro
	ld a,b			;8128
	out (0a1h),a		;8129   ; y luego el dato
	pop bc			;812b
	ret			;812c

; ----------------------------------------------------------------------
; DATOS periodos_del_psg: 60 words: siete a 0x0001 y 53 periodos, los que
;   0x823D indexa con la nota mas 0x0C. Acaban en 0x0038, y detras empieza ya
;   codigo
;   0x812d..0x81a5  (120 bytes)
DATA_periodos_del_psg:
	defw 00001h,00001h,00001h,00001h,00001h,00001h,00001h,00475h	; 812d
	defw 00435h,003f9h,003c0h,0038ah,00357h,00327h,002f9h,002cfh	; 813d
	defw 002a6h,00280h,0025ch,0023ah,0021ah,001fch,001e0h,001c5h	; 814d
	defw 001abh,00193h,0017ch,00167h,00153h,00140h,0012eh,0011dh	; 815d
	defw 0010dh,000feh,000f0h,000e2h,000d5h,000c9h,000beh,000b3h	; 816d
	defw 000a9h,000a0h,00097h,0008eh,00086h,0007fh,00078h,00071h	; 817d
	defw 0006ah,00064h,0005fh,00059h,00054h,00050h,0004bh,00047h	; 818d
	defw 00043h,0003fh,0003ch,00038h	; 819d

; ======================================================================
; CODIGO 0x81a5..0x81f8  (83 bytes)
; ======================================================================


L_81A5:
	ld a,(0838bh)		;81a5   ; si el canal 1 ya esta sonando, no se le pisa
	or a			;81a8
	ret nz			;81a9
	ld a,(de)			;81aa   ; el volumen de la pieza
	inc de			;81ab
	ld (081c6h),a		;81ac   ; ESCRITO DENTRO de la instruccion de 0x81C5
	ld (0838dh),de		;81af   ; el guion, apuntado
	ld a,001h		;81b3
	ld (0838bh),a		;81b5   ; y la marca de "hay algo sonando"
	ret			;81b8
toca_el_canal_1:
	ld c,007h		;81b9   ; el registro 7 del PSG: que canales suenan
	ld a,0b0h		;81bb
	ld (08291h),a		;81bd   ; el valor tambien se guarda, que el canal 2 lo lee
	call escribe_en_el_psg		;81c0
	ld c,006h		;81c3   ; el registro 6, el ruido
	ld a,01fh		;81c5
	call escribe_en_el_psg		;81c7
	ld a,(de)			;81ca   ; la nota, del guion de la pieza
	inc de			;81cb
	push af			;81cc
	ld a,(de)			;81cd   ; y detras su duracion
	inc de			;81ce
	ld (081ech),a		;81cf   ; QUE SE ESCRIBE DENTRO DE LA INSTRUCCION de 0x81C5: asi se le cambia el volumen al canal sin gastar una variable
	pop af			;81d2
	ld (0838dh),de		;81d3   ; por donde va la pieza
	inc a			;81d7   ; si la nota era 0xFF, se acaba
	call z,arranca_el_canal_1		;81d8
	call nota_a_periodo		;81db   ; la nota a periodo
L_81DE:
	ld c,001h		;81de   ; los registros 0 y 1, que son el tono del canal A
	ld a,d			;81e0
	call escribe_en_el_psg		;81e1
	dec c			;81e4
	ld a,e			;81e5
	call escribe_en_el_psg		;81e6
	ld c,008h		;81e9   ; y el registro 8, el volumen
	ld a,000h		;81eb
	jp escribe_en_el_psg		;81ed
arranca_el_canal_1:
	ld (0838bh),a		;81f0   ; se apaga la marca del canal
	ld (081ech),a		;81f3   ; y el volumen a cero
	inc a			;81f6
	ret			;81f7

; ----------------------------------------------------------------------
; DATOS pieza_de_arranque: 32 parejas (nota, duracion) de la musiquilla que
;   suena al empezar; la duracion es 0x0C en todas menos las dos ultimas, y el
;   0xFF de 0x8222 la parte en dos tramos
;   0x81f8..0x8238  (64 bytes)
DATA_pieza_de_arranque:
	defb 028h,00ch,026h,00ch,024h,00ch,021h,00ch,01eh,00ch,01ah,00ch,016h,00ch,012h,00ch	; 81f8  (.&.$.!.........
	defb 011h,00ch,010h,00ch,00fh,00ch,00eh,00ch,00dh,00ch,00ch,00ch,00bh,00ch,00bh,00ch	; 8208  ................
	defb 00ah,00ch,00ah,00ch,00ah,00ch,00ah,00ch,009h,00ch,0ffh,005h,00ch,005h,00ch,005h	; 8218  ................
	defb 00ch,006h,00ch,006h,00ch,006h,00ch,007h,00ch,007h,00ch,007h,00ch,00ch,00ch,0ffh	; 8228  ................

; ======================================================================
; CODIGO 0x8238..0x8291  (89 bytes)
; ======================================================================


nota_a_periodo:
	dec a			;8238   ; el 0 no es nota: es silencio
	jr z,L_823D		;8239
	add a,00ch		;823b   ; y las demas van doce entradas mas alla, que es el margen de la tabla
L_823D:
	ld hl,0812dh		;823d   ; la tabla de periodos
	ld d,000h		;8240
	ld e,a			;8242
	add hl,de			;8243
	add hl,de			;8244
	ld e,(hl)			;8245
	inc hl			;8246
	ld d,(hl)			;8247
	ret			;8248
L_8249:
	ld a,(0838ch)		;8249   ; lo mismo para el canal 2
	or a			;824c
	ret nz			;824d
	ld (0838fh),de		;824e   ; el guion
	ld a,001h		;8252
	ld (0838ch),a		;8254   ; y su marca
	ret			;8257
toca_el_canal_2:
	ld a,(de)			;8258   ; la nota del guion
	inc de			;8259
	push af			;825a
	ld a,(de)			;825b   ; y su duracion
	inc de			;825c
	ld (0838fh),de		;825d   ; por donde va
	ld (081ech),a		;8261   ; escrita DENTRO de la instruccion de 0x81EB, igual que el canal 1
	pop af			;8264
	inc a			;8265   ; con 0xFF se acaba la pieza
	jr nz,L_826F		;8266
	ld (0838ch),a		;8268
	ld (081ech),a		;826b
	inc a			;826e
L_826F:
	call nota_a_periodo		;826f   ; la nota a periodo
	ld c,00bh		;8272   ; el registro 11 del PSG: el periodo de la envolvente
	xor a			;8274
	call escribe_en_el_psg		;8275
	inc c			;8278
	ld a,003h		;8279   ; y el 12
	call escribe_en_el_psg		;827b
	inc c			;827e
	ld a,009h		;827f   ; el registro 13: la FORMA de la envolvente
	call escribe_en_el_psg		;8281
	ld c,007h		;8284   ; y el 7, que dice que canales suenan
	ld a,0b8h		;8286
	ld (08291h),a		;8288
	call escribe_en_el_psg		;828b
	jp L_81DE		;828e

; ----------------------------------------------------------------------
; DATOS volumen_del_canal_2: tres bytes de trabajo del segundo canal; 0x81BD
;   escribe en el primero
;   0x8291..0x8294  (3 bytes)
DATA_volumen_del_canal_2:
	defb 0b8h,000h,000h	; 8291

; ======================================================================
; CODIGO 0x8294..0x8383  (239 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LA MUSICA DE FONDO, A TRES VOCES
; ----------------------------------------------------------------------
la_musica_de_fondo:
	ld a,022h		;8294   ; la tecla 'M'
	call mira_una_tecla		;8296
	jr nz,L_82B4		;8299
	ld hl,08293h		;829b
	inc (hl)			;829e   ; el rebote de la tecla
	ld a,(hl)			;829f
	cp 00fh		;82a0   ; quince cuadros
	jr nz,L_82B9		;82a2
	ld (hl),000h		;82a4
	ld a,(08292h)		;82a6   ; y se le da la vuelta al conmutador
	xor 001h		;82a9
	ld (08292h),a		;82ab
	or 00ch		;82ae   ; de paso, el bit 4 del puerto 0xAB es el CLICK del teclado
	out (0abh),a		;82b0
	jr L_82B9		;82b2
L_82B4:
	ld a,00eh		;82b4
	ld (08293h),a		;82b6
L_82B9:
	ld a,(08292h)		;82b9
	or a			;82bc
	jr z,L_82CA		;82bd
	xor a			;82bf   ; con la musica apagada, los volumenes a cero y ya
	ld c,009h		;82c0
	call escribe_en_el_psg		;82c2
	xor a			;82c5
	inc c			;82c6
	jp escribe_en_el_psg		;82c7
L_82CA:
	ld hl,(08385h)		;82ca   ; la voz de arriba: por donde va
	ld a,(08387h)		;82cd   ; y cuanto le queda a la nota
	dec a			;82d0
	jr nz,L_82DE		;82d1
	ld a,01ah		;82d3   ; al cambiar de nota, el volumen vuelve a 0x1A
	ld (08389h),a		;82d5
	inc hl			;82d8
	ld a,00ch		;82d9   ; y doce cuadros por nota
	ld (08385h),hl		;82db
L_82DE:
	ld (08387h),a		;82de
	ld a,(hl)			;82e1   ; la nota
	and 03fh		;82e2   ; en seis bits
	ld hl,0812dh		;82e4   ; por la tabla de periodos
	ld e,a			;82e7
	ld d,000h		;82e8
	add hl,de			;82ea
	add hl,de			;82eb
	ld e,(hl)			;82ec
	inc hl			;82ed
	ld d,(hl)			;82ee
	exx			;82ef   ; al otro juego de registros: aqui van dos voces a la vez
	ld hl,(08383h)		;82f0   ; la voz de abajo, igual
	ld a,(08388h)		;82f3
	dec a			;82f6
	jr nz,L_8304		;82f7
	ld a,01ah		;82f9
	ld (0838ah),a		;82fb
	inc hl			;82fe
	ld (08383h),hl		;82ff
	ld a,00ch		;8302
L_8304:
	ld (08388h),a		;8304
	ld a,(hl)			;8307
	cp 0feh		;8308   ; el 0xFE del guion NO es final: es un cambio de tempo
	jr nz,L_831F		;830a
	ld hl,08390h		;830c   ; y se automodifican los dos `ld hl,08390h` de 0x8322 y 0x8328, mas las dos duraciones de 0x82DA y 0x8303: la pieza se reprograma sola
	ld (L_8322+1),hl		;830f
	ld (08329h),hl		;8312
	ld a,002h		;8315
	ld (082dah),a		;8317
	ld (08303h),a		;831a
	jr L_8322		;831d
L_831F:
	inc a			;831f   ; y el 0xFF si es el final
	jr nz,saca_las_tres_voces		;8320
L_8322:
	ld hl,08390h		;8322   ; las dos voces vuelven al principio
	ld (08383h),hl		;8325
	ld hl,08390h		;8328
	ld (08385h),hl		;832b
	ld a,001h		;832e
	ld (08387h),a		;8330
	ld (08388h),a		;8333
	jp la_musica_de_fondo		;8336
saca_las_tres_voces:
	dec a			;8339   ; la tercera voz, la que lleva la melodia
	ld hl,0812dh		;833a
	and 03fh		;833d
	ld d,000h		;833f
	ld e,a			;8341   ; la nota, en la tabla de periodos
	add hl,de			;8342
	add hl,de			;8343
	ld e,(hl)			;8344
	inc hl			;8345
	ld d,(hl)			;8346
	ld c,007h		;8347   ; el registro 7
	ld a,(08291h)		;8349
	call escribe_en_el_psg		;834c   ; el registro 7 del PSG
	ld c,004h		;834f   ; los registros 4 y 5: el tono del canal C
	ld a,e			;8351   ; el periodo bajo
	call escribe_en_el_psg		;8352
	inc c			;8355
	ld a,d			;8356
	call escribe_en_el_psg		;8357
	exx			;835a
	ld c,002h		;835b   ; los 2 y 3: el canal B
	ld a,e			;835d
	call escribe_en_el_psg		;835e
	inc c			;8361
	ld a,d			;8362   ; y el alto de la otra voz
	call escribe_en_el_psg		;8363
	ld c,009h		;8366   ; el registro 9, el volumen del canal B
	ld a,(08389h)		;8368
	dec a			;836b   ; que va bajando cuadro a cuadro
	jr z,L_8371		;836c
	ld (08389h),a		;836e   ; el volumen, que baja solo
L_8371:
	rra			;8371   ; entre dos, para que la nota se apague sola
	call escribe_en_el_psg		;8372
	inc c			;8375   ; y el 10, el del canal C
	ld a,(0838ah)		;8376
	dec a			;8379
	jr z,L_837F		;837a
	ld (0838ah),a		;837c
L_837F:
	rra			;837f
	jp escribe_en_el_psg		;8380

; ----------------------------------------------------------------------
; DATOS estado_de_la_musica: las dos voces: en 0x838B y 0x838C las marcas de
;   "hay algo sonando" y en 0x838D y 0x838F los punteros por donde van; los
;   cuatro primeros bytes traen 0x8390 de fabrica
;   0x8383..0x8393  (16 bytes)
DATA_estado_de_la_musica:
	defb 090h,083h	; 8383
	defb 090h,083h	; 8385
	defb 001h,001h	; 8387
	defb 00fh,00fh	; 8389
	defb 000h,000h	; 838b
	defb 000h,000h	; 838d
	defb 000h,000h	; 838f
	defb 000h,0ffh	; 8391

; ======================================================================
; CODIGO 0x8393..0x83b6  (35 bytes)
; ======================================================================


arranca_la_musica_de_fondo:
	ld a,005h		;8393   ; cinco cuadros por nota
	ld (082dah),a		;8395
	ld (08303h),a		;8398
	ld hl,l83b5h		;839b   ; las dos voces, al principio de su guion
	ld (08383h),hl		;839e
	ld (08323h),hl		;83a1
	ld hl,08506h		;83a4   ; y la tercera, al suyo
	ld (08329h),hl		;83a7
	ld (08385h),hl		;83aa
	ld a,001h		;83ad
	ld (08387h),a		;83af
	ld (08388h),a		;83b2
L_83B5:
	ret			;83b5

; ----------------------------------------------------------------------
; DATOS hueco_antes_de_la_musica: doce bytes a cero entre el final del codigo
;   y el principio de las piezas
;   0x83b6..0x83c2  (12 bytes)
DATA_hueco_antes_de_la_musica:
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 83b6  ............

; ----------------------------------------------------------------------
; DATOS piezas_de_musica: las listas de indices de nota que 0x81B9 y 0x8258
;   tocan por la tabla de periodos de 0x812D
;   0x83c2..0x8658  (662 bytes)
DATA_piezas_de_musica:
	defb 00eh,012h,015h,014h,014h,015h,00eh,012h,015h,014h,014h,015h,01ah,01eh,021h,020h	; 83c2  ..............! 
	defb 020h,021h,01ah,01eh,021h,020h,020h,021h,026h,02ah,02dh,02ch,02ch,02dh,026h,02ah	; 83d2   !..!  !&*-,,-&*
	defb 02dh,02ch,02ch,02dh,026h,025h,024h,023h,022h,021h,023h,022h,021h,020h,01fh,01eh	; 83e2  -,,-&%$#"!#"! ..
	defb 021h,020h,01fh,01eh,01dh,01ch,01ah,01ah,01ah,01ah,01ah,01ah,02bh,02ah,029h,028h	; 83f2  ! ..........+*)(
	defb 027h,026h,028h,027h,026h,025h,024h,023h,026h,025h,024h,023h,022h,021h,01fh,01fh	; 8402  '&('&%$#&%$#"!..
	defb 01fh,01fh,01fh,01fh,015h,015h,019h,018h,018h,019h,015h,015h,019h,018h,018h,019h	; 8412  ................
	defb 01ah,026h,02ah,029h,029h,02ah,01ah,026h,02ah,029h,029h,02ah,01ch,028h,02ch,02bh	; 8422  .&*))*.&*))*.(,+
	defb 02bh,02ch,01ch,028h,02ch,02bh,02bh,02ch,02dh,02ch,02bh,02ah,029h,028h,027h,026h	; 8432  +,.(,++,-,+*)('&
	defb 025h,024h,023h,022h,025h,021h,01ch,01ch,000h,025h,023h,020h,01ch,01ch,000h,023h	; 8442  %$#"%!...%# ...#
	defb 021h,01eh,01ah,01ah,000h,021h,020h,023h,028h,02ch,02dh,02fh,031h,02dh,028h,028h	; 8452  !....! #(,-/1-((
	defb 000h,031h,02fh,02ch,028h,028h,000h,02fh,02dh,02ah,026h,026h,000h,02dh,02ch,028h	; 8462  .1/,((./-*&&.-,(
	defb 02ah,02ch,02dh,02fh,031h,031h,028h,028h,021h,021h,02fh,02fh,028h,028h,020h,020h	; 8472  *,-/11((!!//((  
	defb 02dh,02dh,026h,026h,01eh,01eh,02ch,02ch,023h,023h,01ch,01ch,031h,031h,028h,028h	; 8482  --&&..,,##..11((
	defb 021h,021h,02fh,02fh,028h,028h,020h,020h,02dh,02dh,026h,026h,01eh,01eh,02ch,028h	; 8492  !!//((  --&&..,(
	defb 02fh,032h,031h,02fh,025h,02dh,031h,030h,030h,031h,025h,02dh,031h,030h,030h,031h	; 84a2  /21/%-1001%-1001
	defb 023h,02ch,02fh,02eh,02eh,02fh,023h,02ch,02fh,02eh,02eh,02fh,025h,02dh,031h,030h	; 84b2  #,/../#,/../%-10
	defb 030h,031h,025h,02dh,031h,030h,030h,031h,023h,02ch,02fh,02eh,02eh,02fh,000h,02ch	; 84c2  01%-1001#,/../.,
	defb 02fh,032h,031h,02fh,031h,031h,028h,028h,028h,028h,028h,028h,021h,021h,021h,021h	; 84d2  /21/11((((((!!!!
	defb 000h,028h,02ah,02ch,02dh,02fh,02dh,02ch,02bh,02ah,029h,028h,027h,026h,025h,024h	; 84e2  .(*,-/-,+*)('&%$
	defb 023h,022h,021h,020h,01fh,01eh,01dh,01ch,000h,021h,01fh,01eh,01ch,01ah,000h,01fh	; 84f2  #"! .....!......
	defb 01eh,01ch,01ah,019h,0ffh,002h,006h,009h,048h,048h,009h,002h,006h,009h,048h,048h	; 8502  ........HH....HH
	defb 009h,002h,006h,009h,048h,048h,009h,002h,006h,009h,048h,048h,009h,002h,006h,009h	; 8512  ....HH....HH....
	defb 048h,048h,009h,002h,006h,009h,048h,048h,009h,002h,006h,009h,048h,048h,009h,002h	; 8522  HH....HH....HH..
	defb 006h,009h,048h,048h,009h,002h,006h,009h,088h,088h,089h,002h,006h,009h,088h,088h	; 8532  ..HH............
	defb 089h,002h,006h,009h,088h,088h,089h,082h,006h,009h,008h,008h,009h,007h,00bh,00eh	; 8542  ................
	defb 08dh,08dh,08eh,007h,00bh,00eh,08dh,08dh,08eh,007h,00bh,00eh,08dh,08dh,08eh,087h	; 8552  ................
	defb 00bh,00eh,00dh,00dh,00eh,009h,00dh,010h,04fh,04fh,010h,009h,00dh,010h,04fh,04fh	; 8562  ........OO....OO
	defb 010h,00eh,012h,015h,054h,054h,015h,00eh,012h,015h,054h,054h,015h,010h,014h,017h	; 8572  ....TT....TT....
	defb 056h,056h,017h,010h,014h,017h,056h,056h,017h,000h,000h,000h,040h,000h,000h,000h	; 8582  VV....VV....@...
	defb 000h,000h,040h,000h,000h,00dh,009h,004h,08dh,089h,004h,00bh,008h,004h,08bh,088h	; 8592  ..@.............
	defb 004h,009h,006h,002h,089h,086h,002h,008h,00bh,010h,094h,095h,017h,019h,015h,010h	; 85a2  ................
	defb 099h,095h,010h,017h,014h,010h,097h,094h,010h,015h,012h,00eh,095h,092h,00eh,014h	; 85b2  ................
	defb 010h,012h,094h,096h,017h,000h,02dh,02dh,025h,025h,01ch,01ch,02ch,02ch,023h,023h	; 85c2  ......--%%..,,##
	defb 01ch,01ch,02ah,02ah,021h,021h,01ah,01ah,028h,028h,0a0h,0a0h,097h,097h,02dh,02dh	; 85d2  ..**!!..((....--
	defb 025h,025h,01ch,01ch,02ch,02ch,023h,023h,01ch,01ch,02ah,02ah,021h,021h,01ah,000h	; 85e2  %%..,,##..**!!..
	defb 000h,020h,0e3h,0e1h,0e0h,0d9h,01ch,021h,060h,060h,021h,099h,01ch,021h,060h,060h	; 85f2  . .....!``!..!``
	defb 021h,097h,01ch,020h,05fh,05fh,020h,097h,01ch,020h,05fh,05fh,020h,099h,01ch,021h	; 8602  !.. __ .. __ ..!
	defb 060h,060h,021h,099h,01ch,021h,060h,060h,021h,097h,01ch,020h,05fh,05fh,020h,097h	; 8612  ``!..!``!.. __ .
	defb 01ch,01fh,063h,021h,020h,000h,02dh,02dh,02dh,02dh,025h,025h,025h,025h,025h,025h	; 8622  ..c! .----%%%%%%
	defb 01ch,01ch,01ch,01ah,017h,014h,010h,055h,055h,000h,000h,000h,000h,080h,080h,080h	; 8632  .......UU.......
	defb 080h,000h,000h,0c0h,0c0h,0c0h,0c0h,000h,000h,01ah,01ah,01ah,01ah,000h,000h,019h	; 8642  ................
	defb 019h,019h,019h,000h,005h,0ffh	; 8652

; ----------------------------------------------------------------------
; DATOS variables_de_trabajo: 202 bytes de la propia imagen del juego usados
;   como RAM; en la cinta vienen casi todos a cero
;   0x8658..0x8722  (202 bytes)
DATA_variables_de_trabajo:
	defb 047h,046h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 8658  GF..............
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 8668  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 8678  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 8688  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 8698  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 86a8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 86b8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 86c8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 86d8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 86e8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 86f8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,016h,087h	; 8708  ................
	defb 001h,003h,014h,0b0h,001h,000h,088h,02fh,000h,000h	; 8718  ......./..

; ----------------------------------------------------------------------
; DATOS curva_de_salto_larga: 52 filas de sprite, de 0xBE a 0x80 y vuelta,
;   cerrada con 0xFF; es la mas larga y la tabla de 0x87E8 no la apunta
;   0x8722..0x8757  (53 bytes)
DATA_curva_de_salto_larga:
	defb 0beh,0b7h,0b0h,0a7h,0a1h,09ch,098h,094h,090h,08bh,088h,086h,085h,084h,083h,082h,081h,081h,080h,080h	; 8722  ....................
	defb 080h,080h,080h,080h,080h,080h,081h,081h,082h,083h,084h,085h,086h,088h,08bh,090h,094h,098h,09ch,0a1h	; 8736  ....................
	defb 0a7h,0afh,0abh,0a9h,0a8h,0a8h,0a8h,0a8h,0a8h,0a9h,0abh,0afh,0ffh	; 874a  .............

; ----------------------------------------------------------------------
; DATOS curva_de_salto_0: cuarenta filas de sprite, el salto mas alto;
;   simetrica y cerrada con 0xFF
;   0x8757..0x877f  (40 bytes)
DATA_curva_de_salto_0:
	defb 0aah,0a4h,0a0h,09ch,09ah,098h,096h,095h,094h,093h,093h,093h,093h,093h,093h,094h,095h,096h,098h,09ah	; 8757  ....................
	defb 09ch,0a0h,0a4h,0aah,0afh,0aeh,0adh,0ach,0ach,0ach,0adh,0adh,0aeh,0afh,0aeh,0adh,0adh,0aeh,0afh,0ffh	; 876b  ....................

; ----------------------------------------------------------------------
; DATOS curva_de_salto_1: treinta filas de sprite, de 0xAA a 0x9D y vuelta
;   0x877f..0x879d  (30 bytes)
DATA_curva_de_salto_1:
	defb 0aah,0a7h,0a4h,0a2h,0a0h,09fh,09eh,09dh,09dh,09dh,09dh,09dh,09eh,09fh,0a0h,0a2h,0a4h,0a7h,0aah,0afh	; 877f  ....................
	defb 0adh,0ach,0abh,0abh,0abh,0abh,0ach,0aeh,0afh,0ffh	; 8793  ..........

; ----------------------------------------------------------------------
; DATOS curva_de_salto_2: veintitres filas de sprite, de 0xAB a 0xA0 y vuelta
;   0x879d..0x87b4  (23 bytes)
DATA_curva_de_salto_2:
	defb 0abh,0a7h,0a5h,0a3h,0a2h,0a1h,0a0h,0a0h,0a0h,0a1h,0a2h,0a3h,0a5h,0a7h,0aah,0afh,0aeh,0adh,0adh,0adh	; 879d  ....................
	defb 0aeh,0afh,0ffh	; 87b1

; ----------------------------------------------------------------------
; DATOS curva_de_salto_3: veintiuna filas de sprite, de 0xAB a 0xA4 y vuelta
;   0x87b4..0x87c9  (21 bytes)
DATA_curva_de_salto_3:
	defb 0abh,0a9h,0a7h,0a6h,0a5h,0a4h,0a4h,0a4h,0a4h,0a5h,0a6h,0a7h,0a9h,0abh,0afh,0aeh,0adh,0adh,0aeh,0afh	; 87b4  ....................
	defb 0ffh	; 87c8

; ----------------------------------------------------------------------
; DATOS curva_de_salto_4: dieciocho filas de sprite, de 0xAC a 0xA8 y vuelta
;   0x87c9..0x87db  (18 bytes)
DATA_curva_de_salto_4:
	defb 0ach,0aah,0a9h,0a8h,0a8h,0a8h,0a8h,0a8h,0a9h,0aah,0ach,0afh,0aeh,0aeh,0adh,0aeh,0afh,0ffh	; 87c9  ..................

; ----------------------------------------------------------------------
; DATOS curva_de_salto_5: trece filas, el salto mas corto
;   0x87db..0x87e8  (13 bytes)
DATA_curva_de_salto_5:
	defb 0aeh,0adh,0ach,0ach,0ach,0ach,0adh,0aeh,0afh,0aeh,0aeh,0afh,0ffh	; 87db  .............

; ----------------------------------------------------------------------
; DATOS tabla_de_curvas_de_salto: ocho punteros a las curvas de arriba; las
;   tres ultimas entradas repiten la mas larga, asi que de ocho saltos solo
;   salen seis curvas
;   0x87e8..0x87f8  (16 bytes)
DATA_tabla_de_curvas_de_salto:
	defw 087dbh,087c9h,087b4h,0879dh,0877fh,08757h,08757h,08757h	; 87e8

; ----------------------------------------------------------------------
; DATOS textos_del_final: nueve cadenas con el final en el bit 7: 'GAME OVER
;   ........', 'DISQUALIFIED .....', 'NIFTY CONTROL THERE', 'ALL LEVELS DONE',
;   'NO RELAXING NOW!', 'BOUNCE AROUND AGAIN', 'WELL THAT WAS EASY' y 'GO PLAY
;   THE ARCADE'
;   0x87f8..0x8887  (143 bytes)
DATA_textos_del_final:
	defb 047h,041h,04dh,045h,020h,04fh,056h,045h,052h,020h,02eh,02eh,02eh,02eh,02eh,02eh	; 87f8  GAME OVER ......
	defb 02eh,02eh,0aeh,044h,049h,053h,051h,055h,041h,04ch,049h,046h,049h,045h,044h,020h	; 8808  ...DISQUALIFIED 
	defb 02eh,02eh,02eh,02eh,02eh,0aeh,04eh,049h,046h,054h,059h,020h,043h,04fh,04eh,054h	; 8818  ......NIFTY CONT
	defb 052h,04fh,04ch,020h,054h,048h,045h,052h,0c5h,041h,04ch,04ch,020h,04ch,045h,056h	; 8828  ROL THER.ALL LEV
	defb 045h,04ch,053h,020h,044h,04fh,04eh,0c5h,04eh,04fh,020h,052h,045h,04ch,041h,058h	; 8838  ELS DON.NO RELAX
	defb 049h,04eh,047h,020h,04eh,04fh,057h,0a1h,042h,04fh,055h,04eh,043h,045h,020h,041h	; 8848  ING NOW.BOUNCE A
	defb 052h,04fh,055h,04eh,044h,020h,041h,047h,041h,049h,0ceh,057h,045h,04ch,04ch,020h	; 8858  ROUND AGAI.WELL 
	defb 054h,048h,041h,054h,020h,057h,041h,053h,020h,045h,041h,053h,0d9h,047h,04fh,020h	; 8868  THAT WAS EAS.GO 
	defb 050h,04ch,041h,059h,020h,054h,048h,045h,020h,041h,052h,043h,041h,044h,0c5h	; 8878  PLAY THE ARCAD.

; ----------------------------------------------------------------------
; DATOS iniciales_de_la_tabla_de_records: catorce letras, 'EGFNDGVFODEFMW':
;   una inicial por cada puesto de la tabla de puntuaciones que trae el juego
;   de fabrica
;   0x8887..0x8895  (14 bytes)
DATA_iniciales_de_la_tabla_de_records:
	defb 045h,047h,046h,04eh,044h,047h,056h,046h,04fh,044h,045h,046h,04dh,057h	; 8887  EGFNDGVFODEFMW

; ----------------------------------------------------------------------
; DATOS rotulo_del_reloj: '00:00' y los espacios de la linea del cronometro
;   0x8895..0x88a0  (11 bytes)
DATA_rotulo_del_reloj:
	defb 030h,030h,03ah,030h,0b0h,020h,020h,020h,020h,020h,020h	; 8895  00:0.      

; ----------------------------------------------------------------------
; DATOS mascaras_de_bit: 0xA0 0x80 0x40 0x20 0x10 0x08 0x04 0x02 0x01: los
;   ocho bits de un byte, con un 0xA0 delante
;   0x88a0..0x88a9  (9 bytes)
DATA_mascaras_de_bit:
	defb 0a0h,080h,040h,020h,010h,008h,004h,002h,001h	; 88a0  ..@ .....

; ----------------------------------------------------------------------
; DATOS mascaras_de_bit_negadas: las mismas del reves, para apagar en vez de
;   encender
;   0x88a9..0x88b1  (8 bytes)
DATA_mascaras_de_bit_negadas:
	defb 07fh,0bfh,0dfh,0efh,0f7h,0fbh,0fdh,0feh	; 88a9  ........

; ----------------------------------------------------------------------
; DATOS tabla_de_valores_pequenos: 34 bytes de valores de 0 a 7
;   0x88b1..0x88d3  (34 bytes)
DATA_tabla_de_valores_pequenos:
	defb 003h,005h,004h,000h,004h,000h,004h,005h,006h,005h,006h,005h,005h,007h,005h,005h,005h	; 88b1  .................
	defb 000h,003h,000h,002h,000h,003h,000h,003h,005h,003h,005h,091h,04eh,000h,002h,017h,00bh	; 88c2  ............N....

; ----------------------------------------------------------------------
; DATOS plantilla_de_0xfb00: ocho bytes que 0x890F copia treinta y dos veces
;   seguidas a la RAM en 0xFB00
;   0x88d3..0x88db  (8 bytes)
DATA_plantilla_de_0xfb00:
	defb 000h,060h,0a0h,050h,070h,090h,020h,0e0h	; 88d3  .`.Pp. .

; ----------------------------------------------------------------------
; DATOS plantilla_de_0xfc00: otros ocho, que 0x8920 copia treinta y dos veces
;   a 0xFC00
;   0x88db..0x88e3  (8 bytes)
DATA_plantilla_de_0xfc00:
	defb 000h,006h,00ah,005h,007h,009h,002h,00eh	; 88db  ........

; ----------------------------------------------------------------------
; DATOS marca_de_estado: un byte que el codigo escribe diez veces
;   0x88e3..0x88e4  (1 bytes)
DATA_marca_de_estado:
	defb 000h	; 88e3

; ======================================================================
; CODIGO 0x88e4..0x8e2d  (1353 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL BUCLE PRINCIPAL Y LA INTERRUPCION EN MODO 2
; ----------------------------------------------------------------------
el_bucle_principal:
	di			;88e4   ; nada de interrupciones hasta tener la tabla de vectores montada
	call arranca_la_musica_de_fondo		;88e5
	ld hl,0fd00h		;88e8   ; 0xFD00, que va a ser la tabla de vectores
	ld bc,00100h		;88eb   ; 257 bytes...
	ld (hl),0feh		;88ee   ; ...todos con el mismo valor, 0xFE, con el LDIR solapado de siempre
	ld d,h			;88f0
	ld e,l			;88f1
	inc de			;88f2
	ldir		;88f3
	ld hl,0fb18h		;88f5   ; 0xFB18, que como instruccion es `jr $-5`
	ld (0fefeh),hl		;88f8   ; a 0xFEFE, que es adonde manda el vector
	ld hl,09134h		;88fb   ; y el destino de verdad
	ld (0fefch),hl		;88fe   ; en 0xFEFC
	ld a,0c3h		;8901   ; con un 0xC3 delante: `jp 09134h`
	ld (0fefbh),a		;8903
	ld b,020h		;8906   ; EL RODEO: el vector de 0xFDFE vale 0xFEFE; en 0xFEFE hay un `jr $-5` que cae en 0xFEFB; y en 0xFEFB hay el `jp`. Asi la tabla de 257 bytes es un solo byte repetido
	ld a,0fdh		;8908   ; la pagina de la tabla
	ld i,a		;890a   ; al registro I
	ld de,0fb00h		;890c
llena_0xfb00:
	push bc			;890f   ; treinta y dos copias de los ocho bytes de 0x88D3
	ld hl,088d3h		;8910
	ld bc,00008h		;8913
	ldir		;8916
	pop bc			;8918
	djnz llena_0xfb00		;8919
	ld b,020h		;891b
	ld de,0fc00h		;891d
llena_0xfc00:
	push bc			;8920   ; y otras treinta y dos de los de 0x88DB
	ld hl,088dbh		;8921
	ld bc,00008h		;8924
	ldir		;8927
	pop bc			;8929
	djnz llena_0xfc00		;892a
	ld hl,05b00h		;892c   ; 128 words en 0x5B00
	ld b,080h		;892f
	xor a			;8931
llena_la_tabla_de_0x5b00:
	push bc			;8932   ; que se calculan uno a uno
	push af			;8933
	push hl			;8934
	call pixel_a_direccion_de_vram		;8935   ; con la rutina de 0x8D02
	ld a,h			;8938
	ld c,l			;8939
	pop hl			;893a
	ld (hl),c			;893b
	inc hl			;893c
	ld (hl),a			;893d
	inc hl			;893e
	pop af			;893f
	pop bc			;8940
	inc a			;8941
	djnz llena_la_tabla_de_0x5b00		;8942

; ----------------------------------------------------------------------
; UNA PARTIDA
; ----------------------------------------------------------------------
empieza_una_partida:
	xor a			;8944   ; la partida empieza aqui, y aqui se vuelve al acabar
	ld (0965bh),a		;8945   ; marcadores a cero
	ld (08682h),a		;8948
	call la_pantalla_del_titulo		;894b   ; la pantalla de presentacion
	ld a,001h		;894e
	ld (088e3h),a		;8950
	ld de,0a5e9h		;8953   ; el rotulo de la puntuacion
	ld hl,08895h		;8956
	call pinta_un_rotulo		;8959
	ld de,0a629h		;895c   ; y los dos de los tiempos
	ld hl,08895h		;895f
	call pinta_un_rotulo		;8962
	ld de,0a669h		;8965
	ld hl,08895h		;8968
	call pinta_un_rotulo		;896b
	ld de,0a61eh		;896e
	ld hl,0889ah		;8971
	call pinta_un_rotulo		;8974
	im 2		;8977   ; modo 2 de interrupcion: el vector lo pone el hardware sobre la tabla de 0xFD00
	call monta_la_pantalla_de_juego		;8979   ; a jugar
	ld a,001h		;897c
	ld (088e3h),a		;897e
	call L_9ABC		;8981   ; y al acabar, la tabla de records
	jr empieza_una_partida		;8984   ; y vuelta a empezar
monta_la_pantalla_de_juego:
	ld hl,0865ah		;8986   ; las variables de trabajo, de 0x865A en adelante
	ld de,0865bh		;8989
	ld bc,00037h		;898c   ; 55 bytes
	ld (hl),000h		;898f   ; a cero de un golpe
	ldir		;8991
	ld hl,08688h		;8993
	ld a,010h		;8996
	ld (08c02h),a		;8998   ; SE ESCRIBE DENTRO DE UNA INSTRUCCION: 0x8C02 es el operando del `add a,h` que elige la pagina de la tabla de perspectiva
	call bola_al_suelo		;899b
	call borra_la_pantalla		;899e
	ld hl,058e0h		;89a1   ; la ultima fila de la pantalla
	xor a			;89a4
	ld bc,00220h		;89a5   ; a cero
	call rellena_color		;89a8
	ld hl,0a5afh		;89ab   ; los patrones del juego
	ld de,04000h		;89ae   ; a la VRAM 0x0000
	ld bc,00800h		;89b1
	call vuelca_a_la_vram		;89b4
	ld hl,0adafh		;89b7   ; y la primera banda de la rejilla
	ld bc,00100h		;89ba
	ld de,05800h		;89bd   ; a la VRAM 0x1800
	call vuelca_a_la_vram		;89c0
L_89C3:
	ld a,0ffh		;89c3   ; la marca de "hay que montar todo"
	ld (08676h),a		;89c5
L_89C8:
	ld a,001h		;89c8
	ld (088e3h),a		;89ca
	ld a,0bfh		;89cd   ; la velocidad de salida
	ld (0871bh),a		;89cf
	call la_bola_se_cae		;89d2   ; la bola, al suelo
	xor a			;89d5
	ld (0865ah),a		;89d6
	ld (08675h),a		;89d9
	ld (08682h),a		;89dc
	inc a			;89df   ; y la marca de nivel nuevo
	ld (0868ch),a		;89e0
	ld hl,08676h		;89e3   ; la cuenta de niveles, uno mas
	inc (hl)			;89e6
	ld a,(08720h)		;89e7   ; si esto es la prueba de tres pistas
	or a			;89ea
	jr nz,L_89F7		;89eb
	ld a,(08677h)		;89ed   ; con tres hechas, se acaba
	cp 003h		;89f0
	jp z,se_acabo_la_prueba		;89f2
	jr L_89FD		;89f5
L_89F7:
	ld a,(hl)			;89f7
	cp 00eh		;89f8   ; y si es la partida entera, con catorce
	jp z,se_acabaron_las_catorce		;89fa
L_89FD:
	call empieza_una_pista		;89fd
	ld a,007h		;8a00   ; siete vidas
	ld (08658h),a		;8a02
	ld a,004h		;8a05   ; y cuatro saltos
	ld (08721h),a		;8a07
	call pinta_las_vidas		;8a0a
	ld hl,058e0h		;8a0d
	ld bc,00220h		;8a10
	xor a			;8a13
	call rellena_color		;8a14
	call la_rejilla_a_la_vram		;8a17   ; la rejilla de la pista, a la VRAM
	call pinta_los_catorce		;8a1a
	ld b,020h		;8a1d   ; treinta y dos vueltas de la cuenta atras
L_8A1F:
	push bc			;8a1f
	call avanza_la_pista_un_paso		;8a20
	call mueve_las_estrellas_de_fondo		;8a23
	pop bc			;8a26
	djnz L_8A1F		;8a27
	ld a,(08658h)		;8a29   ; las vidas que quedan
	ld hl,058e0h		;8a2c
	ld bc,00220h		;8a2f
	xor a			;8a32
	ld (088e3h),a		;8a33
	call la_interrupcion		;8a36   ; un cuadro entero, a mano, sin esperar a la interrupcion
	ld a,003h		;8a39
	ld (08678h),a		;8a3b   ; tres
	xor a			;8a3e
	ld (0865ah),a		;8a3f
L_8A42:
	ld a,(08668h)		;8a42
	or a			;8a45
	jr nz,la_bola_se_ha_perdido		;8a46
	ld (09658h),a		;8a48
	ld a,031h		;8a4b   ; la tecla CTRL: fila 6, bit 1
	call mira_una_tecla		;8a4d
	jr nz,L_8A5A		;8a50
	ld a,03ch		;8a52   ; y la STOP: fila 7, bit 4. LAS DOS A LA VEZ ABANDONAN LA PARTIDA, y es la unica combinacion de teclas del juego. Medido en la maquina: cinco segundos jugando sin tocar nada no pasan por 0x8AC1, y apretandolas si
	call mira_una_tecla		;8a54
	jp z,L_8AC1		;8a57
L_8A5A:
	call remata_la_pista		;8a5a
	ld a,(08675h)		;8a5d
	or a			;8a60
	jp nz,L_89C8		;8a61
	jp L_8A42		;8a64
la_bola_se_ha_perdido:
	ld a,001h		;8a67   ; mientras se monta, la interrupcion no pinta
	ld (088e3h),a		;8a69
	ld hl,087f8h		;8a6c   ; 'GAME OVER ........'
	ld bc,00904h		;8a6f
	ld a,(08720h)		;8a72   ; en la partida entera se pinta el mejor tiempo
	or a			;8a75
	jr nz,L_8A7E		;8a76
	call pinta_el_mejor_tiempo		;8a78
	ld hl,0880bh		;8a7b   ; y en la prueba, 'DISQUALIFIED .....'
L_8A7E:
	call pinta_un_texto		;8a7e
	ld hl,06800h		;8a81   ; la tabla de atributos de sprite
	ld a,l			;8a84
	out (099h),a		;8a85
	ld a,h			;8a87
	out (099h),a		;8a88
	ld bc,00400h		;8a8a   ; 0x400 bytes
borra_los_sprites:
	ld a,0e0h		;8a8d   ; 0xE0 en todos: fuera de la pantalla
	out (098h),a		;8a8f
	dec bc			;8a91
	ld a,b			;8a92
	or c			;8a93
	jr nz,borra_los_sprites		;8a94
	call pinta_el_reloj		;8a96   ; y el reloj se deja pintado
	ld b,050h		;8a99   ; ochenta cuadros de pausa
L_8A9B:
	ei			;8a9b
	halt			;8a9c   ; con `halt`, que gasta menos que un bucle
	djnz L_8A9B		;8a9d
	jr L_8AC1		;8a9f
remata_la_pista:
	ld hl,0865ah		;8aa1   ; la puntuacion de la pista
	ld a,(08720h)		;8aa4   ; en la prueba de tres pistas
	or a			;8aa7
	jr z,pinta_el_final_de_pista		;8aa8
	ld a,(hl)			;8aaa   ; la puntuacion de la pista
	ld (hl),000h		;8aab
	or a			;8aad
	call nz,numero_a_digitos		;8aae   ; que se le suma al total
pinta_el_final_de_pista:
	ld a,(08720h)		;8ab1   ; en la partida entera se pinta la puntuacion
	or a			;8ab4
	push af			;8ab5
	call nz,pinta_la_puntuacion		;8ab6
	call pinta_el_reloj		;8ab9   ; el reloj, siempre
	pop af			;8abc
	ret nz			;8abd
	jp pinta_el_mejor_tiempo		;8abe   ; y en la prueba de tres, el mejor tiempo
L_8AC1:
	ld a,001h		;8ac1
	ld (088e3h),a		;8ac3
	ld de,04000h		;8ac6   ; y de paso se recupera de la VRAM lo que habia
	ld hl,0a5afh		;8ac9   ; y los patrones, recuperados de la VRAM
	ld bc,00800h		;8acc
	call lee_de_la_vram		;8acf
	ret			;8ad2

; ----------------------------------------------------------------------
; EL AVANCE DE LA PISTA: cinco bandas a cinco velocidades
; ----------------------------------------------------------------------
avanza_la_pista_un_paso:
	ld hl,0865ah		;8ad3   ; el contador de cuadros
	inc (hl)			;8ad6
	ld a,(0868bh)		;8ad7
	inc a			;8ada   ; el contador de cuadros
	ld (0868bh),a		;8adb
	ld a,(08718h)		;8ade   ; el contador de ocho...
	inc a			;8ae1   ; el de ocho
	and 007h		;8ae2
	ld (08718h),a		;8ae4
	srl a		;8ae7   ; ...entre dos, que es el balanceo de la bola
	ld (08719h),a		;8ae9
	ld a,(08689h)		;8aec   ; cada dieciseis pasos, la pista avanza una fila entera
	inc a			;8aef   ; y el de dieciseis
	and 00fh		;8af0
	jr nz,L_8AF6		;8af2
	inc iy		;8af4
L_8AF6:
	push iy		;8af6
	ld (08689h),a		;8af8
	call fila_de_delante		;8afb   ; LAS CINCO BANDAS. La de delante se repinta DOS veces por paso, la siguiente una, la tercera una de cada dos, la cuarta una de cada cuatro y la del fondo una de cada ocho: eso es la perspectiva, y no cuesta ni una multiplicacion
	call fila_de_delante		;8afe
	inc iy		;8b01
	call fila_media		;8b03   ; la segunda banda
	inc iy		;8b06
	call fila_de_atras		;8b08   ; la tercera
	inc iy		;8b0b
	call fila_del_fondo		;8b0d   ; la cuarta
	inc iy		;8b10
	ld a,(iy+000h)		;8b12   ; el 0xFF de la pista dice que se acabo
	cp 0ffh		;8b15
	jr nz,L_8B1E		;8b17
	ld a,001h		;8b19
	ld (08675h),a		;8b1b   ; y se apunta
L_8B1E:
	call fila_del_horizonte		;8b1e   ; la del fondo
	inc iy		;8b21
	call L_8BA4		;8b23
	pop iy		;8b26
	push iy		;8b28
	ld a,(08688h)		;8b2a   ; con la bola por encima de 0x18
	cp 018h		;8b2d
	jr nc,L_8B33		;8b2f
	dec iy		;8b31   ; la pista se lee una fila mas atras
L_8B33:
	ld a,(0871bh)		;8b33   ; si la bola esta en el suelo
	cp 0afh		;8b36
	call z,altura_a_fila_de_pista		;8b38   ; se mira que casilla pisa
	pop iy		;8b3b
	ld (08716h),iy		;8b3d   ; y la ficha, guardada
	ret			;8b41
fila_de_delante:
	ld a,(08688h)		;8b42   ; la banda de delante, de 32 filas
	inc a			;8b45   ; una fila mas
	and 01fh		;8b46
	ld (08688h),a		;8b48
	add a,01fh		;8b4b   ; la fila de pantalla que le toca
	cp 038h		;8b4d   ; con tope en 0x38
	ret nc			;8b4f
	jp pinta_una_fila_de_pista		;8b50
fila_media:
	ld a,(08687h)		;8b53   ; la segunda, de 16
	inc a			;8b56   ; la segunda banda
	and 00fh		;8b57
	ld (08687h),a		;8b59
	add a,00fh		;8b5c
	jp pinta_una_fila_de_pista		;8b5e
fila_de_atras:
	ld a,(08686h)		;8b61   ; la tercera, tambien de 16 pero repintada una de cada dos
	inc a			;8b64   ; la tercera
	and 00fh		;8b65
	ld (08686h),a		;8b67
	bit 0,a		;8b6a
	ret nz			;8b6c
	srl a		;8b6d   ; entre dos
	add a,007h		;8b6f
	jp pinta_una_fila_de_pista		;8b71
fila_del_fondo:
	ld a,(08685h)		;8b74   ; la banda de 16, una de cada cuatro
	inc a			;8b77   ; la cuarta
	and 00fh		;8b78
	ld (08685h),a		;8b7a
	ld c,a			;8b7d
	and 003h		;8b7e   ; los dos bits bajos
	ret nz			;8b80
	ld a,c			;8b81
	srl a		;8b82
	srl a		;8b84
	add a,003h		;8b86   ; y tres filas de pantalla mas abajo
	jp pinta_una_fila_de_pista		;8b88
fila_del_horizonte:
	ld a,(08684h)		;8b8b   ; la del horizonte, una de cada ocho
	inc a			;8b8e   ; la del fondo
	and 00fh		;8b8f
	ld c,a			;8b91
	ld (08684h),a		;8b92
	and 007h		;8b95   ; los tres bits bajos
	ret nz			;8b97
	ld a,c			;8b98
	srl a		;8b99
	srl a		;8b9b
	srl a		;8b9d
	add a,001h		;8b9f   ; y una fila mas abajo
	jp pinta_una_fila_de_pista		;8ba1
L_8BA4:
	ld a,(08683h)		;8ba4
	inc a			;8ba7
	and 00fh		;8ba8
	ld (08683h),a		;8baa
	ret nz			;8bad

; ----------------------------------------------------------------------
; EL MOTOR DE LA PISTA: una rutina que se reescribe a si misma
; ----------------------------------------------------------------------
pinta_una_fila_de_pista:
	ld e,a			;8bae   ; la fila de pista que toca
	ld l,(iy+000h)		;8baf   ; de la ficha
	ld h,000h		;8bb2
	ld c,l			;8bb4
	ld b,h			;8bb5
	add hl,hl			;8bb6   ; por cinco: cada fila de la pista ocupa cinco bytes en la tabla de 0x7800
	add hl,hl			;8bb7
	add hl,bc			;8bb8
	ld bc,07800h		;8bb9   ; la tabla, en la RAM
	add hl,bc			;8bbc
	ld a,e			;8bbd
	ld b,0fbh		;8bbe   ; 0xFB00, una de las dos tablas que 0x890F lleno con la plantilla de ocho bytes
	ld c,(hl)			;8bc0   ; el primer byte de la fila
	ld a,(bc)			;8bc1   ; pasado por la tabla
	ld (08c57h),a		;8bc2   ; Y ESCRITO DENTRO DE LA INSTRUCCION de 0x8C56, que es un `ld a,000h` cuyo valor sale acto seguido por el puerto del VDP. La rutina de dibujo no lee los pixeles: SE LOS ESCRIBE ENCIMA
	inc hl			;8bc5
	ld c,(hl)			;8bc6
	inc b			;8bc7   ; 0xFC00, la otra tabla
	ld d,a			;8bc8
	ld a,(bc)			;8bc9
	or d			;8bca
	ld (08c43h),a		;8bcb   ; el segundo, al `ld a,000h` de 0x8C42
	inc hl			;8bce
	dec b			;8bcf
	ld c,(hl)			;8bd0
	and 00fh		;8bd1   ; del tercero solo el nibble bajo
	ld d,a			;8bd3
	ld a,(bc)			;8bd4
	or d			;8bd5
	ld (08c2eh),a		;8bd6   ; al de 0x8C2D
	inc hl			;8bd9
	inc b			;8bda
	ld c,(hl)			;8bdb
	and 0f0h		;8bdc   ; y del cuarto el alto
	ld d,a			;8bde
	ld a,(bc)			;8bdf
	or d			;8be0
	ld (08c82h),a		;8be1   ; al de 0x8C81
	inc hl			;8be4
	dec b			;8be5
	ld c,(hl)			;8be6
	and 00fh		;8be7
	ld d,a			;8be9
	ld a,(bc)			;8bea
	or d			;8beb
	ld (08c96h),a		;8bec   ; el quinto, al de 0x8C95
	and 0f0h		;8bef
	ld (08caah),a		;8bf1   ; y su nibble alto, al de 0x8CA9
	ld a,e			;8bf4   ; la fila otra vez
	ld h,05bh		;8bf5   ; la tabla de 128 words de 0x5B00, la que 0x8932 calculo al arrancar
	add a,008h		;8bf7   ; mas ocho, y por dos porque son words
	add a,a			;8bf9
	ld l,a			;8bfa
	ld e,(hl)			;8bfb   ; la direccion de VRAM de esa fila
	inc hl			;8bfc
	ld d,(hl)			;8bfd
	ex de,hl			;8bfe
	set 5,h		;8bff   ; el bit 5 del byte alto
	ld a,000h		;8c01   ; y AQUI OTRO OPERANDO ESCRITO A MANO: 0x8998 le mete el 0x10 que elige la pagina de la tabla de perspectiva
	add a,h			;8c03
	ld h,a			;8c04
	push hl			;8c05
	call pinta_hacia_arriba		;8c06   ; se pinta hacia arriba
	pop hl			;8c09
	ld a,l			;8c0a   ; ocho filas mas abajo
	add a,008h		;8c0b
	ld l,a			;8c0d
	jp pinta_hacia_abajo		;8c0e   ; y hacia abajo
pinta_hacia_arriba:
	ld b,0ffh		;8c11   ; 0xFF es el byte que dice "sigue"
	ex de,hl			;8c13
	ld a,e			;8c14   ; la direccion de la tabla de perspectiva se arma con los tres bits bajos de e...
	and 007h		;8c15
	add a,a			;8c17   ; ...por dos...
	or 0c0h		;8c18   ; ...y con 0xC0 delante: las ocho paginas pares de 0xC000 a 0xCE00
	ld h,a			;8c1a
	ld a,e			;8c1b   ; y el byte bajo, de los otros bits
	and 0f8h		;8c1c
	ld l,a			;8c1e
	ld a,d			;8c1f
	and 007h		;8c20
	or l			;8c22
	rrca			;8c23
	rrca			;8c24
	rrca			;8c25
	ld l,a			;8c26
L_8C27:
	ld a,e			;8c27   ; la direccion de VRAM
	out (099h),a		;8c28
	ld a,d			;8c2a
	out (099h),a		;8c2b
	ld a,000h		;8c2d   ; ESTE es el byte que 0x8BC2 acaba de escribir
	out (098h),a		;8c2f   ; al puerto de datos
	ld a,e			;8c31   ; una fila de pantalla mas arriba
	sub 008h		;8c32
	ld e,a			;8c34
	ld a,(hl)			;8c35   ; y la tabla dice si sigue
	dec l			;8c36
	cp 0ffh		;8c37   ; con 0xFF, otra vez el mismo byte
	jp z,L_8C27		;8c39
L_8C3C:
	ld a,e			;8c3c   ; el segundo tramo, con su propio byte
	out (099h),a		;8c3d
	ld a,d			;8c3f
	out (099h),a		;8c40
	ld a,000h		;8c42
	out (098h),a		;8c44
	ld a,e			;8c46
	sub 008h		;8c47
	ld e,a			;8c49
	ld a,(hl)			;8c4a   ; y aqui la tabla se para con un CERO, no con 0xFF
	dec l			;8c4b
	or a			;8c4c
	jp z,L_8C3C		;8c4d
L_8C50:
	ld a,e			;8c50   ; el tercer tramo hacia arriba
	out (099h),a		;8c51
	ld a,d			;8c53
	out (099h),a		;8c54
	ld a,000h		;8c56   ; el byte que 0x8BEC escribio aqui
	out (098h),a		;8c58
	ld a,e			;8c5a
	sub 008h		;8c5b
	ld e,a			;8c5d
	ld a,(hl)			;8c5e   ; y la tabla, que dice si sigue
	dec l			;8c5f
	cp b			;8c60
	jp z,L_8C50		;8c61
	ret			;8c64
pinta_hacia_abajo:
	ld b,0ffh		;8c65   ; lo mismo pero hacia abajo: `add a,008h` en vez de `sub`, y `inc l` en vez de `dec l`
	ex de,hl			;8c67
	ld a,e			;8c68
	and 007h		;8c69
	add a,a			;8c6b
	or 0c0h		;8c6c   ; la misma cuenta del byte alto: 0xC0 mas el doble de los tres bits bajos
	ld h,a			;8c6e
	ld a,e			;8c6f
	and 0f8h		;8c70
	ld l,a			;8c72
	ld a,d			;8c73
	and 007h		;8c74
	or l			;8c76
	rrca			;8c77
	rrca			;8c78
	rrca			;8c79
	ld l,a			;8c7a
pinta_el_primer_tramo_abajo:
	ld a,e			;8c7b   ; el primer tramo hacia abajo
	out (099h),a		;8c7c
	ld a,d			;8c7e
	out (099h),a		;8c7f
	ld a,000h		;8c81   ; su byte, escrito por 0x8BE1
	out (098h),a		;8c83
	ld a,e			;8c85
	add a,008h		;8c86
	ld e,a			;8c88
	ld a,(hl)			;8c89   ; y la tabla
	inc l			;8c8a
	cp b			;8c8b
	jp z,pinta_el_primer_tramo_abajo		;8c8c
pinta_el_segundo_tramo_abajo:
	ld a,e			;8c8f   ; el segundo
	out (099h),a		;8c90
	ld a,d			;8c92
	out (099h),a		;8c93
	ld a,000h		;8c95   ; con el byte de 0x8BF1
	out (098h),a		;8c97
	ld a,e			;8c99
	add a,008h		;8c9a
	ld e,a			;8c9c
	ld a,(hl)			;8c9d
	inc l			;8c9e
	or a			;8c9f   ; y este se para con un cero
	jp z,pinta_el_segundo_tramo_abajo		;8ca0
L_8CA3:
	ld a,e			;8ca3   ; el tercero, que remata al dar la vuelta a los cinco bits bajos
	out (099h),a		;8ca4
	ld a,d			;8ca6
	out (099h),a		;8ca7
	ld a,000h		;8ca9   ; el tercer tramo hacia abajo
	out (098h),a		;8cab
	ld a,e			;8cad
	add a,008h		;8cae
	ld e,a			;8cb0
	ld a,(hl)			;8cb1
	ex af,af'			;8cb2
	inc l			;8cb3   ; la casilla siguiente
	ld a,l			;8cb4
	and 01fh		;8cb5   ; y este remata al dar la vuelta a los cinco bits bajos, o sea cada 32 filas
	ret z			;8cb7
	ex af,af'			;8cb8
	cp b			;8cb9
	jp z,L_8CA3		;8cba
	ret			;8cbd
sube_una_fila_hl:
	dec h			;8cbe   ; una fila de pantalla mas arriba
	ld a,l			;8cbf
	cpl			;8cc0   ; si los tres bits altos del byte bajo no eran cero
	and 0e0h		;8cc1
	jr z,cambia_de_banda_hl		;8cc3
	ld a,l			;8cc5   ; se sube dentro de la misma banda
	add a,020h		;8cc6
	ld l,a			;8cc8
	ld a,h			;8cc9   ; y se recorta el byte alto
	and 0f8h		;8cca
	ld h,a			;8ccc
	ret			;8ccd
cambia_de_banda_hl:
	ld a,l			;8cce   ; y si lo eran, hay que cambiar de banda
	and 01fh		;8ccf
	ld l,a			;8cd1
	ld a,h			;8cd2
	and 0f8h		;8cd3
	add a,008h		;8cd5   ; ocho paginas mas alla
	ld h,a			;8cd7
	and 018h		;8cd8
	cp 018h		;8cda   ; y al llegar a la tercera se da la vuelta
	ret nz			;8cdc
	ld h,000h		;8cdd
	ret			;8cdf
sube_una_fila_de:
	dec d			;8ce0   ; igual que 0x8CBE pero sobre `de`
	ld a,e			;8ce1
	cpl			;8ce2
	and 0e0h		;8ce3
	jr z,cambia_de_banda_de		;8ce5
	ld a,e			;8ce7
	add a,020h		;8ce8   ; dentro de la misma banda
	ld e,a			;8cea
	ld a,d			;8ceb
	and 0f8h		;8cec
	ld d,a			;8cee
	ret			;8cef
cambia_de_banda_de:
	ld a,e			;8cf0   ; y su cambio de banda
	and 01fh		;8cf1
	ld e,a			;8cf3
	ld a,d			;8cf4
	and 0f8h		;8cf5
	add a,008h		;8cf7   ; ocho paginas
	ld d,a			;8cf9
	and 018h		;8cfa
	cp 018h		;8cfc
	ret nz			;8cfe
	ld d,000h		;8cff
	ret			;8d01
pixel_a_direccion_de_vram:
	push af			;8d02   ; el numero de fila
	ld b,a			;8d03
	ld c,00fh		;8d04   ; la columna 15, que es por donde va la bola
	ld a,b			;8d06   ; la fila
	and 007h		;8d07   ; los tres bits bajos son la fila dentro del patron
	ld l,a			;8d09
	ld a,b			;8d0a
	rrca			;8d0b   ; y los cinco de arriba, el patron
	rrca			;8d0c
	rrca			;8d0d
	and 01fh		;8d0e   ; cinco bits: el patron
	or 040h		;8d10   ; con 0x40, la marca de escritura
	ld h,a			;8d12
	ld a,c			;8d13   ; la columna por ocho: la cuenta del entrelazado
	add a,a			;8d14
	add a,a			;8d15
	add a,a			;8d16
	or l			;8d17
	ld l,a			;8d18
	pop af			;8d19   ; y el acumulador, de vuelta
	ret			;8d1a
atiende_el_mando:
	ld e,a			;8d1b   ; lo que se ha pulsado
	bit 4,e		;8d1c   ; el bit 4 es el disparo: SALTAR
	jr z,L_8D4A		;8d1e
	ld a,(08681h)		;8d20   ; pero no si ya hay un rebote
	or a			;8d23
	jr nz,L_8D4A		;8d24
	ld a,(0867dh)		;8d26   ; ni si esta cayendo
	or a			;8d29
	jr nz,L_8D4A		;8d2a
	ld a,(08680h)		;8d2c   ; ni si ya esta saltando
	or a			;8d2f
	jr nz,L_8D4A		;8d30
	ld a,(08720h)		;8d32   ; en la partida entera los saltos son contados
	or a			;8d35
	ld a,(08721h)		;8d36
	jr z,L_8D42		;8d39
	or a			;8d3b
	jr z,L_8D4A		;8d3c   ; y si no quedan, no salta
	dec a			;8d3e   ; uno menos
	ld (08721h),a		;8d3f
L_8D42:
	push de			;8d42
	call pinta_las_vidas		;8d43   ; las vidas
	call arranca_un_rebote		;8d46   ; y arranca el salto
	pop de			;8d49
L_8D4A:
	ld hl,0871ah		;8d4a   ; la columna de la bola
	ld a,(hl)			;8d4d   ; la columna de ahora
	bit 0,e		;8d4e   ; el bit 0 es DERECHA
	jr z,L_8D59		;8d50
	inc a			;8d52   ; de dos en dos pixeles
	inc a			;8d53
	cp 0e7h		;8d54   ; con tope en 0xE7, el borde
	jr nc,L_8D59		;8d56
	ld (hl),a			;8d58
L_8D59:
	bit 1,e		;8d59   ; el bit 1 es IZQUIERDA
	jr z,L_8D64		;8d5b
	dec a			;8d5d
	jr z,L_8D64		;8d5e   ; con tope en el otro borde
	dec a			;8d60
	jr z,L_8D64		;8d61
	ld (hl),a			;8d63   ; guardada
L_8D64:
	xor a			;8d64   ; la aceleracion, a cero de entrada
	ld (0867ch),a		;8d65
	bit 3,e		;8d68   ; el bit 3 es ARRIBA: acelerar
	jr z,L_8D71		;8d6a
	ld a,001h		;8d6c
	ld (0867ch),a		;8d6e   ; acelerar
L_8D71:
	bit 2,e		;8d71   ; y el bit 2 ABAJO: frenar
	ret z			;8d73
	ld a,0ffh		;8d74
	ld (0867ch),a		;8d76   ; y frenar
	ret			;8d79
mueve_la_pista:
	ld a,(0867dh)		;8d7a   ; si esta cayendo por un agujero
	or a			;8d7d
	jp nz,se_acabo_la_pista		;8d7e
	ld a,(08678h)		;8d81   ; la velocidad
	or a			;8d84
	ret z			;8d85   ; parada, no hay nada que mover
	ld hl,08679h		;8d86   ; el contador de la velocidad
	cp 001h		;8d89   ; y segun sea 1, 2, 3, 4, 5 o 6, la pista se mueve cada 16, 8, 4, 2, 1 o 2 veces por cuadro: eso es la velocidad
	jr z,L_8DC6		;8d8b
	cp 002h		;8d8d
	jr z,L_8DD1		;8d8f
	cp 003h		;8d91
	jr z,L_8DDC		;8d93
	cp 004h		;8d95
	jr z,L_8DE7		;8d97
	cp 005h		;8d99
	jr z,L_8DF2		;8d9b
	cp 006h		;8d9d
	jr z,L_8DF5		;8d9f
	ret			;8da1
se_acabo_la_pista:
	ld de,081f8h		;8da2   ; la musiquilla de haber acabado
	call L_8249		;8da5
	xor a			;8da8
	ld (08681h),a		;8da9
	ld a,(0871bh)		;8dac   ; la bola se va bajando
	inc a			;8daf
	inc a			;8db0
	cp 0c2h		;8db1   ; hasta 0xC2
	jp nc,L_8DBA		;8db3
	ld (0871bh),a		;8db6
	ret			;8db9
L_8DBA:
	xor a			;8dba   ; y ahi para de caer
	ld (0867dh),a		;8dbb
	inc a			;8dbe
	ld (08680h),a		;8dbf
	ld (0867eh),a		;8dc2
	ret			;8dc5
L_8DC6:
	ld a,(hl)			;8dc6   ; velocidad 1: una de cada dieciseis
	inc a			;8dc7
	cp 010h		;8dc8
	ld (hl),a			;8dca
	ret nz			;8dcb
	xor a			;8dcc
	ld (hl),a			;8dcd
	jp avanza_la_pista_un_paso		;8dce
L_8DD1:
	ld a,(hl)			;8dd1   ; velocidad 2: una de cada ocho
	inc a			;8dd2
	cp 008h		;8dd3
	ld (hl),a			;8dd5
	ret nz			;8dd6
	xor a			;8dd7
	ld (hl),a			;8dd8
	jp avanza_la_pista_un_paso		;8dd9
L_8DDC:
	ld a,(hl)			;8ddc   ; velocidad 3: una de cada cuatro
	inc a			;8ddd
	ld (hl),a			;8dde
	cp 004h		;8ddf
	ret nz			;8de1
	xor a			;8de2
	ld (hl),a			;8de3
	jp avanza_la_pista_un_paso		;8de4
L_8DE7:
	ld a,(hl)			;8de7   ; velocidad 4: una de cada dos
	inc a			;8de8
	cp 002h		;8de9
	ld (hl),a			;8deb
	ret nz			;8dec
	xor a			;8ded
	ld (hl),a			;8dee
	jp avanza_la_pista_un_paso		;8def
L_8DF2:
	jp avanza_la_pista_un_paso		;8df2   ; velocidad 5: una por cuadro
L_8DF5:
	call avanza_la_pista_un_paso		;8df5   ; y velocidad 6: DOS por cuadro
	jp avanza_la_pista_un_paso		;8df8
pinta_la_bola:
	ld hl,(0871ah)		;8dfb   ; la columna y la altura
	ld (0a29eh),hl		;8dfe   ; al bufer del que tira la rutina de sprites
	ld a,(08719h)		;8e01
	ld (0a2a0h),a		;8e04
	call vuelca_los_atributos_de_sprite		;8e07   ; y a pintar
	ld hl,(0871dh)		;8e0a   ; el segundo sprite, el de la sombra
	ld (0a29eh),hl		;8e0d
	ld a,(0871ch)		;8e10
	ld (0a2a0h),a		;8e13
	ret			;8e16
lee_el_mando:
	call lee_el_teclado		;8e17   ; el mando o el teclado
	ld e,a			;8e1a
	ld a,(08682h)		;8e1b   ; y si la bola va del reves
	or a			;8e1e
	jr z,L_8E2B		;8e1f
	ld a,e			;8e21   ; SE LE DA LA VUELTA A LOS DOS BITS de izquierda y derecha, rotandolos uno sobre el otro
	rrca			;8e22
	rrca			;8e23
	rr e		;8e24
	rla			;8e26
	rr e		;8e27
	rla			;8e29
	ld e,a			;8e2a
L_8E2B:
	ld a,e			;8e2b
	ret			;8e2c

; ----------------------------------------------------------------------
; DATOS bufer_de_cuatro: cuatro bytes que 0x8EC7 y 0x8F19 usan de bufer con
;   `ld de,08e2dh`
;   0x8e2d..0x8e31  (4 bytes)
DATA_bufer_de_cuatro:
	defb 000h,000h,000h,000h	; 8e2d

; ======================================================================
; CODIGO 0x8e31..0x8e93  (98 bytes)
; ======================================================================


altura_a_fila_de_pista:
	ld hl,mira_la_casilla_de_debajo		;8e31   ; la vuelta, empujada a mano
	push hl			;8e34
	ld e,004h		;8e35   ; cuatro
	ld a,(0871ah)		;8e37   ; la altura de la bola
	cp 0b3h		;8e3a   ; y segun en que franja caiga -0xB3, 0x8E, 0x64 o 0x3E-, la fila de pista que le toca: 4, 3, 2, 1 o 0. Es la perspectiva vista al reves
	ret nc			;8e3c
	dec e			;8e3d
	cp 08eh		;8e3e
	ret nc			;8e40
	dec e			;8e41
	cp 064h		;8e42
	ret nc			;8e44
	dec e			;8e45
	cp 03eh		;8e46
	ret nc			;8e48
	dec e			;8e49
	ret			;8e4a

; ----------------------------------------------------------------------
; QUE HAY DEBAJO DE LA BOLA
; ----------------------------------------------------------------------
mira_la_casilla_de_debajo:
	ld a,(08688h)		;8e4b   ; la altura de la bola
	cp 010h		;8e4e   ; por debajo de 0x10 no toca el suelo
	ex af,af'			;8e50
	ld l,(iy+000h)		;8e51   ; la fila de pista
	ld h,000h		;8e54
	ld c,l			;8e56
	ld b,h			;8e57
	add hl,hl			;8e58   ; por cinco, que es lo que ocupa cada fila en la tabla de 0x7800
	add hl,hl			;8e59
	add hl,bc			;8e5a
	ld bc,07800h		;8e5b   ; la tabla de filas de pista
	add hl,bc			;8e5e
	ld d,000h		;8e5f   ; y la columna
	add hl,de			;8e61
	ex af,af'			;8e62
	jr c,$+49		;8e63
	ld a,(hl)			;8e65   ; la casilla que hay ahi
	or a			;8e66   ; el 0 es agujero
	jr z,$+53		;8e67
	cp 006h		;8e69   ; el 6 FRENA: pone la velocidad en 2
	jr nz,L_8E73		;8e6b
	ld a,002h		;8e6d
	ld (08678h),a		;8e6f   ; frena
	ret			;8e72
L_8E73:
	cp 002h		;8e73   ; el 2 ACELERA: la pone en 6
	jr nz,L_8E7D		;8e75
	ld a,006h		;8e77
	ld (08678h),a		;8e79   ; acelera
	ret			;8e7c
L_8E7D:
	cp 007h		;8e7d   ; el 7 hace REBOTAR
	jp z,arranca_un_rebote		;8e7f
	cp 003h		;8e82   ; el 3 y el 4 INVIERTEN LOS MANDOS
	jr z,L_8E8A		;8e84
	cp 004h		;8e86
	jr nz,L_8E8E		;8e88
L_8E8A:
	ld (08682h),a		;8e8a
	ret			;8e8d
L_8E8E:
	xor a			;8e8e   ; y cualquier otra cosa los deja como estaban
	ld (08682h),a		;8e8f
	ret			;8e92

; ----------------------------------------------------------------------
; DATOS relleno_entre_rutinas: un byte a cero entre el final de una rutina y
;   el principio de la siguiente
;   0x8e93..0x8e94  (1 bytes)
DATA_relleno_entre_rutinas:
	defb 000h	; 8e93

; ======================================================================
; CODIGO 0x8e94..0x9593  (1791 bytes)
; ======================================================================


mira_si_hay_suelo:
	ld a,(hl)			;8e94   ; el 7 rebota, igual que arriba
	cp 007h		;8e95
	jp z,arranca_un_rebote		;8e97
	or a			;8e9a   ; y cualquier cosa que no sea agujero deja pasar
	ret nz			;8e9b
L_8E9C:
	ld bc,(0871ah)		;8e9c   ; la columna y la fila
	ld a,b			;8ea0
	add a,010h		;8ea1   ; dieciseis pixeles mas abajo
	ld b,a			;8ea3
	push iy		;8ea4
	call pixel_a_direccion		;8ea6   ; a direccion de VRAM
	pop iy		;8ea9
	di			;8eab
	ld a,l			;8eac
	out (099h),a		;8ead
	res 6,h		;8eaf   ; sin la marca de escritura, que aqui se LEE
	ld a,h			;8eb1
	out (099h),a		;8eb2
	push af			;8eb4
	pop af			;8eb5
	in a,(098h)		;8eb6   ; el byte de patron que hay en la pantalla
	ld c,00fh		;8eb8   ; y si esta a 0xFF, o sea lleno
	cp 0ffh		;8eba
	jr nz,L_8EC0		;8ebc
	ld c,0f0h		;8ebe   ; se mira el nibble alto del color en vez del bajo
L_8EC0:
	ld a,l			;8ec0   ; la direccion, otra vez
	out (099h),a		;8ec1
	ld a,h			;8ec3
	set 5,a		;8ec4   ; con el bit 5 que la lleva al color
	out (099h),a		;8ec6
	ld de,08e2dh		;8ec8   ; el bufer de cuatro bytes
	ld a,l			;8ecb
	add a,008h		;8ecc   ; ocho filas mas abajo
	ld l,a			;8ece
	nop			;8ecf
	in a,(098h)		;8ed0   ; el color de esa fila
	and c			;8ed2   ; recortado al nibble que toca
	ld (de),a			;8ed3   ; y guardado
	ld a,l			;8ed4
	out (099h),a		;8ed5
	ld a,h			;8ed7
	out (099h),a		;8ed8
	ld a,l			;8eda
	add a,008h		;8edb
	ld l,a			;8edd
	inc de			;8ede
	in a,(098h)		;8edf
	ld c,00fh		;8ee1
	cp 0ffh		;8ee3
	jr nz,L_8EE9		;8ee5
	ld c,0f0h		;8ee7
L_8EE9:
	ld a,l			;8ee9   ; el segundo color
	out (099h),a		;8eea
	ld a,h			;8eec
	set 5,a		;8eed   ; el bit 5 lleva la direccion a la tabla de color
	out (099h),a		;8eef
	push af			;8ef1
	pop af			;8ef2
	in a,(098h)		;8ef3   ; se lee
	and c			;8ef5
	ld (de),a			;8ef6
	ld a,l			;8ef7   ; la fila siguiente
	add a,008h		;8ef8
	out (099h),a		;8efa
	ld a,h			;8efc
	out (099h),a		;8efd
	push hl			;8eff
	pop hl			;8f00
	inc de			;8f01   ; y el tercero
	in a,(098h)		;8f02
	ld c,00fh		;8f04   ; el nibble bajo del color
	cp 0ffh		;8f06   ; y si el patron esta lleno
	jr nz,L_8F0C		;8f08
	ld c,0f0h		;8f0a
L_8F0C:
	ld a,l			;8f0c
	out (099h),a		;8f0d
	ld a,h			;8f0f
	set 5,a		;8f10
	out (099h),a		;8f12
	push af			;8f14
	pop af			;8f15
	in a,(098h)		;8f16
	and c			;8f18
	ld (de),a			;8f19
	ld hl,08e2dh		;8f1a   ; y con los tres colores leidos
	xor a			;8f1d
	ld c,a			;8f1e
	ld a,(hl)			;8f1f   ; si el primero es cero, no hay pista debajo por la izquierda
	or a			;8f20
	jr nz,L_8F25		;8f21
	set 0,c		;8f23
L_8F25:
	ld a,(0871ah)		;8f25
	and 007h		;8f28
	jr z,L_8F2D		;8f2a
	inc l			;8f2c   ; y lo mismo por la derecha
L_8F2D:
	inc l			;8f2d   ; la casilla de la derecha
	xor a			;8f2e
	ld a,(hl)			;8f2f
	or a			;8f30
	jr nz,L_8F35		;8f31
	set 1,c		;8f33   ; y su marca
L_8F35:
	ld a,c			;8f35
	or a			;8f36   ; si los dos lados tienen suelo, no pasa nada
	ret z			;8f37
	cp 003h		;8f38   ; si los dos estan al aire, la bola se cae
	jr z,la_bola_se_cae		;8f3a
	ld hl,0871ah		;8f3c
	bit 1,c		;8f3f   ; y si solo uno, la bola se DESLIZA siete pixeles hacia el lado que si tiene suelo
	jr z,L_8F47		;8f41
	ld a,(hl)			;8f43
	add a,007h		;8f44
	ld (hl),a			;8f46
L_8F47:
	bit 0,c		;8f47
	jr z,la_bola_se_cae		;8f49
	ld a,(hl)			;8f4b
	sub 007h		;8f4c
	ld (hl),a			;8f4e
la_bola_se_cae:
	ld a,001h		;8f4f   ; la bola cae
	ld (0867dh),a		;8f51
	xor a			;8f54
	ld (08680h),a		;8f55   ; y se cancelan salto, rebote e inversion
	ld (08681h),a		;8f58
	ld (08682h),a		;8f5b
	ret			;8f5e
bola_al_suelo:
	ld a,0afh		;8f5f   ; la altura de siempre
	ld (0871bh),a		;8f61
	ret			;8f64

; ----------------------------------------------------------------------
; LAS SIETE ESTRELLAS QUE SE ALEJAN
; ----------------------------------------------------------------------
mueve_las_estrellas_de_fondo:
	ld a,(0868bh)		;8f65   ; el contador de cuadros
	cp 002h		;8f68   ; una de cada dos
	ret c			;8f6a
	xor a			;8f6b
	ld (0868bh),a		;8f6c   ; el contador, a cero
	ld de,0002ah		;8f6f   ; 42 bytes: el segundo juego de siete estrellas
	ld a,(0868ah)		;8f72   ; y se alternan los dos juegos
	xor 001h		;8f75
	ld (0868ah),a		;8f77   ; y el conmutador de los dos juegos
	ld ix,08694h		;8f7a   ; la lista de estrellas
	jr z,L_8F82		;8f7e
	add ix,de		;8f80
L_8F82:
	ld a,(08693h)		;8f82   ; el contador de dieciseis
	inc a			;8f85
	and 00fh		;8f86
	ld (08693h),a		;8f88
	and 00eh		;8f8b   ; cada dos, las estrellas aceleran
	call z,acelera_las_estrellas		;8f8d   ; cada dos vueltas
	ld b,007h		;8f90   ; siete estrellas
L_8F92:
	push bc			;8f92
	ld c,(ix+002h)		;8f93   ; su columna
	ld b,(ix+003h)		;8f96   ; y su fila
	call apaga_un_pixel		;8f99   ; se borra de donde estaba
	ld a,(ix+000h)		;8f9c   ; la velocidad en x
	bit 7,a		;8f9f   ; el bit 7 dice si va hacia la izquierda
	jr z,L_8FAE		;8fa1
	add a,c			;8fa3   ; sumada a la columna
	ld (ix+002h),a		;8fa4   ; la columna nueva
	cp c			;8fa7
	ld c,a			;8fa8
	call nc,recoloca_una_estrella		;8fa9   ; y si se sale por el borde, vuelve al centro
	jr L_8FB6		;8fac
L_8FAE:
	add a,c			;8fae
	ld (ix+002h),a		;8faf
	ld c,a			;8fb2
	call c,recoloca_una_estrella		;8fb3
L_8FB6:
	ld a,(ix+001h)		;8fb6   ; la velocidad en y
	add a,b			;8fb9
	ld (ix+003h),a		;8fba   ; la fila nueva
	ld b,a			;8fbd
	cp 03fh		;8fbe   ; con los topes por arriba
	call c,recoloca_una_estrella		;8fc0
	cp 0afh		;8fc3   ; y por abajo
	call nc,recoloca_una_estrella		;8fc5
	ld b,(ix+003h)		;8fc8
	ld c,(ix+002h)		;8fcb
	call enciende_un_pixel		;8fce   ; y se pinta en su sitio nuevo
	inc ix		;8fd1   ; seis bytes por estrella
	inc ix		;8fd3
	inc ix		;8fd5
	inc ix		;8fd7
	inc ix		;8fd9
	inc ix		;8fdb
	pop bc			;8fdd
	djnz L_8F92		;8fde
	ret			;8fe0
recoloca_una_estrella:
	call estrella_nueva		;8fe1   ; vuelta al centro, con velocidad nueva
	ld b,(ix+003h)		;8fe4
	ld c,(ix+002h)		;8fe7
	xor a			;8fea
	ret			;8feb
acelera_las_estrellas:
	ld b,007h		;8fec   ; las siete
	push ix		;8fee
L_8FF0:
	ld a,(ix+000h)		;8ff0   ; a la velocidad en x se le suma su aceleracion...
	add a,(ix+004h)		;8ff3   ; la aceleracion en x
	ld (ix+000h),a		;8ff6
	ld a,(ix+001h)		;8ff9   ; ...y a la de y la suya: por eso las estrellas se ABREN al acercarse, como si vinieran de frente
	add a,(ix+005h)		;8ffc   ; y la de y
	ld (ix+001h),a		;8fff
	inc ix		;9002
	inc ix		;9004
	inc ix		;9006
	inc ix		;9008
	inc ix		;900a
	inc ix		;900c
	djnz L_8FF0		;900e
	pop ix		;9010
	ret			;9012
estrella_nueva:
	call coloca_una_estrella		;9013   ; la estrella se coloca y su velocidad se copia a la aceleracion
	ld a,(ix+000h)		;9016   ; la velocidad se copia a la aceleracion
	ld (ix+004h),a		;9019
	ld a,(ix+001h)		;901c
	ld (ix+005h),a		;901f
	ret			;9022
coloca_una_estrella:
	call numero_al_azar		;9023   ; la columna, al azar
	and 03fh		;9026   ; en 64 sitios
	add a,060h		;9028   ; desde 0x60
	cp 073h		;902a   ; el agujero del centro de la pantalla
	jr c,L_903A		;902c
	cp 08ch		;902e
	jr nc,L_903A		;9030
	bit 0,a		;9032   ; se echa a un lado o al otro segun el bit 0
	ld a,073h		;9034
	ld a,08ch		;9036
	ld a,087h		;9038
L_903A:
	ld (ix+002h),a		;903a
L_903D:
	call numero_al_azar		;903d   ; la fila, tambien al azar
	and 03fh		;9040
	cp 02fh		;9042   ; pero solo la mitad de arriba
	jr nc,L_903D		;9044
	add a,050h		;9046   ; desde 0x50
	ld (ix+003h),a		;9048
	cp 060h		;904b   ; y segun donde caiga, la estrella sale hacia arriba o hacia abajo
	jr nc,L_9070		;904d
	ld (ix+001h),0ffh		;904f   ; velocidad -1 en y
	ld a,(ix+002h)		;9053
	cp 06ch		;9056   ; y en x hacia un lado, hacia el otro o recta, segun la columna
	jr c,L_9066		;9058
	cp 07ch		;905a
	jr nc,L_906B		;905c
	ld (ix+000h),000h		;905e
	dec (ix+001h)		;9062
	ret			;9065
L_9066:
	ld (ix+000h),0feh		;9066
	ret			;906a
L_906B:
	ld (ix+000h),002h		;906b
	ret			;906f
L_9070:
	ld (ix+001h),000h		;9070   ; y por debajo, lo mismo al reves
	cp 078h		;9074   ; y por debajo, al reves
	jr nc,L_9089		;9076
L_9078:
	ld a,(ix+002h)		;9078
	cp 080h		;907b
	jr nc,L_9084		;907d
	ld (ix+000h),0feh		;907f
	ret			;9083
L_9084:
	ld (ix+000h),002h		;9084
	ret			;9088
L_9089:
	inc (ix+001h)		;9089
	jr L_9078		;908c

; ----------------------------------------------------------------------
; EL DADO
; ----------------------------------------------------------------------
numero_al_azar:
	ld a,(08692h)		;908e   ; EL DADO, sin tabla ni nada: se toma la semilla
	push hl			;9091
	push de			;9092
	ld h,a			;9093   ; se pone en el byte alto
	ld l,000h		;9094
	ld d,l			;9096
	ld e,h			;9097
	and a			;9098
	sbc hl,de		;9099   ; se le resta dos veces
	sbc hl,de		;909b
	ld a,l			;909d   ; se cruzan los dos bytes
	sub h			;909e
	jr c,L_90A6		;909f
	dec a			;90a1
	ld e,a			;90a2
	ld a,r		;90a3   ; Y SE MEZCLA CON EL REGISTRO R, el contador de refresco de la DRAM, que va cambiando con cada instruccion: asi dos partidas no salen iguales
	xor e			;90a5
L_90A6:
	ld (08692h),a		;90a6
	pop de			;90a9
	pop hl			;90aa
	ret			;90ab

; ----------------------------------------------------------------------
; PINTAR UN PIXEL SUELTO EN SCREEN 2
; ----------------------------------------------------------------------
enciende_un_pixel:
	push hl			;90ac   ; los registros, que esto se llama desde donde sea
	push de			;90ad
	push bc			;90ae
	push af			;90af
	call pixel_a_direccion		;90b0   ; la fila y la columna, a direccion de VRAM y mascara
	push hl			;90b3
	ld l,a			;90b4
	ld h,000h		;90b5
	ld de,088a1h		;90b7   ; la mascara del bit, de la tabla de 0x88A0
	add hl,de			;90ba
	ld c,(hl)			;90bb
	pop hl			;90bc
	ld a,l			;90bd   ; se pone la direccion para leer
	out (099h),a		;90be
	ld a,h			;90c0
	out (099h),a		;90c1
	push hl			;90c3
	pop hl			;90c4
	in a,(098h)		;90c5   ; se lee el byte que ya habia
	or c			;90c7   ; y se le anade el bit
	ex af,af'			;90c8
	ld a,l			;90c9   ; la misma direccion, ahora para escribir
	out (099h),a		;90ca
	ld a,h			;90cc
	set 6,a		;90cd   ; el bit 6 del byte alto es la marca de escritura
	out (099h),a		;90cf
	ex af,af'			;90d1
	out (098h),a		;90d2   ; y va el patron
	push af			;90d4
	pop af			;90d5
	ld a,l			;90d6   ; y ahora la MISMA direccion en la tabla de COLOR
	out (099h),a		;90d7
	ld a,h			;90d9
	or 060h		;90da   ; el 0x60 la lleva a 0x2000
	out (099h),a		;90dc
	ld a,r		;90de   ; EL COLOR SALE DEL REGISTRO R, el contador de refresco de la DRAM: cada estrella se pinta del color que toque, sin gastar ni un byte en decidirlo
	add a,a			;90e0   ; subido al nibble alto, que es la tinta
	add a,a			;90e1
	add a,a			;90e2
	add a,a			;90e3
	out (098h),a		;90e4
	pop af			;90e6
	pop bc			;90e7
	pop de			;90e8
	pop hl			;90e9
	ret			;90ea
pixel_a_direccion:
	ld a,0afh		;90eb   ; 0xAF es la fila mas baja
	cp b			;90ed
	jr nc,L_90F2		;90ee   ; por debajo de ahi no se pinta
	ld b,0bfh		;90f0   ; y se recorta
L_90F2:
	ld a,b			;90f2   ; los tres bits bajos de la fila son la fila DENTRO del patron
	and 007h		;90f3
	ld l,a			;90f5
	ld a,c			;90f6   ; y los cinco altos de la columna, el patron
	and 0f8h		;90f7
	or l			;90f9
	ld l,a			;90fa
	ld a,b			;90fb   ; la fila entre ocho es la banda
	srl a		;90fc
	srl a		;90fe
	srl a		;9100
	ld h,a			;9102
	ld a,c			;9103   ; y los tres bits bajos de la columna, el bit dentro del byte
	and 007h		;9104
	ret			;9106
apaga_un_pixel:
	push hl			;9107   ; los registros, que esto se llama desde cualquier sitio
	push de			;9108
	push bc			;9109
	push af			;910a
	call pixel_a_direccion		;910b   ; la direccion de VRAM del pixel
	push hl			;910e
	ld l,a			;910f
	ld h,000h		;9110
	ld de,088a9h		;9112   ; la mascara negada del bit, de la tabla de 0x88A9
	add hl,de			;9115
	ld c,(hl)			;9116
	pop hl			;9117
	ld a,l			;9118   ; se pone la direccion
	out (099h),a		;9119
	ld a,h			;911b
	out (099h),a		;911c
	push hl			;911e
	pop hl			;911f
	in a,(098h)		;9120   ; se lee el byte que ya habia
	and c			;9122   ; y se le quita el bit
	ex af,af'			;9123
	ld a,l			;9124   ; la misma direccion, ahora para escribir
	out (099h),a		;9125
	ld a,h			;9127
	set 6,a		;9128   ; el bit 6 del byte alto es la marca de escritura del VDP
	out (099h),a		;912a
	ex af,af'			;912c
	out (098h),a		;912d   ; y de vuelta
	pop af			;912f
	pop bc			;9130
	pop de			;9131
	pop hl			;9132
	ret			;9133

; ----------------------------------------------------------------------
; LA INTERRUPCION: todo el juego cuelga de aqui
; ----------------------------------------------------------------------
la_interrupcion:
	di			;9134   ; aqui salta el hardware, por el rodeo de 0xFEFE
	push af			;9135
	in a,(099h)		;9136   ; el registro de estado del VDP
	bit 7,a		;9138   ; el bit 7 dice si la interrupcion es suya
	jp z,sale_de_la_interrupcion		;913a   ; si no lo es, no hay nada que hacer
	ld a,(088e3h)		;913d   ; y si el juego esta a medio montar
	or a			;9140
	jp nz,sale_de_la_interrupcion		;9141   ; tampoco
	ex af,af'			;9144   ; se guardan los DOS juegos de registros enteros: esto interrumpe cualquier cosa
	push af			;9145
	push de			;9146
	push bc			;9147
	push hl			;9148
	push ix		;9149
	push iy		;914b
	exx			;914d
	push hl			;914e
	push de			;914f
	push bc			;9150
	call la_musica_de_fondo		;9151   ; los mandos
	ld a,(0838bh)		;9154   ; si el canal 1 tiene algo que sonar
	or a			;9157
	ld de,(0838dh)		;9158   ; por donde iba
	call nz,toca_el_canal_1		;915c   ; una nota
	ld a,(0838ch)		;915f   ; y lo mismo con el canal 2
	or a			;9162
	ld de,(0838fh)		;9163
	call nz,toca_el_canal_2		;9167
	ld iy,(08716h)		;916a   ; la ficha de la bola
	ld a,(0867eh)		;916e   ; si hay una secuencia en marcha -morir, llegar-, se va por otro lado
	or a			;9171
	jp nz,la_secuencia_del_rebote		;9172
	call mueve_las_estrellas_de_fondo		;9175   ; el cuadro
	ld a,(0867bh)		;9178   ; el contador de dieciseis
	inc a			;917b
	cp 010h		;917c   ; cuando llega a dieciseis
	ld (0867bh),a		;917e
	jr nz,L_91A0		;9181
	xor a			;9183
	ld (0867bh),a		;9184
	ld a,(0867ch)		;9187   ; la aceleracion
	ld c,a			;918a
	ld a,(08678h)		;918b   ; sumada a la velocidad
	add a,c			;918e
	cp 007h		;918f   ; con siete se para de acelerar
	jr z,L_91A0		;9191
	cp 001h		;9193   ; y con uno, de frenar
	jr z,L_91A0		;9195
	push af			;9197
	xor a			;9198
	ld (08679h),a		;9199
	pop af			;919c
	ld (08678h),a		;919d
L_91A0:
	call mueve_la_pista		;91a0   ; la pista
	ld a,(0867dh)		;91a3   ; si no hay nada raro
	or a			;91a6
	jr nz,L_91AF		;91a7
	call lee_el_mando		;91a9   ; se mueve la bola
	call atiende_el_mando		;91ac
L_91AF:
	ld a,(08681h)		;91af   ; la secuencia de rebote
	or a			;91b2
	jr z,mueve_el_salto		;91b3
	ld c,a			;91b5   ; el paso siguiente
	inc c			;91b6
	dec a			;91b7
	ld e,a			;91b8
	ld d,000h		;91b9
	ld hl,(0868fh)		;91bb   ; la curva que toque
	add hl,de			;91be
	ld b,(hl)			;91bf   ; la altura
	inc hl			;91c0
	ld a,(hl)			;91c1
	cp 0ffh		;91c2   ; y con 0xFF se acaba la curva
	jr z,L_91D0		;91c4
	ld a,b			;91c6
	ld (0871bh),a		;91c7   ; la altura, a la variable que la pinta
	ld a,c			;91ca
	ld (08681h),a		;91cb   ; y el paso, guardado
	jr mueve_el_salto		;91ce
L_91D0:
	xor a			;91d0   ; se acabo el rebote
	ld (08681h),a		;91d1
	push iy		;91d4
	ld a,(08688h)		;91d6   ; con la bola por debajo de 0x18
	cp 018h		;91d9
	jr nc,L_91DF		;91db
	dec iy		;91dd   ; baja una fila
L_91DF:
	ld a,0afh		;91df   ; y vuelve a la altura de siempre
	ld (0871bh),a		;91e1
	call altura_a_fila_de_pista		;91e4
	pop iy		;91e7
mueve_el_salto:
	ld a,(08680h)		;91e9   ; el paso del salto
	or a			;91ec
	ld c,a			;91ed
	jr z,L_9224		;91ee
	dec a			;91f0
	ld e,a			;91f1
	ld d,000h		;91f2
	ld hl,08722h		;91f4   ; la curva larga de 0x8722
	add hl,de			;91f7
	ld a,006h		;91f8   ; mientras salta, la velocidad se queda en seis
	ld (08678h),a		;91fa
	ld b,(hl)			;91fd   ; la altura de este cuadro
	inc hl			;91fe
	ld a,(hl)			;91ff
	cp 0ffh		;9200   ; y el 0xFF que cierra la curva
	jr nz,L_9217		;9202
	xor a			;9204
	ld (08680h),a		;9205   ; se acabo el salto
	ld (0868ch),a		;9208
	ld a,004h		;920b   ; cuatro
	ld (08678h),a		;920d
	ld a,0afh		;9210   ; y la bola vuelve al suelo
	ld (0871bh),a		;9212
	jr L_9224		;9215
L_9217:
	ld a,b			;9217   ; la altura de este paso
	ld (0871bh),a		;9218
	ld a,c			;921b
	inc a			;921c   ; el paso siguiente
	ld (08680h),a		;921d
	xor a			;9220
	ld (08681h),a		;9221
L_9224:
	call pinta_la_bola		;9224   ; se pinta todo
	ld (08716h),iy		;9227   ; la ficha de la bola, guardada
L_922B:
	ld a,(0868ch)		;922b   ; si no hay salto en marcha
	or a			;922e
	jr nz,L_923B		;922f
	ld a,(08720h)		;9231   ; segun sea prueba de tres pistas o partida entera
	or a			;9234
	call nz,baja_el_reloj		;9235
	call z,L_92A7		;9238
L_923B:
	ld a,(08681h)		;923b   ; y si lo hay
	or a			;923e
	call nz,el_alto_de_la_bola		;923f
	pop bc			;9242   ; los registros, de vuelta
	pop de			;9243
	pop hl			;9244
	exx			;9245
	pop iy		;9246
	pop ix		;9248
	pop hl			;924a
	pop bc			;924b
	pop de			;924c
	pop af			;924d
	ex af,af'			;924e
	pop af			;924f
	ei			;9250   ; y a lo que estuviera haciendo
	ret			;9251
sale_de_la_interrupcion:
	ex af,af'			;9252   ; aqui llega la interrupcion cuando el juego esta a medio montar: solo suena la musica
	push af			;9253
	push hl			;9254
	push de			;9255
	push bc			;9256   ; los registros que la interrupcion va a tocar
	push ix		;9257
	push iy		;9259
	call la_musica_de_fondo		;925b   ; la musica de fondo
	ld a,(0838bh)		;925e   ; y las dos voces de los efectos
	or a			;9261
	ld de,(0838dh)		;9262
	call nz,toca_el_canal_1		;9266
	ld a,(0838ch)		;9269
	or a			;926c
	ld de,(0838fh)		;926d
	call nz,toca_el_canal_2		;9271
	pop iy		;9274   ; y de vuelta
	pop ix		;9276
	pop bc			;9278
	pop de			;9279
	pop hl			;927a
	pop af			;927b
	ex af,af'			;927c
	pop af			;927d
	ei			;927e
	ret			;927f
el_alto_de_la_bola:
	ld a,(0871bh)		;9280
	ret			;9283
baja_el_reloj:
	ld hl,mira_si_llego_a_cero		;9284   ; la vuelta se empuja a mano: cuando esta rutina remate, se seguira por 0x92E7
	push hl			;9287
	ld hl,08669h		;9288   ; el reloj, digito a digito, PERO HACIA ATRAS: en la prueba de tres pistas el tiempo se descuenta
	ld a,(hl)			;928b   ; una centesima menos
	dec (hl)			;928c
	or a			;928d
	ret nz			;928e
	ld (hl),005h		;928f   ; cada digito da la vuelta a 5 o a 9
	inc hl			;9291
	ld a,(hl)			;9292
	dec (hl)			;9293
	or a			;9294
	ret nz			;9295
	ld (hl),009h		;9296   ; y al llegar a cero, se pide prestado
	inc hl			;9298
	ld a,(hl)			;9299   ; a las decimas
	dec (hl)			;929a
	or a			;929b
	ret nz			;929c
	ld (hl),009h		;929d
	inc hl			;929f
	ld a,(hl)			;92a0
	dec (hl)			;92a1
	or a			;92a2
	ret nz			;92a3
	ld (hl),009h		;92a4
	ret			;92a6
L_92A7:
	call sube_el_reloj		;92a7   ; el reloj sube
	ld hl,mira_si_se_acabo_el_tiempo		;92aa   ; con la vuelta empujada tambien
	push hl			;92ad
	ld hl,08669h		;92ae
	inc (hl)			;92b1   ; una centesima mas
	ld a,(hl)			;92b2
	cp 006h		;92b3   ; las centesimas van de seis en seis
	ret nz			;92b5
	xor a			;92b6
	ld (hl),a			;92b7
	inc hl			;92b8
	inc (hl)			;92b9
	ld a,(hl)			;92ba
	cp 00ah		;92bb
	ret nz			;92bd
	xor a			;92be   ; y al llegar a diez, se lleva una
	ld (hl),a			;92bf
	inc hl			;92c0
	inc (hl)			;92c1   ; los segundos
	ld a,(hl)			;92c2
	cp 00ah		;92c3
	ret nz			;92c5
	xor a			;92c6
	ld (hl),a			;92c7
	inc hl			;92c8
	inc (hl)			;92c9   ; y los minutos
	ld a,(hl)			;92ca
	cp 00ah		;92cb
	ret nz			;92cd
	xor a			;92ce
	ld (hl),a			;92cf
	ret			;92d0
mira_si_se_acabo_el_tiempo:
	ld hl,0866ah		;92d1   ; los tres digitos de arriba
	ld b,003h		;92d4
L_92D6:
	ld a,(hl)			;92d6
	cp 009h		;92d7   ; si todos son nueve, el reloj se paso
	inc hl			;92d9
	ret nz			;92da
	djnz L_92D6		;92db
	inc a			;92dd   ; y se acabo
	ld (08668h),a		;92de
	ld a,001h		;92e1
	ld (088e3h),a		;92e3
	ret			;92e6
mira_si_llego_a_cero:
	ld hl,08669h		;92e7   ; los cuatro digitos
	ld b,004h		;92ea
	xor a			;92ec
L_92ED:
	or (hl)			;92ed   ; si TODOS son cero, el tiempo se agoto
	inc hl			;92ee
	djnz L_92ED		;92ef
	or a			;92f1
	ret nz			;92f2
	inc a			;92f3
	ld a,001h		;92f4
	ld (088e3h),a		;92f6
	ld (08668h),a		;92f9
	ret			;92fc
la_secuencia_del_rebote:
	inc a			;92fd   ; la cuenta de la secuencia, de 0 a 63
	and 03fh		;92fe
	ld (0867eh),a		;9300
	ld a,0ffh		;9303   ; y mientras dura, la bola no responde
	ld (08719h),a		;9305
	call pinta_la_bola		;9308
	jp L_922B		;930b
arranca_un_rebote:
	ld a,(08678h)		;930e   ; el numero de rebote
	or a			;9311
	ret z			;9312
	dec a			;9313   ; por dos, que la tabla es de words
	add a,a			;9314
	ld e,a			;9315
	ld d,000h		;9316
	ld hl,087e8h		;9318   ; la tabla de las seis curvas
	add hl,de			;931b
	ld e,(hl)			;931c   ; la que toque
	inc hl			;931d
	ld d,(hl)			;931e
	ld (0868fh),de		;931f   ; la que toque, guardada
	ld a,001h		;9323   ; y el rebote arranca por el paso 1
	ld (08681h),a		;9325
	ld de,08223h		;9328   ; con su ruidito
	jp L_8249		;932b
pinta_los_catorce:
	ld b,00eh		;932e   ; catorce
	ld a,001h		;9330
	ld (088e3h),a		;9332   ; mientras se monta, la interrupcion no pinta
	di			;9335
	ld ix,08694h		;9336   ; la lista de las catorce marcas
L_933A:
	push bc			;933a
	call estrella_nueva		;933b
	ld b,(ix+003h)		;933e   ; su columna
	ld c,(ix+002h)		;9341   ; su columna
	call enciende_un_pixel		;9344   ; y un pixel encendido por cada una
	pop bc			;9347
	inc ix		;9348   ; seis bytes por marca
	inc ix		;934a
	inc ix		;934c
	inc ix		;934e
	inc ix		;9350   ; seis bytes por marca
	inc ix		;9352
	djnz L_933A		;9354
	ret			;9356
empieza_una_pista:
	ld a,001h		;9357   ; el marcador
	ld (088e3h),a		;9359
	push hl			;935c
	call pinta_el_marcador		;935d
	ld hl,08669h		;9360   ; el reloj a cero
	ld b,004h		;9363
L_9365:
	ld (hl),000h		;9365   ; el reloj a cero
	inc hl			;9367
	djnz L_9365		;9368
	pop hl			;936a
	ld a,(08720h)		;936b   ; si es la partida entera
	or a			;936e
	jr nz,L_9386		;936f
	ld hl,08677h		;9371   ; la pista que toca
	ld e,(hl)			;9374
	inc (hl)			;9375   ; y la siguiente
	ld d,000h		;9376
	ld hl,09aa1h		;9378   ; la tabla de letras de 0x9AA1
	add hl,de			;937b
	ld a,(hl)			;937c   ; la letra
	and 07fh		;937d   ; sin el bit de fin
	sub 041h		;937f   ; menos 'A': la letra de la pista da su numero
	ld (08676h),a		;9381
	jr L_9398		;9384
L_9386:
	ld e,(hl)			;9386   ; y si es la prueba de tres
	ld d,000h		;9387
	ld hl,088b1h		;9389   ; la tabla de parejas de 0x88B1
	add hl,de			;938c   ; la tabla de parejas
	add hl,de			;938d
	ld a,(hl)			;938e
	ld (0866ch),a		;938f
	inc hl			;9392
	ld a,(hl)			;9393
	ld (0866bh),a		;9394
	ld a,e			;9397
L_9398:
	ld iy,06000h		;9398   ; LA PISTA VIVE EN 0x6000, que es adonde la pieza `datos` de la cinta llevo sus ocho kilobytes
	ld (08716h),iy		;939c
	or a			;93a0
	jr z,L_93B8		;93a1
	ld b,a			;93a3
L_93A4:
	ld a,(iy+000h)		;93a4   ; se avanza pista a pista buscando el 0xFF que las separa
	cp 0ffh		;93a7   ; el 0xFF separa una pista de la siguiente
	inc iy		;93a9
	jr nz,L_93A4		;93ab
	djnz L_93A4		;93ad
	ld de,00005h		;93af   ; y cinco bytes mas: la cabecera de cada una
	add iy,de		;93b2
	ld (08716h),iy		;93b4
L_93B8:
	ld bc,01000h		;93b8   ; 0x1000 bytes
	ld hl,04800h		;93bb   ; el bufer de la pista en RAM
	ld de,04801h		;93be
	push bc			;93c1
	push de			;93c2
	push hl			;93c3
	call aparca_los_sprites		;93c4   ; los sprites, fuera de la pantalla
	ld ix,088cdh		;93c7   ; el marco
	ld hl,05903h		;93cb   ; la fila 3 de la pantalla
	call pinta_un_marco		;93ce   ; el nombre de la pista
	call pinta_la_cabecera_de_la_pista		;93d1   ; y el rotulo de arriba
	call espera_un_rato		;93d4   ; y la pausa
	pop hl			;93d7
	pop de			;93d8
	pop bc			;93d9
	jr L_9413		;93da
L_93DC:
	ret			;93dc
espera_un_rato:
	ld e,006h		;93dd   ; seis vueltas
L_93DF:
	ld bc,0ffffh		;93df   ; de 65536 cada una: la pausa mas tonta y mas eficaz
L_93E2:
	dec bc			;93e2   ; el bucle de dentro: 65536 vueltas
	ld a,c			;93e3
	or b			;93e4
	jr nz,L_93E2		;93e5
	dec e			;93e7   ; por seis
	jr nz,L_93DF		;93e8
	ret			;93ea
borra_la_pantalla:
	ld hl,04000h		;93eb   ; la tabla de patrones entera
	ld bc,01800h		;93ee   ; 0x1800 bytes
borra_de_un_tiron:
	ld a,001h		;93f1   ; la interrupcion, quieta mientras se borra
	ld (088e3h),a		;93f3
	ld a,l			;93f6   ; la direccion de VRAM
	out (099h),a		;93f7
	ld a,h			;93f9
	out (099h),a		;93fa
L_93FC:
	ld a,000h		;93fc   ; a cero, uno a uno
	out (098h),a		;93fe
	dec bc			;9400
	ld a,b			;9401
	or c			;9402
	jr nz,L_93FC		;9403
aparca_los_sprites:
	ld hl,05b00h		;9405   ; la tabla de atributos de sprite
	ld a,l			;9408
	out (099h),a		;9409
	ld a,h			;940b
	out (099h),a		;940c
	ld a,0d0h		;940e   ; 0xD0 en el byte de fila: el convenio del VDP para "no pintes mas sprites"
	out (098h),a		;9410
	ret			;9412
L_9413:
	ex de,hl			;9413
	call arma_la_direccion		;9414
	ex de,hl			;9417
	jr borra_de_un_tiron		;9418
sube_el_reloj:
	ld hl,0866dh		;941a   ; el reloj: centesimas
	inc (hl)			;941d   ; una centesima
	ld a,(hl)			;941e
	cp 006h		;941f   ; de seis en seis, que es como sube
	ret nz			;9421
	xor a			;9422   ; al llegar a seis, vuelta a cero
	ld (hl),a			;9423
	inc hl			;9424   ; decimas
	inc (hl)			;9425
	ld a,(hl)			;9426
	cp 00ah		;9427
	ret nz			;9429   ; y se lleva una a las decimas
	xor a			;942a
	ld (hl),a			;942b
	inc hl			;942c
	inc (hl)			;942d   ; segundos
	ld a,(hl)			;942e
	cp 00ah		;942f
	ret nz			;9431   ; lo mismo con los segundos
	xor a			;9432
	ld (hl),a			;9433
	inc hl			;9434   ; decenas de segundo
	inc (hl)			;9435
	ld a,(hl)			;9436
	cp 00ah		;9437
	ret nz			;9439
	xor a			;943a
	ld (hl),a			;943b
	inc hl			;943c   ; y con las decenas
	inc (hl)			;943d   ; y minutos: cinco digitos encadenados, cada uno con su tope
	ld a,(hl)			;943e
	cp 00ah		;943f
	ret nz			;9441
	xor a			;9442
	ld (hl),a			;9443
	inc hl			;9444
	inc (hl)			;9445
	ret			;9446
pinta_el_marcador:
	ld a,(08720h)		;9447   ; en la prueba de tres pistas no hay marcador
	or a			;944a
	ret nz			;944b
	ld a,(08677h)		;944c   ; ni antes de la primera
	or a			;944f
	ret z			;9450
	call pinta_el_reloj		;9451   ; el reloj
	call pinta_el_mejor_tiempo		;9454   ; y el mejor tiempo
	ld a,(08676h)		;9457   ; la pista de ahora
	dec a			;945a
	add a,a			;945b   ; por ocho: la tabla de records tiene ocho bytes por linea
	add a,a			;945c
	add a,a			;945d
	ld e,a			;945e
	ld d,000h		;945f
	ld hl,09a33h		;9461   ; la tabla de 0x9A33
	add hl,de			;9464
	ld b,h			;9465   ; la linea de la tabla
	ld c,l			;9466
	ld de,0866ch		;9467
	ex de,hl			;946a
	ld a,(de)			;946b
	sub 030h		;946c
	cp (hl)			;946e
	ret c			;946f
	jr nz,pasa_el_reloj_al_rotulo		;9470
	inc de			;9472
	dec hl			;9473
	ld a,(de)			;9474
	sub 030h		;9475
	cp (hl)			;9477
	ret c			;9478
	jr nz,pasa_el_reloj_al_rotulo		;9479
	inc de			;947b
	inc de			;947c
	dec hl			;947d
	ld a,(de)			;947e
	sub 030h		;947f
	cp (hl)			;9481
	ret c			;9482
	jr nz,pasa_el_reloj_al_rotulo		;9483
	inc de			;9485
	dec hl			;9486
	ld a,(de)			;9487
	sub 030h		;9488
	cp (hl)			;948a
	ret c			;948b
pasa_el_reloj_al_rotulo:
	ld d,b			;948c   ; el sitio del rotulo
	ld e,c			;948d
	ld hl,0866ch		;948e   ; el reloj, de mayor a menor
	ld a,(hl)			;9491
	add a,030h		;9492   ; mas 0x30, que es el ASCII
	ld (de),a			;9494   ; el digito, al bufer
	inc de			;9495
	dec hl			;9496
	ld a,(hl)			;9497   ; el siguiente
	add a,030h		;9498
	ld (de),a			;949a
	inc de			;949b
	inc de			;949c   ; un hueco: ahi van los dos puntos
	dec hl			;949d
	ld a,(hl)			;949e   ; y los dos de arriba
	add a,030h		;949f
	ld (de),a			;94a1
	inc de			;94a2
	dec hl			;94a3
	ld a,(hl)			;94a4
	add a,030h		;94a5
	ld (de),a			;94a7
	ret			;94a8
pinta_las_vidas:
	ld hl,04036h		;94a9
	add a,030h		;94ac   ; de numero a caracter: el 0x30 del ASCII
	jp pinta_un_caracter		;94ae
se_acabaron_las_catorce:
	ld ix,088cdh		;94b1   ; el marco
	ld hl,05903h		;94b5
	call pinta_un_marco		;94b8
	ld hl,0881eh		;94bb   ; 'NIFTY CONTROL THERE'
	ld bc,00b06h		;94be
	call pinta_un_texto		;94c1
	ld hl,08831h		;94c4   ; 'ALL LEVELS DONE'
	ld bc,00d08h		;94c7
	call pinta_un_texto		;94ca
	ld hl,08840h		;94cd   ; 'NO RELAXING NOW!'
	ld bc,00f08h		;94d0
	call pinta_un_texto		;94d3
	ld hl,08850h		;94d6   ; 'BOUNCE AROUND AGAIN'
	ld bc,01106h		;94d9
	call pinta_un_texto		;94dc
	call espera_un_rato		;94df   ; un rato para leerlo
	jp L_89C3		;94e2
se_acabo_la_prueba:
	call pinta_el_marcador		;94e5   ; el marcador
	ld ix,088cdh		;94e8
	ld hl,05903h		;94ec
	call pinta_un_marco		;94ef
	ld hl,08863h		;94f2   ; 'WELL THAT WAS EASY'
	ld bc,00d06h		;94f5
	call pinta_un_texto		;94f8
	ld hl,08875h		;94fb   ; y 'GO PLAY THE ARCADE'
	ld bc,00f06h		;94fe
	call pinta_un_texto		;9501
	call espera_un_rato		;9504
	jp L_8AC1		;9507

; ----------------------------------------------------------------------
; LOS VOLCADOS A VRAM, CON LA MISMA TRANSPOSICION QUE LA PORTADA
; ----------------------------------------------------------------------
vuelca_a_la_vram:
	di			;950a   ; sin interrupciones mientras se habla con el VDP
	ld a,d			;950b
	cp 058h		;950c   ; por encima de 0x5800 es COLOR, que va comprimido
	jp nc,vuelca_color_comprimido		;950e
	call arma_la_direccion		;9511   ; la direccion, armada con los bits del entrelazado
	ld a,e			;9514
	out (099h),a		;9515
	ld a,d			;9517
	out (099h),a		;9518
	ld d,000h		;951a   ; el contador de bandas
L_951C:
	push hl			;951c
	ld e,008h		;951d   ; ocho filas por patron
L_951F:
	ld a,(hl)			;951f   ; la fila
	out (098h),a		;9520
	inc h			;9522   ; Y OTRA VEZ `inc h`: en la RAM los patrones estan por FILAS DE PANTALLA, no por patron, igual que en la portada
	dec bc			;9523
	ld a,c			;9524
	or b			;9525
	jr z,L_9538		;9526
	dec e			;9528   ; las ocho
	jr nz,L_951F		;9529
	pop hl			;952b
	inc hl			;952c   ; el patron siguiente
	dec d			;952d
	jr nz,L_951C		;952e
	ld d,000h		;9530
	ld a,h			;9532   ; y al acabar la banda, siete paginas mas alla
	add a,007h		;9533
	ld h,a			;9535
	jr L_951C		;9536
L_9538:
	ei			;9538
	pop hl			;9539
	ret			;953a
arma_la_direccion:
	ld a,d			;953b   ; los tres bits bajos del byte alto se guardan
	and 007h		;953c
	push af			;953e   ; los tres bits, guardados
	ld a,d			;953f   ; el resto del byte alto
	and 0f8h		;9540
	ld d,a			;9542
	ld a,e			;9543   ; el byte bajo, subido tres
	rlca			;9544
	rlca			;9545
	rlca			;9546
	push af			;9547
	and 007h		;9548
	or d			;954a
	ld d,a			;954b
	pop af			;954c
	and 0f8h		;954d
	ld e,a			;954f
	pop af			;9550   ; y todo junto
	or e			;9551
	ld e,a			;9552
	ret			;9553
vuelca_color_comprimido:
	ex de,hl			;9554   ; el destino
	ld a,h			;9555
	and 003h		;9556   ; de 0x58, 0x59 o 0x5A solo los dos bits bajos
	ld h,a			;9558
	add hl,hl			;9559   ; por ocho
	add hl,hl			;955a
	add hl,hl			;955b
	ld a,h			;955c
	add a,060h		;955d   ; con el 0x60 de escribir en 0x2000
	ld h,a			;955f
	ex de,hl			;9560
	ld a,e			;9561
	out (099h),a		;9562
	ld a,d			;9564
	out (099h),a		;9565
L_9567:
	ld a,(hl)			;9567   ; el byte de color comprimido
	push af			;9568
	and 007h		;9569   ; LOS TRES BITS BAJOS SON LA TINTA
	exx			;956b
	ld l,a			;956c
	ld h,000h		;956d
	ld de,09593h		;956f   ; por la paleta de 0x9593
	add hl,de			;9572
	ld c,(hl)			;9573
	pop af			;9574
	and 038h		;9575   ; y los tres siguientes, EL PAPEL
	rrca			;9577
	rrca			;9578
	rrca			;9579
	ld l,a			;957a
	ld h,000h		;957b
	ld de,0959bh		;957d   ; por la de 0x959B
	add hl,de			;9580
	ld a,(hl)			;9581
	or c			;9582   ; pegados
	ld b,008h		;9583   ; y escrito ocho veces: un byte por patron, no por fila
escribe_ocho_veces:
	out (098h),a		;9585   ; el mismo byte, ocho veces: las ocho filas del patron
	nop			;9587   ; dos `nop` de respiro para el VDP
	nop			;9588
	djnz escribe_ocho_veces		;9589
	exx			;958b
	inc hl			;958c   ; el byte de color siguiente
	dec bc			;958d
	ld a,c			;958e
	or b			;958f
	ret z			;9590
	jr L_9567		;9591

; ----------------------------------------------------------------------
; DATOS paleta_de_ocho: las MISMAS dos tablas de la pantalla de carga: ocho
;   colores en el nibble alto y los mismos ocho en el bajo. El juego y su
;   portada comparten paleta aunque sean piezas distintas de la cinta
;   0x9593..0x95a3  (16 bytes)
DATA_paleta_de_ocho:
	defb 010h,040h,060h,0d0h,020h,070h,0a0h,0f0h	; 9593  .@`. p..
	defb 001h,004h,006h,00dh,002h,007h,00ah,00fh	; 959b  ........

; ======================================================================
; CODIGO 0x95a3..0x964b  (168 bytes)
; ======================================================================


rellena_color:
	di			;95a3   ; sin interrupciones
	push bc			;95a4
	push af			;95a5
	ld a,h			;95a6
	and 003h		;95a7   ; los dos bits de banda
	ld h,a			;95a9
	add hl,hl			;95aa
	add hl,hl			;95ab
	add hl,hl			;95ac
	ld a,h			;95ad
	add a,060h		;95ae   ; y el 0x60 de escribir en la tabla de color
	ld h,a			;95b0
	ld a,l			;95b1   ; la direccion, byte a byte
	out (099h),a		;95b2
	ld a,h			;95b4
	out (099h),a		;95b5
	pop af			;95b7
	push af			;95b8   ; el color, que se guarda
	and 007h		;95b9   ; mismo reparto: tinta en los tres bits bajos
	exx			;95bb
	ld l,a			;95bc   ; la tinta, por su paleta
	ld h,000h		;95bd
	ld de,09593h		;95bf
	add hl,de			;95c2
	ld c,(hl)			;95c3
	pop af			;95c4
	and 038h		;95c5   ; y papel en los tres siguientes
	rrca			;95c7   ; el papel, bajado a los tres bits de abajo
	rrca			;95c8
	rrca			;95c9
	ld l,a			;95ca
	ld h,000h		;95cb
	ld de,0959bh		;95cd
	add hl,de			;95d0
	ld a,(hl)			;95d1
	or c			;95d2   ; pegados, ya es un color del MSX
	pop bc			;95d3
L_95D4:
	ld h,008h		;95d4   ; ocho filas por patron
L_95D6:
	out (098h),a		;95d6   ; y aqui igual, pero rellenando
	nop			;95d8
	nop			;95d9
	dec h			;95da   ; las ocho filas
	jr nz,L_95D6		;95db
	dec bc			;95dd
	ex af,af'			;95de
	ld a,c			;95df
	or b			;95e0
	jr z,L_95E6		;95e1
	ex af,af'			;95e3
	jr L_95D4		;95e4
L_95E6:
	ei			;95e6
	ret			;95e7
lee_de_la_vram:
	di			;95e8   ; y leer de la VRAM, que tambien hace falta
	push de			;95e9
	call arma_la_direccion		;95ea
	ld a,e			;95ed
	out (099h),a		;95ee   ; la direccion, para LEER
	ld a,d			;95f0
	and 03fh		;95f1   ; sin la marca de escritura
	out (099h),a		;95f3
	nop			;95f5   ; tres `nop`: leer del VDP pide mas espera que escribir
	nop			;95f6
	nop			;95f7
	in a,(098h)		;95f8   ; el byte
	ld (hl),a			;95fa
	pop de			;95fb
	inc de			;95fc
	inc hl			;95fd
	dec bc			;95fe   ; uno menos
	ld a,c			;95ff
	or b			;9600
	jr nz,lee_de_la_vram		;9601
	ei			;9603
	ret			;9604
pinta_un_rotulo:
	ld a,(hl)			;9605   ; el caracter, sin el bit de fin
	and 07fh		;9606
	push hl			;9608
	ld l,a			;9609
	ld h,000h		;960a
	add hl,hl			;960c   ; por ocho
	add hl,hl			;960d
	add hl,hl			;960e
	ld bc,(0a41eh)		;960f   ; en la hoja de caracteres que este puesta
	add hl,bc			;9613
	ld b,008h		;9614   ; ocho filas
	push de			;9616
mete_una_letra_en_el_bufer:
	ld a,(hl)			;9617   ; la fila
	ld (de),a			;9618
	inc hl			;9619
	inc d			;961a   ; al bufer, saltando de 256 en 256: TRANSPUESTO, como todo lo demas
	djnz mete_una_letra_en_el_bufer		;961b
	pop de			;961d
	inc de			;961e
	pop hl			;961f
	bit 7,(hl)		;9620   ; y el bit 7 dice si era la ultima letra
	jr nz,L_9627		;9622
	inc hl			;9624
	jr pinta_un_rotulo		;9625
L_9627:
	inc hl			;9627
	ret			;9628
la_rejilla_a_la_vram:
	ld hl,0c000h		;9629
	ld de,05000h		;962c
L_962F:
	push hl			;962f
	ld b,000h		;9630
L_9632:
	ld a,(hl)			;9632   ; la pagina, byte a byte
	ld (de),a			;9633
	inc hl			;9634
	inc de			;9635
	djnz L_9632		;9636
	pop hl			;9638
	inc h			;9639   ; DOS `inc h`: solo las paginas PARES de 0xC000 a 0xCE00
	inc h			;963a
	ld a,h			;963b
	cp 0d0h		;963c   ; hasta 0xD000
	jr nz,L_962F		;963e
	ld hl,05000h		;9640
	ld e,l			;9643
	ld d,h			;9644
	ld bc,00800h		;9645   ; y los 0x800 juntados van a la VRAM
	jp vuelca_a_la_vram		;9648

; ----------------------------------------------------------------------
; DATOS tabla_y_variables_de_la_pantalla: diecisiete bytes: los primeros son
;   parametros de montaje y los ultimos, de 0x9658 a 0x965C, variables que el
;   codigo escribe nueve veces
;   0x964b..0x965c  (17 bytes)
DATA_tabla_y_variables_de_la_pantalla:
	defb 000h,071h,0e4h,000h,002h,01ch,011h,071h,0b1h,000h,002h,01ch,011h,000h,000h,000h	; 964b  .q.....q........
	defb 000h	; 965b

; ======================================================================
; CODIGO 0x965c..0x981c  (448 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL MENU DE OPCIONES
; ----------------------------------------------------------------------
la_pantalla_de_opciones:
	ld a,0ffh		;965c
	ld (09b00h),a		;965e
	ld a,(0965bh)		;9661   ; si ya se esta en las opciones, no se vuelve a montar
	or a			;9664
	jp nz,pinta_los_records		;9665
	ld a,001h		;9668
	ld (0965ah),a		;966a
	ld a,(09affh)		;966d   ; el conmutador de mando o teclas, que se le da la vuelta cada vez
	cpl			;9670
	ld (09affh),a		;9671
	or a			;9674
	jp z,L_985B		;9675   ; si queda a cero, fuera
	xor a			;9678
	ld (09658h),a		;9679
	ld hl,05841h		;967c   ; la fila 2 de la pantalla
	ld ix,0964ch		;967f
	call pinta_un_marco		;9683
L_9686:
	ld hl,0981ch		;9686   ; el rotulo OPTIONS
	ld bc,0070ch		;9689   ; fila 7, columna 12
	call pinta_un_texto		;968c
	ld hl,09823h		;968f   ; '3 : Play the game'
	ld a,(0871fh)		;9692   ; el estado de la musica...
	ld (l9808h),a		;9695   ; ...ESCRITO DENTRO de la instruccion de 0x9807, que es la que decide el color del texto: asi la linea de la musica se pinta encendida o apagada sin una sola comparacion
	push af			;9698
	ld bc,00b04h		;9699
	call pinta_un_texto		;969c
	pop af			;969f
	xor 02fh		;96a0   ; y para la siguiente linea, el color contrario
	ld (l9808h),a		;96a2
	ld bc,00d04h		;96a5
	ld hl,09834h		;96a8
	call pinta_un_texto		;96ab
	xor a			;96ae
	ld (l9808h),a		;96af
	ld hl,09849h		;96b2
	ld bc,00f04h		;96b5
	call pinta_un_texto		;96b8
	jr L_970E		;96bb
atiende_las_teclas:
	call lee_el_mando_o_las_teclas		;96bd   ; las teclas
	bit 4,a		;96c0   ; el bit 4 dice si hay algo pulsado
	jr z,L_96C6		;96c2
	xor a			;96c4
	ret			;96c5
L_96C6:
	xor a			;96c6
	call mira_una_tecla		;96c7   ; la fila 0 del teclado
	bit 4,a		;96ca   ; su bit 4 es el '4'
	jr z,entra_en_opciones		;96cc
	bit 3,a		;96ce   ; y el bit 3 el '3'
	ret z			;96d0
	ld a,(0965bh)		;96d1   ; en la pantalla de opciones, las flechas mueven la eleccion
	or a			;96d4
	jr z,L_96FF		;96d5
	call lee_el_mando		;96d7
	ld hl,09659h		;96da
	ld e,a			;96dd
	bit 0,e		;96de   ; derecha
	jr z,L_96EA		;96e0
	ld a,(hl)			;96e2
	inc a			;96e3
	cp 004h		;96e4   ; de cuatro en cuatro y da la vuelta
	jr nz,L_96E9		;96e6
	xor a			;96e8
L_96E9:
	ld (hl),a			;96e9
L_96EA:
	bit 1,e		;96ea   ; izquierda
	jr z,L_96FA		;96ec
	ld a,(hl)			;96ee
	dec a			;96ef
	cp 0ffh		;96f0   ; con la vuelta por el otro lado
	jr nz,L_96F6		;96f2
	ld a,003h		;96f4
L_96F6:
	ld (hl),a			;96f6
	jp elige_pista_o_tecla		;96f7
L_96FA:
	ld a,e			;96fa
	or a			;96fb
	jp nz,elige_pista_o_tecla		;96fc
L_96FF:
	ld a,022h		;96ff   ; la tecla 'M'
	call mira_una_tecla		;9701
	jr z,L_970E		;9704
	call mira_las_ocho_filas		;9706   ; y si no, las ocho filas del teclado enteras
	jr z,L_970E		;9709
	call sale_de_opciones		;970b
L_970E:
	ld a,0ffh		;970e
	or a			;9710
	ret			;9711
mira_las_ocho_filas:
	ld b,008h		;9712   ; ocho filas
L_9714:
	push bc			;9714
	ld a,b			;9715
	rlca			;9716   ; por ocho: el numero de fila sube al nibble alto
	rlca			;9717
	rlca			;9718
	call mira_una_tecla		;9719
	inc a			;971c   ; con 0xFF no hay nada pulsado
	pop bc			;971d
	ret nz			;971e
	djnz L_9714		;971f
	ret			;9721
vuelve_al_titulo:
	xor a			;9722
	ld (0965bh),a		;9723
	call la_pantalla_de_opciones		;9726
	jr L_970E		;9729
entra_en_opciones:
	ld a,001h		;972b   ; se entra en opciones
	ld (0965bh),a		;972d
	ld hl,05841h		;9730   ; y se pinta el rotulo de arriba
	ld ix,09652h		;9733
	call pinta_un_marco		;9737
	call pinta_los_records		;973a
	jr L_970E		;973d
pone_la_musica:
	ld a,02fh		;973f   ; 0x2F es el color de "encendido"
	ld (0871fh),a		;9741
	jr devuelve_las_opciones		;9744
quita_la_musica:
	xor a			;9746   ; y cero, el de apagado
	ld (0871fh),a		;9747
devuelve_las_opciones:
	ld a,(0965bh)		;974a   ; lo que estaba puesto
	ld c,a			;974d
	xor a			;974e
	ld (0965bh),a		;974f   ; y las opciones se cierran
	ld a,c			;9752
	or a			;9753
	jr nz,L_977D		;9754
	ld a,(09affh)		;9756
	or a			;9759
	jp nz,L_9686		;975a
	jp la_pantalla_de_opciones		;975d
sale_de_opciones:
	ld a,(0965bh)		;9760   ; lo que estaba puesto
	ld c,a			;9763
	xor a			;9764
	ld (0965bh),a		;9765   ; y las opciones se cierran
	ld a,c			;9768
	or a			;9769
	jr nz,L_977D		;976a
	ld a,(09658h)		;976c
	or a			;976f
	jp z,la_pantalla_de_opciones		;9770   ; si no se venia de los records, se vuelve a ellas
	ld a,(09affh)		;9773
	or a			;9776
	jp nz,L_9686		;9777
	jp la_pantalla_de_opciones		;977a   ; y si si, tambien
L_977D:
	xor a			;977d
	ld (09affh),a		;977e
	jp la_pantalla_de_opciones		;9781
elige_pista_o_tecla:
	ld a,(09659h)		;9784   ; la pista elegida
	or a			;9787
	jr z,L_978C		;9788
	jr L_9794		;978a
L_978C:
	ld a,02fh		;978c   ; en la prueba de tres pistas
	ld (08720h),a		;978e
	jp pinta_los_records		;9791
L_9794:
	xor a			;9794   ; y en la partida entera
	ld (08720h),a		;9795
	ld a,(09659h)		;9798
	ld hl,09aa1h		;979b   ; la tabla de letras de las pistas
	dec a			;979e
	ld c,a			;979f
	ld b,000h		;97a0
	add hl,bc			;97a2
	bit 3,e		;97a3   ; arriba sube la letra
	jr z,L_97B0		;97a5
	ld a,(hl)			;97a7
	inc a			;97a8
	cp 0cfh		;97a9   ; hasta la 'N' y vuelve a la 'A'
	jr nz,L_97AF		;97ab
	ld a,0c1h		;97ad
L_97AF:
	ld (hl),a			;97af
L_97B0:
	bit 2,e		;97b0   ; y abajo la baja
	jr z,L_97BD		;97b2
	ld a,(hl)			;97b4
	dec a			;97b5
	cp 0c0h		;97b6
	jr nz,L_97BC		;97b8
	ld a,0ceh		;97ba
L_97BC:
	ld (hl),a			;97bc
L_97BD:
	jp pinta_los_records		;97bd
fila_y_columna_a_vram:
	ld a,c			;97c0   ; la columna, en cinco bits
	and 01fh		;97c1
	ld e,a			;97c3
	ld a,b			;97c4
	and 007h		;97c5   ; la fila, en tres, subida al nibble alto
	rrca			;97c7
	rrca			;97c8
	rrca			;97c9
	or e			;97ca
	ld e,a			;97cb
	ld a,b			;97cc
	and 018h		;97cd   ; y las bandas, en dos
	or 040h		;97cf   ; con la marca de escritura
	ld d,a			;97d1
	ret			;97d2

; ----------------------------------------------------------------------
; PINTAR TEXTO
; ----------------------------------------------------------------------
pinta_un_texto:
	call fila_y_columna_a_vram		;97d3
L_97D6:
	ld a,(hl)			;97d6   ; el caracter, sin el bit que marca el final
	and 07fh		;97d7
	push hl			;97d9
	ld l,a			;97da
	ld h,000h		;97db
	add hl,hl			;97dd   ; el caracter por ocho
	add hl,hl			;97de
	add hl,hl			;97df
	ld bc,(0a41eh)		;97e0   ; la hoja de caracteres que este puesta
	add hl,bc			;97e4
	ld b,008h		;97e5   ; ocho filas
	push de			;97e7   ; el destino, guardado
	ld a,d			;97e8   ; y la direccion de VRAM, con el entrelazado de siempre
	and 007h		;97e9
	push af			;97eb
	ld a,d			;97ec
	and 0f8h		;97ed
	ld d,a			;97ef
	ld a,e			;97f0
	rlca			;97f1   ; el byte bajo, subido tres bits
	rlca			;97f2
	rlca			;97f3
	push af			;97f4
	and 007h		;97f5
	or d			;97f7
	ld d,a			;97f8
	pop af			;97f9
	and 0f8h		;97fa
	ld e,a			;97fc
	pop af			;97fd
	or e			;97fe
	ld e,a			;97ff
vuelca_una_letra:
	ld a,e			;9800   ; la direccion de VRAM
	di			;9801
	out (099h),a		;9802
	ld a,d			;9804
	out (099h),a		;9805
	ld a,(hl)			;9807   ; la fila del caracter
L_9808:
	nop			;9808   ; UN `nop` QUE NO ES UN NOP: 0x9695 y 0x98D6 le escriben aqui un `or` con el color, y asi el mismo bucle pinta encendido o apagado sin ninguna comparacion
	out (098h),a		;9809   ; al puerto de datos
	ei			;980b
	inc hl			;980c
	inc e			;980d   ; la fila siguiente
	djnz vuelca_una_letra		;980e
	pop de			;9810
	inc de			;9811
	pop hl			;9812
	bit 7,(hl)		;9813   ; y el bit 7 de la letra dice si era la ultima
	jr nz,L_981A		;9815
	inc hl			;9817
	jr L_97D6		;9818
L_981A:
	inc hl			;981a
	ret			;981b

; ----------------------------------------------------------------------
; DATOS menu_de_opciones: 'OPTIONS', '3 : Play the game', '4 :
;   Game/Scores/Times' y 'M : Music On/Off', con el final en el bit 7
;   0x981c..0x985b  (63 bytes)
DATA_menu_de_opciones:
	defb 04fh,050h,054h,049h,04fh,04eh,0d3h,033h,020h,03ah,020h,050h,06ch,061h,079h,020h	; 981c  OPTION.3 : Play 
	defb 074h,068h,065h,020h,067h,061h,06dh,0e5h,034h,020h,03ah,020h,047h,061h,06dh,065h	; 982c  the gam.4 : Game
	defb 02fh,053h,063h,06fh,072h,065h,073h,02fh,054h,069h,06dh,065h,0f3h,04dh,020h,03ah	; 983c  /Scores/Time.M :
	defb 020h,04dh,075h,073h,069h,063h,020h,04fh,06eh,02fh,04fh,066h,0e6h,0f3h,000h	; 984c   Music On/Of...

; ======================================================================
; CODIGO 0x985b..0x9989  (302 bytes)
; ======================================================================


L_985B:
	ld ix,0964ch		;985b
	ld hl,05841h		;985f
	call pinta_un_marco		;9862

; ----------------------------------------------------------------------
; LA PANTALLA DE PUNTUACIONES
; ----------------------------------------------------------------------
pinta_los_records:
	ld a,001h		;9865   ; se apunta que se esta en la pantalla de records
	ld (09658h),a		;9867
	ld bc,00403h		;986a   ; fila 4, columna 3
	ld hl,09aa4h		;986d   ; el rotulo 'HIGH SCORES   BEST TIMES'
	call pinta_un_texto		;9870
	call pinta_las_lineas		;9873
	ld bc,00604h		;9876   ; y las siete lineas
	ld de,09e16h		;9879   ; la lista de puntuaciones
	ld a,007h		;987c
L_987E:
	push af			;987e
	push bc			;987f
	push de			;9880
	push de			;9881
	call fila_y_columna_a_vram		;9882   ; la direccion de VRAM de esa fila
	ex de,hl			;9885
	pop de			;9886
	call L_A391		;9887
	pop hl			;988a
	ld bc,0000ah		;988b   ; diez bytes por linea
	add hl,bc			;988e
	ex de,hl			;988f
	pop bc			;9890
	inc b			;9891   ; la fila siguiente
	pop af			;9892
	dec a			;9893
	jr nz,L_987E		;9894
	jp L_970E		;9896
pinta_las_lineas:
	ld a,002h		;9899   ; dos columnas de rotulos
	ld bc,0060eh		;989b   ; fila 6, columna 14
	ld hl,09a31h		;989e
L_98A1:
	push af			;98a1
	ld a,007h		;98a2   ; siete lineas cada una
L_98A4:
	push af			;98a4
	push bc			;98a5
	push hl			;98a6
	call pinta_un_texto		;98a7
	pop hl			;98aa
	ld bc,00008h		;98ab   ; ocho bytes por linea
	add hl,bc			;98ae
	pop bc			;98af
	inc b			;98b0
	pop af			;98b1
	dec a			;98b2
	jr nz,L_98A4		;98b3
	pop af			;98b5
	ld bc,00616h		;98b6   ; y la segunda columna, en la 0x16
	dec a			;98b9
	jr nz,L_98A1		;98ba
	ld a,(0965bh)		;98bc   ; si no se esta en las opciones, ya esta
	or a			;98bf
	ret z			;98c0
	ld a,(0871fh)		;98c1   ; el rotulo de los mandos, encendido o apagado
	ld bc,01204h		;98c4
	ld hl,099dfh		;98c7   ; 'KEMPSTON J/STICK SELECTS'
	or a			;98ca
	jr z,L_98D0		;98cb
	ld hl,099f7h		;98cd   ; o 'KEYS (Q W P L)   SELECTS'
L_98D0:
	call pinta_un_texto		;98d0
	ld a,(08720h)		;98d3
	ld (09808h),a		;98d6   ; el color, otra vez escrito dentro de la instruccion de 0x9807
	ld a,002h		;98d9
	ld bc,00e04h		;98db
	ld hl,09a15h		;98de   ; 'PLAY ARCADE'
L_98E1:
	push af			;98e1
	ld a,002h		;98e2
L_98E4:
	push af			;98e4
	push bc			;98e5
	call pinta_un_texto		;98e6   ; el rotulo
	pop bc			;98e9
	inc b			;98ea   ; la fila siguiente
	pop af			;98eb
	dec a			;98ec   ; dos lineas
	jr nz,L_98E4		;98ed
	ld a,(09808h)		;98ef
	xor 02fh		;98f2   ; y para la otra linea, el color contrario
	ld (09808h),a		;98f4
	pop af			;98f7
	ld bc,00e0bh		;98f8
	ld hl,09a21h		;98fb   ; '3 COURSE  TEST'
	dec a			;98fe
	jr nz,L_98E1		;98ff
	xor a			;9901
	ld (09808h),a		;9902
	ld bc,00e16h		;9905
	ld a,(08720h)		;9908
	cp 02fh		;990b   ; si es la prueba de tres pistas
	jr z,pinta_la_prueba_de_tres		;990d
	ld a,(09659h)		;990f   ; se enciende la letra que este elegida
	cp 001h		;9912
	jr nz,L_991B		;9914
	ld a,02fh		;9916
	ld (09808h),a		;9918
L_991B:
	ld hl,09aa1h		;991b   ; la 'A'
	call pinta_un_texto		;991e
	xor a			;9921
	ld (09808h),a		;9922
	ld bc,00e18h		;9925   ; la 'B'
	ld a,(09659h)		;9928
	cp 002h		;992b
	jr nz,L_9934		;992d
	ld a,02fh		;992f
	ld (09808h),a		;9931
L_9934:
	ld hl,09aa2h		;9934
	call pinta_un_texto		;9937
	xor a			;993a
	ld (09808h),a		;993b
	ld bc,00e1ah		;993e   ; y la 'C'
	ld a,(09659h)		;9941
	cp 003h		;9944
	jr nz,L_994D		;9946
	ld a,02fh		;9948
	ld (09808h),a		;994a
L_994D:
	ld hl,09aa3h		;994d
	call pinta_un_texto		;9950
	xor a			;9953
	ld (09808h),a		;9954
	ld hl,099b7h		;9957   ; la hoja de caracteres se cambia por la grande
	ld (0a41eh),hl		;995a
	ld hl,09989h		;995d   ; para el guion de posiciones
	ld bc,01004h		;9960
	call pinta_un_texto		;9963
	ld hl,0ba2eh		;9966   ; y se devuelve la normal
	ld (0a41eh),hl		;9969
	ret			;996c
pinta_la_prueba_de_tres:
	ld hl,09a0fh		;996d   ; '3 COURSE  TEST'
	call pinta_un_texto		;9970
	ld hl,099b7h		;9973   ; con la hoja de caracteres grande
	ld (0a41eh),hl		;9976
	ld hl,099a0h		;9979
	ld bc,01004h		;997c
	call pinta_un_texto		;997f
	ld hl,0ba2eh		;9982   ; que se devuelve al acabar
	ld (0a41eh),hl		;9985
	ret			;9988

; ----------------------------------------------------------------------
; DATOS guion_de_posiciones: 46 bytes de valores pequenos (0x00 a 0x04, con
;   0x84 de cierre) que 0x995D y 0x9979 pasan a la rutina de texto de 0x97D3
;   0x9989..0x99b7  (46 bytes)
DATA_guion_de_posiciones:
	defb 004h,004h,004h,000h,004h,004h,004h,004h,004h,004h,001h,004h,004h,004h,004h,004h	; 9989  ................
	defb 004h,004h,004h,002h,004h,003h,084h,004h,004h,004h,000h,004h,004h,004h,004h,004h	; 9999  ................
	defb 004h,001h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,004h,084h	; 99a9  ..............

; ----------------------------------------------------------------------
; DATOS hoja_de_caracteres_grande: cuarenta bytes; es la hoja alternativa que
;   0x9957 y 0x9973 meten en (0xA41E) antes de pintar y quitan despues
;   0x99b7..0x99df  (40 bytes)
DATA_hoja_de_caracteres_grande:
	defb 010h,030h,057h,0b7h,0b1h,057h,030h,010h,008h,00ch,0eah,08dh,0edh,0eah,00ch,008h	; 99b7  .0W..W0.........
	defb 018h,024h,05ah,0ffh,000h,02ch,02ch,03ch,03ch,034h,034h,000h,0ffh,05ah,024h,018h	; 99c7  .$Z..,,<<44..Z$.
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; 99d7  ........

; ----------------------------------------------------------------------
; DATOS rotulos_de_los_mandos: 'KEMPSTON J/STICK SELECTS' y 'KEYS (Q W P L)
;   SELECTS', que los punteros de 0x98C7 y 0x98CD pintan en la pantalla de
;   opciones
;   0x99df..0x9a15  (54 bytes)
DATA_rotulos_de_los_mandos:
	defb 04bh,045h,04dh,050h,053h,054h,04fh,04eh,020h,04ah,02fh,053h,054h,049h,043h,04bh	; 99df  KEMPSTON J/STICK
	defb 020h,053h,045h,04ch,045h,043h,054h,0d3h,04bh,045h,059h,053h,020h,028h,051h,020h	; 99ef   SELECT.KEYS (Q 
	defb 057h,020h,050h,020h,04ch,029h,020h,020h,020h,053h,045h,04ch,045h,043h,054h,0d3h	; 99ff  W P L)   SELECT.
	defb 020h,020h,020h,020h,020h,0a0h	; 9a0f

; ----------------------------------------------------------------------
; DATOS rotulos_de_las_dos_partidas: 'PLAY ARCADE' y '3 COURSE  TEST'
;   0x9a15..0x9a33  (30 bytes)
DATA_rotulos_de_las_dos_partidas:
	defb 020h,050h,04ch,041h,059h,0a0h,041h,052h,043h,041h,044h,0c5h,033h,020h,043h,04fh	; 9a15   PLAY.ARCAD.3 CO
	defb 055h,052h,053h,0c5h,020h,020h,054h,045h,053h,054h,020h,0a0h,041h,02eh	; 9a25  URS.  TEST .A.

; ----------------------------------------------------------------------
; DATOS tabla_de_records_de_fabrica: catorce lineas 'X.99:99 ', de la A a la
;   N: los tiempos que el juego trae puestos, uno por pista
;   0x9a33..0x9aa1  (110 bytes)
DATA_tabla_de_records_de_fabrica:
	defb 039h,039h,03ah,039h,039h,0a0h,042h,02eh	; 9a33  99:99.B.
	defb 039h,039h,03ah,039h,039h,0a0h,043h,02eh	; 9a3b  99:99.C.
	defb 039h,039h,03ah,039h,039h,0a0h,044h,02eh	; 9a43  99:99.D.
	defb 039h,039h,03ah,039h,039h,0a0h,045h,02eh	; 9a4b  99:99.E.
	defb 039h,039h,03ah,039h,039h,0a0h,046h,02eh	; 9a53  99:99.F.
	defb 039h,039h,03ah,039h,039h,0a0h,047h,02eh	; 9a5b  99:99.G.
	defb 039h,039h,03ah,039h,039h,0a0h,048h,02eh	; 9a63  99:99.H.
	defb 039h,039h,03ah,039h,039h,0a0h,049h,02eh	; 9a6b  99:99.I.
	defb 039h,039h,03ah,039h,039h,0a0h,04ah,02eh	; 9a73  99:99.J.
	defb 039h,039h,03ah,039h,039h,0a0h,04bh,02eh	; 9a7b  99:99.K.
	defb 039h,039h,03ah,039h,039h,0a0h,04ch,02eh	; 9a83  99:99.L.
	defb 039h,039h,03ah,039h,039h,0a0h,04dh,02eh	; 9a8b  99:99.M.
	defb 039h,039h,03ah,039h,039h,0a0h,04eh,02eh	; 9a93  99:99.N.
	defb 039h,039h,03ah,039h,039h,0a0h	; 9a9b

; ----------------------------------------------------------------------
; DATOS rotulo_de_los_records: 'ABC' y 'HIGH SCORES   BEST TIMES'
;   0x9aa1..0x9abc  (27 bytes)
DATA_rotulo_de_los_records:
	defb 0c1h,0c2h,0c3h,048h,049h,047h,048h,020h,053h,043h,04fh,052h,045h,053h,020h,020h	; 9aa1  ...HIGH SCORES  
	defb 020h,042h,045h,053h,054h,020h,054h,049h,04dh,045h,0d3h	; 9ab1   BEST TIME.

; ======================================================================
; CODIGO 0x9abc..0x9afc  (64 bytes)
; ======================================================================


L_9ABC:
	ld de,09e5fh		;9abc
	ld hl,0865eh		;9abf
	ld bc,0000ah		;9ac2
	ldir		;9ac5
L_9AC7:
	ld hl,09e22h		;9ac7
	ld de,09e18h		;9aca
	ld b,008h		;9acd
L_9ACF:
	push bc			;9acf
	push hl			;9ad0
	push de			;9ad1
	ld b,00ah		;9ad2
L_9AD4:
	ld a,(de)			;9ad4
	cp (hl)			;9ad5
	jr c,L_9AEC		;9ad6
	jr z,L_9ADC		;9ad8
	jr nc,L_9AE0		;9ada
L_9ADC:
	dec de			;9adc
	dec hl			;9add
	djnz L_9AD4		;9ade
L_9AE0:
	pop hl			;9ae0   ; diez bytes por linea de la tabla
	ld bc,0000ah		;9ae1
	add hl,bc			;9ae4
	ex de,hl			;9ae5
	pop hl			;9ae6
	add hl,bc			;9ae7
	pop bc			;9ae8
	djnz L_9ACF		;9ae9
	ret			;9aeb
L_9AEC:
	pop hl			;9aec
	pop de			;9aed
	pop bc			;9aee
	ld b,00ah		;9aef
intercambia_dos_lineas:
	ld c,(hl)			;9af1   ; se cambian dos lineas de sitio: la ordenacion de la tabla de records, a base de burbuja
	ld a,(de)			;9af2
	ld (hl),a			;9af3
	ld a,c			;9af4
	ld (de),a			;9af5
	dec hl			;9af6   ; diez bytes cada una
	dec de			;9af7
	djnz intercambia_dos_lineas		;9af8
	jr L_9AC7		;9afa

; ----------------------------------------------------------------------
; DATOS variables_del_menu: cinco bytes de trabajo, nueve escrituras
;   0x9afc..0x9b01  (5 bytes)
DATA_variables_del_menu:
	defb 000h,000h,000h,000h,000h	; 9afc

; ======================================================================
; CODIGO 0x9b01..0x9cc8  (455 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LA PANTALLA DEL TITULO Y EL ROTULO QUE DESFILA
; ----------------------------------------------------------------------
la_pantalla_del_titulo:
	ld a,00ch		;9b01   ; el bit 4 del puerto 0xAB apaga el click del teclado
	out (0abh),a		;9b03
	ld a,001h		;9b05
	ld (088e3h),a		;9b07
	di			;9b0a
	im 2		;9b0b   ; modo 2 de interrupcion
	ei			;9b0d
	ld hl,0c200h		;9b0e   ; los sprites, fuera de la pantalla
	ld (0a29eh),hl		;9b11
	call vuelca_los_atributos_de_sprite		;9b14
	xor a			;9b17
	call monta_los_graficos_del_juego		;9b18   ; los graficos
	ld a,0f0h		;9b1b   ; y 0xF0 cuadros hasta que salgan las opciones
	ld (09b00h),a		;9b1d
	ld hl,09e69h		;9b20   ; el rotulo que desfila, por el principio
	ld (09afch),hl		;9b23
	xor a			;9b26
	ld (09afeh),a		;9b27
	ld (09affh),a		;9b2a
	jp el_bucle_del_titulo		;9b2d
el_bucle_del_titulo:
	call espera_el_cuadro		;9b30
	call atiende_las_teclas		;9b33   ; las teclas
	ret z			;9b36
	ld hl,09b00h		;9b37
	dec (hl)			;9b3a   ; la cuenta atras
	jr nz,saca_una_letra_del_rotulo		;9b3b
	ld a,(0965bh)		;9b3d
	or a			;9b40
	call z,la_pantalla_de_opciones		;9b41   ; y al llegar a cero, la pantalla de opciones
saca_una_letra_del_rotulo:
	ld hl,(09afch)		;9b44
	ld a,(hl)			;9b47   ; la letra siguiente del rotulo
	inc hl			;9b48
	ld (09afch),hl		;9b49
	cp 0feh		;9b4c   ; el 0xFE es una PAUSA, no una letra
	push af			;9b4e
	jr nz,L_9B67		;9b4f
	ld bc,000fah		;9b51   ; 250 vueltas
L_9B54:
	push bc			;9b54
	ld a,022h		;9b55
	call mira_una_tecla		;9b57   ; mirando el espacio
	jr z,la_cuenta_de_la_pausa		;9b5a
	call mira_las_ocho_filas		;9b5c
la_cuenta_de_la_pausa:
	pop bc			;9b5f   ; la cuenta de la pausa
	jr nz,L_9B67		;9b60
	dec bc			;9b62   ; una menos
	ld a,c			;9b63
	or b			;9b64
	jr nz,L_9B54		;9b65
L_9B67:
	pop af			;9b67
	jp z,el_bucle_del_titulo		;9b68
	cp 0ffh		;9b6b   ; y el 0xFF cierra el rotulo
	jp nz,mete_la_letra_en_el_bufer		;9b6d
	xor a			;9b70
	ld (09658h),a		;9b71
	jp la_pantalla_del_titulo		;9b74   ; y vuelve a empezar todo
mete_la_letra_en_el_bufer:
	ld h,000h		;9b77
	ld l,a			;9b79
	add hl,hl			;9b7a   ; la letra por ocho
	add hl,hl			;9b7b
	add hl,hl			;9b7c
	ld de,(0a41eh)		;9b7d   ; en la hoja de caracteres
	add hl,de			;9b81
	ld de,050dfh		;9b82   ; al final del bufer de la linea que desfila
	ld b,010h		;9b85   ; dieciseis filas
L_9B87:
	ld a,(hl)			;9b87
	ld (de),a			;9b88
	bit 0,b		;9b89   ; UNA DE CADA DOS: el rotulo se pinta a media altura, y por eso ocupa dos filas de pantalla
	jr z,L_9B8E		;9b8b
	inc hl			;9b8d
L_9B8E:
	inc d			;9b8e
	ld a,d			;9b8f
	cp 058h		;9b90
	jr nz,L_9B97		;9b92
	ld de,050ffh		;9b94
L_9B97:
	djnz L_9B87		;9b97
	jp el_bucle_del_titulo		;9b99
espera_el_cuadro:
	ei			;9b9c   ; a esperar la interrupcion
	halt			;9b9d   ; con un `halt` de una linea
	ld a,(0964bh)		;9b9e   ; y el conmutador que hace que las estrellas se muevan a la mitad de velocidad
	xor 001h		;9ba1
	ld (0964bh),a		;9ba3
	jr z,L_9BAC		;9ba6
	ld a,(0965ah)		;9ba8
	or a			;9bab
L_9BAC:
	ld hl,050dfh		;9bac
	ld b,010h		;9baf

; ----------------------------------------------------------------------
; LAS ESTRELLAS QUE PASAN
; ----------------------------------------------------------------------
desplaza_las_estrellas:
	and a			;9bb1   ; el acarreo a cero: la estrella que entra por la derecha es negra
	push hl			;9bb2
	rl (hl)		;9bb3   ; treinta y dos `rl (hl)` seguidos, sin bucle
	dec l			;9bb5
	rl (hl)		;9bb6   ; el acarreo del byte anterior entra por la derecha
	dec l			;9bb8
	rl (hl)		;9bb9
	dec l			;9bbb
	rl (hl)		;9bbc   ; y sale por la izquierda hacia el siguiente
	dec l			;9bbe
	rl (hl)		;9bbf
	dec l			;9bc1
	rl (hl)		;9bc2
	dec l			;9bc4
	rl (hl)		;9bc5   ; treinta y dos bytes: los 256 pixeles de una fila
	dec l			;9bc7
	rl (hl)		;9bc8   ; uno por byte
	dec hl			;9bca   ; cada ocho hay un `dec hl` en vez de `dec l`, para saltar a la banda de arriba
	rl (hl)		;9bcb
	dec l			;9bcd
	rl (hl)		;9bce
	dec l			;9bd0
	rl (hl)		;9bd1   ; sin bucle, para que quepa en el tiempo de un cuadro
	dec l			;9bd3
	rl (hl)		;9bd4
	dec l			;9bd6
	rl (hl)		;9bd7
	dec l			;9bd9
	rl (hl)		;9bda
	dec l			;9bdc
	rl (hl)		;9bdd   ; cada `dec l` baja un byte dentro de la misma banda
	dec l			;9bdf
	rl (hl)		;9be0   ; y la banda de arriba
	dec hl			;9be2
	rl (hl)		;9be3
	dec l			;9be5
	rl (hl)		;9be6
	dec l			;9be8
	rl (hl)		;9be9
	dec l			;9beb
	rl (hl)		;9bec
	dec l			;9bee
	rl (hl)		;9bef   ; y cada ocho, un `dec hl` para cambiar de banda
	dec l			;9bf1
	rl (hl)		;9bf2
	dec l			;9bf4
	rl (hl)		;9bf5   ; y cada `dec hl` cambia de banda
	dec l			;9bf7
	rl (hl)		;9bf8
	dec hl			;9bfa
	rl (hl)		;9bfb
	dec l			;9bfd
	rl (hl)		;9bfe
	dec l			;9c00
	rl (hl)		;9c01   ; el acarreo va pasando de uno a otro
	dec l			;9c03
	rl (hl)		;9c04
	dec l			;9c06
	rl (hl)		;9c07   ; asi se desplaza una fila entera de pantalla un pixel, con el acarreo saltando de byte en byte
	dec l			;9c09
	rl (hl)		;9c0a
	dec l			;9c0c
	rl (hl)		;9c0d   ; y al llegar al primero, la estrella se pierde por la izquierda
	dec l			;9c0f
	rl (hl)		;9c10   ; el ultimo
	dec hl			;9c12
	pop hl			;9c13
	inc h			;9c14   ; la fila siguiente del patron
	ld a,h			;9c15
	cp 058h		;9c16   ; y al llegar a 0x5800 se acabo la pantalla
	jr nz,L_9C1D		;9c18
	ld hl,050ffh		;9c1a   ; se vuelve al principio
L_9C1D:
	djnz desplaza_las_estrellas		;9c1d   ; ocho filas
	ld hl,050c0h		;9c1f   ; el bufer en RAM, ya desplazado
	ld de,05600h		;9c22   ; y la VRAM
	di			;9c25   ; sin interrupciones, que el volcado va a pelo
	ld a,e			;9c26
	out (099h),a		;9c27
	ld a,d			;9c29
	out (099h),a		;9c2a
L_9C2C:
	push hl			;9c2c
	ld b,008h		;9c2d   ; ocho bytes por patron
L_9C2F:
	ld a,(hl)			;9c2f
	out (098h),a		;9c30   ; al puerto de datos
	nop			;9c32   ; dos `nop` para no correr mas que el VDP
	nop			;9c33
	inc h			;9c34   ; saltando de 256 en 256, que el bufer tambien esta transpuesto
	djnz L_9C2F		;9c35
	pop hl			;9c37
	inc l			;9c38   ; el patron siguiente
	jr z,L_9C3D		;9c39
	jr L_9C2C		;9c3b
L_9C3D:
	ei			;9c3d
	ld a,(09afeh)		;9c3e   ; y el contador de ocho: las estrellas solo se mueven una vez de cada ocho
	inc a			;9c41
	and 007h		;9c42
	ld (09afeh),a		;9c44
	jp nz,espera_el_cuadro		;9c47
	ret			;9c4a

; ----------------------------------------------------------------------
; LOS GRAFICOS DE LA PISTA
; ----------------------------------------------------------------------
monta_los_graficos_del_juego:
	ld a,(0965bh)		;9c4b   ; si se esta en las opciones, no se toca nada
	or a			;9c4e
	ret nz			;9c4f
	xor a			;9c50
	ld (0965ah),a		;9c51
	ld hl,05800h		;9c54
	ld de,05801h		;9c57
	ld bc,002ffh		;9c5a
	ld hl,0a5afh		;9c5d   ; los patrones del banco 0
	ld de,04000h		;9c60
	ld bc,00800h		;9c63
	call vuelca_a_la_vram		;9c66
	ld hl,0adafh		;9c69   ; la primera banda de la rejilla
	ld de,05800h		;9c6c
	ld bc,000e0h		;9c6f
	call vuelca_a_la_vram		;9c72
	ld hl,058e0h		;9c75
	ld bc,00020h		;9c78
	ld a,047h		;9c7b   ; y la ultima fila, de un solo color
	call rellena_color		;9c7d
	ld ix,0b0afh		;9c80   ; EL GUION DE LOS OTROS DOS BANCOS, que va comprimido
	ld hl,04800h		;9c84
descomprime_los_patrones:
	ld a,(ix+000h)		;9c87   ; el byte del guion
	ld c,a			;9c8a
	or a			;9c8b   ; si es 0x00...
	jr z,L_9C92		;9c8c
	cp 0ffh		;9c8e   ; ...o 0xFF, el siguiente byte dice cuantas veces se repite
	jr nz,L_9CA4		;9c90
L_9C92:
	inc ix		;9c92
	ld b,(ix+000h)		;9c94   ; la cuenta
L_9C97:
	ld (hl),c			;9c97   ; y se escribe tantas veces
	inc hl			;9c98
	ld a,h			;9c99
	cp 058h		;9c9a   ; hasta llenar los 0x1000
	jr z,vuelca_los_patrones		;9c9c
	djnz L_9C97		;9c9e
	inc ix		;9ca0
	jr descomprime_los_patrones		;9ca2
L_9CA4:
	ld (hl),a			;9ca4   ; y cualquier otro byte va literal, uno solo
	inc hl			;9ca5
	ld a,h			;9ca6
	cp 058h		;9ca7
	jr z,vuelca_los_patrones		;9ca9
	inc ix		;9cab
	jr descomprime_los_patrones		;9cad
vuelca_los_patrones:
	ld hl,04800h		;9caf   ; los 0x1000 descomprimidos
	ld bc,01000h		;9cb2
	ld de,04800h		;9cb5
	call vuelca_a_la_vram		;9cb8   ; a la VRAM 0x0800: los bancos 1 y 2
	ld hl,0aeafh		;9cbb   ; y las otras dos bandas de la rejilla
	ld de,05900h		;9cbe
	ld bc,00200h		;9cc1
	call vuelca_a_la_vram		;9cc4
	ret			;9cc7

; ----------------------------------------------------------------------
; DATOS copyright_y_modo_de_trampas: ' 1986 Gremlin Graphics Ltd' y el rotulo
;   del modo de trampas: 'FOOLED YOU!    YOU ARE NOW IN CHEAT MODE', las dos
;   cerradas con el bit 7 como todos los textos. ESTAN, PERO NO LAS PINTA
;   NADIE: no hay una sola instruccion en los 38.299 bytes que cargue nada de
;   la pagina 0x9C. En el C64 al modo se entra con Z+X+C; aqui esas tres
;   teclas (0x2F, 0x2D y 0x18) no aparecen en ninguna de las doce llamadas a
;   mira_una_tecla, y con las tres apretadas en el titulo, en las opciones y
;   en la partida, el vigia sobre 0x9CC8..0x9D19 no anota una sola lectura. El
;   texto que desfila bromea con que "puede que haya un modo de trampas, pero
;   lo dudo": en esta conversion, no lo hay
;   0x9cc8..0x9d1a  (82 bytes)
DATA_copyright_y_modo_de_trampas:
	defb 07fh,020h,031h,039h,038h,036h,020h,047h,072h,065h,06dh,06ch,069h,06eh,020h,047h	; 9cc8  . 1986 Gremlin G
	defb 072h,061h,070h,068h,069h,063h,073h,020h,04ch,074h,064h,020h,020h,0a0h,046h,04fh	; 9cd8  raphics Ltd  .FO
	defb 04fh,04ch,045h,044h,020h,059h,04fh,055h,021h,020h,020h,020h,020h,059h,04fh,055h	; 9ce8  OLED YOU!    YOU
	defb 020h,041h,052h,045h,020h,04eh,04fh,057h,020h,049h,04eh,020h,043h,048h,045h,041h	; 9cf8   ARE NOW IN CHEA
	defb 054h,020h,04dh,04fh,044h,045h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; 9d08  T MODE          
	defb 020h,0ffh	; 9d18

; ======================================================================
; CODIGO 0x9d1a..0x9def  (213 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LOS MARCOS DE LA PANTALLA
; ----------------------------------------------------------------------
pinta_un_marco:
	ld a,0ffh		;9d1a   ; el marco de fuera
	ld (09d8eh),a		;9d1c   ; 0xFF de grosor
	call dibuja_el_marco		;9d1f
	ld a,003h		;9d22   ; y el de dentro, de 3
	ld (09d8eh),a		;9d24
	ret			;9d27
dibuja_el_marco:
	push hl			;9d28
	ld hl,09defh		;9d29   ; la hoja de caracteres del MARCO: tres patrones que hacen las esquinas y los lados
	ld (0a41eh),hl		;9d2c
	pop hl			;9d2f
	ld c,(ix+000h)		;9d30   ; el ancho
	ld b,(ix+004h)		;9d33   ; el alto
	ld d,(ix+002h)		;9d36
	ld e,(ix+000h)		;9d39
	call una_fila_del_marco		;9d3c   ; la fila de arriba
	ld bc,00020h		;9d3f   ; una fila entera
	add hl,bc			;9d42
	ld b,(ix+005h)		;9d43
L_9D46:
	push bc			;9d46   ; las filas de en medio
	ld b,(ix+004h)		;9d47   ; las filas de en medio
	ld c,(ix+000h)		;9d4a
	ld d,(ix+003h)		;9d4d
	ld e,(ix+001h)		;9d50
	call una_fila_del_marco		;9d53
	ld bc,00020h		;9d56
	add hl,bc			;9d59
	pop bc			;9d5a
	djnz L_9D46		;9d5b
	ld c,(ix+000h)		;9d5d   ; y la de abajo
	ld b,(ix+004h)		;9d60
	ld d,(ix+002h)		;9d63   ; y la de abajo
	ld e,(ix+000h)		;9d66
	call una_fila_del_marco		;9d69
	ld hl,0ba2eh		;9d6c   ; la hoja normal, de vuelta
	ld (0a41eh),hl		;9d6f
	ret			;9d72
una_fila_del_marco:
	push hl			;9d73
	push hl			;9d74
	ld a,c			;9d75   ; la esquina de la izquierda
	call escribe_un_color		;9d76
	call direccion_de_color		;9d79
	ld a,d			;9d7c
	call pinta_un_caracter		;9d7d
	pop hl			;9d80
	inc hl			;9d81
L_9D82:
	push hl			;9d82
	ex af,af'			;9d83
	ld a,e			;9d84   ; el relleno
	call escribe_un_color		;9d85   ; la esquina de la derecha
	call direccion_de_color		;9d88
	ld a,d			;9d8b   ; y su relleno
	inc a			;9d8c   ; y la de la derecha
	cp 003h		;9d8d
	call nz,pinta_un_caracter		;9d8f
	pop hl			;9d92
	inc hl			;9d93
	djnz L_9D82		;9d94
	ld a,c			;9d96
	call escribe_un_color		;9d97
	call direccion_de_color		;9d9a
	ld a,d			;9d9d
	call pinta_un_caracter		;9d9e
	pop hl			;9da1
	ret			;9da2
direccion_de_color:
	ld a,h			;9da3   ; los dos bits de banda, subidos, con la marca de escritura
	and 003h		;9da4
	rlca			;9da6
	rlca			;9da7
	rlca			;9da8
	or 040h		;9da9
	ld h,a			;9dab
	ret			;9dac
recolorea_la_pantalla:
	ld a,(09658h)		;9dad   ; si se esta en los records o en las opciones, no
	or a			;9db0
	ret nz			;9db1
	ld a,(0965bh)		;9db2
	or a			;9db5
	ret nz			;9db6
	ld hl,05900h		;9db7   ; la tabla de nombres, desde la fila 8
	ld bc,000c0h		;9dba   ; 0xC0 casillas
	ld d,007h		;9dbd   ; de tres en tres
L_9DBF:
	ld a,(hl)			;9dbf
	inc a			;9dc0   ; la casilla siguiente, dando la vuelta cada tres: asi la rejilla parece que corre
	and d			;9dc1
	or a			;9dc2
	jr nz,guarda_y_sigue		;9dc3
	inc a			;9dc5
guarda_y_sigue:
	ld (hl),a			;9dc6   ; la casilla, guardada
	inc hl			;9dc7
	dec bc			;9dc8   ; y la siguiente
	ld a,c			;9dc9
	or b			;9dca
	ret z			;9dcb
	jr L_9DBF		;9dcc
escribe_un_color:
	push hl			;9dce   ; la direccion de color
	push af			;9dcf
	ld a,h			;9dd0
	and 003h		;9dd1
	ld h,a			;9dd3
	add hl,hl			;9dd4
	add hl,hl			;9dd5
	add hl,hl			;9dd6
	ld a,h			;9dd7
	add a,060h		;9dd8   ; con el 0x60 que la lleva a 0x2000
	ld h,a			;9dda
	di			;9ddb
	ld a,l			;9ddc
	out (099h),a		;9ddd
	ld a,h			;9ddf
	out (099h),a		;9de0
	pop af			;9de2
	ld h,008h		;9de3
L_9DE5:
	out (098h),a		;9de5   ; al puerto de datos
	nop			;9de7
	nop			;9de8
	dec h			;9de9
	jr nz,L_9DE5		;9dea
	ei			;9dec
	pop hl			;9ded
	ret			;9dee

; ----------------------------------------------------------------------
; DATOS dibujo_de_ocho_por_ocho: veinticuatro bytes con pinta de tres patrones
;   sueltos
;   0x9def..0x9e07  (24 bytes)
DATA_dibujo_de_ocho_por_ocho:
	defb 0ffh,081h,0bdh,0a5h,0a5h,0bdh,081h,0ffh	; 9def  ........
	defb 0ffh,000h,07fh,040h,079h,07fh,000h,0ffh	; 9df7  ...@y...
	defb 0adh,0a5h,0a5h,0adh,0adh,0adh,0bdh,081h	; 9dff  ........

; ----------------------------------------------------------------------
; DATOS hueco_antes_del_rotulo: 98 bytes a cero entre los patrones y el
;   principio del texto
;   0x9e07..0x9e69  (98 bytes)
DATA_hueco_antes_del_rotulo:
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 9e07  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 9e17  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 9e27  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 9e37  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 9e47  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 9e57  ................
	defb 000h,000h	; 9e67

; ----------------------------------------------------------------------
; DATOS rotulo_que_desfila: el texto del titulo, de 0x9E69 a 0xA29D, cerrado
;   con 0xFF: la presentacion y TODOS los creditos del juego
;   0x9e69..0xa29e  (1077 bytes)
DATA_rotulo_que_desfila:
	defb 02eh,02eh,02eh,02eh,02eh,02eh,050h,072h,065h,073h,073h,020h,061h,06eh,079h,020h	; 9e69  ......Press any 
	defb 06bh,065h,079h,020h,066h,06fh,072h,020h,06fh,070h,074h,069h,06fh,06eh,073h,02eh	; 9e79  key for options.
	defb 02eh,02eh,0feh,057h,065h,06ch,063h,06fh,06dh,065h,020h,074h,06fh,020h,054h,072h	; 9e89  ...Welcome to Tr
	defb 061h,069h,06ch,062h,06ch,061h,07ah,065h,072h,02eh,02eh,02eh,02eh,02eh,02eh,02eh	; 9e99  ailblazer.......
	defb 02eh,02eh,02eh,028h,063h,029h,020h,04dh,072h,020h,043h,068h,069h,070h,020h,031h	; 9ea9  ...(c) Mr Chip 1
	defb 039h,038h,036h,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,054h,068h,069h,073h,020h	; 9eb9  986........This 
	defb 061h,06dh,061h,07ah,069h,06eh,067h,020h,076h,065h,072h,073h,069h,06fh,06eh,020h	; 9ec9  amazing version 
	defb 077h,072h,069h,074h,074h,065h,06eh,020h,062h,079h,020h,053h,048h,041h,055h,04eh	; 9ed9  written by SHAUN
	defb 020h,048h,04fh,04ch,04ch,049h,04eh,047h,057h,04fh,052h,054h,048h,02ch,020h,043h	; 9ee9   HOLLINGWORTH, C
	defb 04fh,04ch,049h,04eh,020h,044h,04fh,04fh,04ch,045h,059h,02ch,020h,050h,045h,054h	; 9ef9  OLIN DOOLEY, PET
	defb 045h,052h,020h,048h,041h,052h,052h,041h,050h,02ch,020h,043h,048h,052h,049h,053h	; 9f09  ER HARRAP, CHRIS
	defb 020h,04bh,045h,052h,052h,059h,020h,061h,06eh,064h,020h,047h,052h,045h,047h,020h	; 9f19   KERRY and GREG 
	defb 048h,04fh,04ch,04dh,045h,053h,020h,028h,074h,06fh,06fh,020h,070h,065h,079h,03fh	; 9f29  HOLMES (too pey?
	defb 029h,06fh,066h,020h,047h,072h,065h,06dh,06ch,069h,06eh,020h,047h,072h,061h,070h	; 9f39  )of Gremlin Grap
	defb 068h,069h,063h,073h,020h,053h,06fh,066h,074h,077h,061h,072h,065h,020h,04ch,069h	; 9f49  hics Software Li
	defb 06dh,069h,074h,065h,064h,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,04fh,072h,069h	; 9f59  mited........Ori
	defb 067h,069h,06eh,061h,06ch,06ch,079h,020h,063h,072h,065h,061h,074h,065h,064h,020h	; 9f69  ginally created 
	defb 062h,079h,020h,053h,068h,061h,075h,06eh,020h,053h,06fh,075h,074h,068h,065h,072h	; 9f79  by Shaun Souther
	defb 06eh,020h,06fh,06eh,020h,074h,068h,065h,020h,043h,06fh,06dh,06dh,06fh,064h,06fh	; 9f89  n on the Commodo
	defb 072h,065h,02eh,02eh,02eh,02eh,02eh,047h,061h,06dh,065h,020h,070h,06ch,061h,079h	; 9f99  re.....Game play
	defb 020h,061h,06eh,064h,020h,073h,06fh,06dh,065h,020h,067h,072h,061h,070h,068h,069h	; 9fa9   and some graphi
	defb 063h,020h,062h,069h,074h,073h,020h,062h,079h,020h,054h,065h,072h,072h,079h,020h	; 9fb9  c bits by Terry 
	defb 04ch,04ch,06fh,079h,064h,020h,028h,079h,061h,06bh,069h,020h,064h,061h,021h,029h	; 9fc9  LLoyd (yaki da!)
	defb 020h,061h,06eh,064h,020h,050h,02eh,048h,061h,072h,072h,061h,070h,02eh,02eh,02eh	; 9fd9   and P.Harrap...
	defb 02eh,02eh,02eh,02eh,04fh,068h,021h,02ch,061h,06eh,064h,020h,069h,066h,020h,079h	; 9fe9  ....Oh!,and if y
	defb 06fh,075h,020h,074h,068h,069h,06eh,06bh,020h,074h,068h,065h,020h,06ch,065h,076h	; 9ff9  ou think the lev
	defb 065h,06ch,073h,020h,061h,072h,065h,020h,074h,06fh,06fh,020h,068h,061h,072h,064h	; a009  els are too hard
	defb 020h,074h,068h,065h,06eh,020h,074h,06fh,075h,067h,068h,021h,02ch,020h,079h,06fh	; a019   then tough!, yo
	defb 075h,020h,063h,061h,06eh,027h,074h,020h,068h,061h,076h,065h,020h,065h,078h,070h	; a029  u can't have exp
	defb 065h,063h,074h,065h,064h,020h,069h,074h,020h,074h,06fh,020h,062h,065h,020h,065h	; a039  ected it to be e
	defb 061h,073h,079h,020h,063h,061h,06eh,020h,079h,06fh,075h,03fh,020h,02eh,02eh,02eh	; a049  asy can you? ...
	defb 02eh,02eh,02eh,02eh,02eh,049h,074h,027h,073h,020h,06eh,06fh,020h,075h,073h,065h	; a059  .....It's no use
	defb 020h,063h,06fh,06dh,070h,06ch,061h,069h,06eh,069h,06eh,067h,02ch,077h,065h,020h	; a069   complaining,we 
	defb 077h,065h,072h,065h,020h,066h,06fh,072h,063h,065h,064h,020h,061h,074h,020h,067h	; a079  were forced at g
	defb 075h,06eh,070h,06fh,069h,06eh,074h,020h,074h,06fh,020h,070h,06ch,061h,079h,020h	; a089  unpoint to play 
	defb 041h,04ch,04ch,020h,074h,068h,065h,020h,06ch,065h,076h,065h,06ch,073h,020h,063h	; a099  ALL the levels c
	defb 06fh,06dh,070h,06ch,065h,074h,065h,06ch,079h,020h,073h,06fh,020h,077h,065h,020h	; a0a9  ompletely so we 
	defb 064h,06fh,06eh,027h,074h,020h,073h,065h,065h,020h,077h,068h,079h,020h,079h,06fh	; a0b9  don't see why yo
	defb 075h,020h,073h,068h,06fh,075h,06ch,064h,06eh,027h,074h,020h,062h,065h,020h,061h	; a0c9  u shouldn't be a
	defb 062h,06ch,065h,020h,074h,06fh,020h,064h,06fh,020h,074h,068h,065h,06dh,021h,02eh	; a0d9  ble to do them!.
	defb 02eh,02eh,02eh,02eh,04eh,065h,061h,072h,06ch,079h,020h,066h,06fh,072h,067h,06fh	; a0e9  ....Nearly forgo
	defb 074h,020h,02dh,020h,074h,068h,065h,020h,06bh,065h,079h,073h,020h,061h,072h,065h	; a0f9  t - the keys are
	defb 02eh,02eh,02eh,02eh,02eh,02eh,02eh,06fh,06eh,020h,079h,06fh,075h,072h,020h,063h	; a109  .......on your c
	defb 06fh,06dh,070h,075h,074h,065h,072h,020h,02dh,020h,06fh,06fh,070h,073h,021h,020h	; a119  omputer - oops! 
	defb 049h,020h,06dh,065h,061h,06eh,074h,020h,074h,068h,065h,020h,06bh,065h,079h,073h	; a129  I meant the keys
	defb 020h,061h,072h,065h,020h,051h,02dh,04ch,065h,066h,074h,02ch,057h,02dh,072h,069h	; a139   are Q-Left,W-ri
	defb 067h,068h,074h,02ch,050h,02dh,055h,070h,02ch,04ch,02dh,044h,06fh,077h,06eh,020h	; a149  ght,P-Up,L-Down 
	defb 061h,06eh,064h,020h,053h,070h,061h,063h,065h,020h,074h,06fh,020h,06ah,075h,06dh	; a159  and Space to jum
	defb 070h,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,054h,068h,065h,072h,065h	; a169  p..........There
	defb 020h,06dh,061h,079h,020h,062h,065h,020h,061h,020h,043h,068h,065h,061h,074h,020h	; a179   may be a Cheat 
	defb 06dh,06fh,064h,065h,020h,062h,075h,074h,020h,049h,020h,064h,06fh,075h,062h,074h	; a189  mode but I doubt
	defb 020h,069h,074h,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,020h,020h,050h,02eh,053h	; a199   it........  P.S
	defb 020h,064h,06fh,06eh,027h,074h,020h,066h,06fh,072h,067h,065h,074h,020h,074h,06fh	; a1a9   don't forget to
	defb 020h,072h,065h,061h,064h,020h,074h,068h,065h,020h,050h,02eh,053h,020h,04fh,04bh	; a1b9   read the P.S OK
	defb 020h,06fh,072h,020h,079h,06fh,075h,027h,06ch,06ch,020h,062h,065h,020h,073h,06fh	; a1c9   or you'll be so
	defb 072h,072h,079h,021h,02eh,02eh,02eh,02eh,020h,049h,020h,073h,075h,070h,070h,06fh	; a1d9  rry!.... I suppo
	defb 073h,065h,020h,079h,06fh,075h,027h,06ch,06ch,020h,077h,061h,06eh,074h,020h,074h	; a1e9  se you'll want t
	defb 06fh,020h,070h,06ch,061h,079h,020h,074h,068h,065h,020h,067h,061h,06dh,065h,020h	; a1f9  o play the game 
	defb 06eh,06fh,077h,02eh,02eh,02eh,079h,06fh,075h,020h,068h,061h,076h,065h,020h,062h	; a209  now...you have b
	defb 065h,065h,06eh,020h,077h,061h,072h,06eh,065h,064h,02eh,02eh,02eh,02eh,02eh,02eh	; a219  een warned......
	defb 02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh	; a229  ................
	defb 04fh,06eh,065h,020h,06ch,061h,073h,074h,020h,070h,06fh,069h,06eh,074h,02ch,02eh	; a239  One last point,.
	defb 02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,077h,061h,069h,074h,020h,066h,06fh	; a249  .........wait fo
	defb 072h,020h,069h,074h,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,069h,074h	; a259  r it..........it
	defb 027h,073h,020h,06eh,065h,061h,072h,06ch,079h,020h,068h,065h,072h,065h,02eh,02eh	; a269  's nearly here..
	defb 02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,048h,065h,06ch,06ch,06fh,020h,04dh,075h	; a279  ........Hello Mu
	defb 06dh,021h,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh,02eh	; a289  m!..............
	defb 02eh,02eh,02eh,02eh,0ffh	; a299

; ----------------------------------------------------------------------
; DATOS variables_del_rotulo: tres bytes de trabajo: 0x8DFE, 0x8E0D y 0x9B11
;   escriben el puntero de por donde va el texto y 0xA2BB lee el otro
;   0xa29e..0xa2a1  (3 bytes)
DATA_variables_del_rotulo:
	defb 040h,091h,000h	; a29e

; ======================================================================
; CODIGO 0xa2a1..0xa41e  (381 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; LOS SPRITES DE LA BOLA
; ----------------------------------------------------------------------
vuelca_los_atributos_de_sprite:
	ld hl,05b00h		;a2a1   ; la tabla de atributos, en VRAM 0x1B00
	ld a,l			;a2a4
	out (099h),a		;a2a5
	ld a,h			;a2a7
	out (099h),a		;a2a8
	ld hl,(0a29eh)		;a2aa   ; la fila y la columna de la bola
	ld a,h			;a2ad
	cp 0beh		;a2ae   ; por encima de 0xBE ya no se ve
	jr nc,L_A2F8		;a2b0
	jr L_A2B4		;a2b2
L_A2B4:
	out (098h),a		;a2b4   ; fila
	ld a,l			;a2b6
	jr L_A2B9		;a2b7
L_A2B9:
	out (098h),a		;a2b9   ; columna
	ld a,(0a2a0h)		;a2bb   ; el patron, que sale del tamano
	add a,a			;a2be   ; por cuatro, que los sprites de 16x16 van de cuatro en cuatro
	add a,a			;a2bf
	add a,008h		;a2c0
	jr L_A2C4		;a2c2
L_A2C4:
	out (098h),a		;a2c4
	ld a,00fh		;a2c6   ; blanco
	jr L_A2CA		;a2c8
L_A2CA:
	out (098h),a		;a2ca
	ld a,h			;a2cc
	jr L_A2CF		;a2cd
L_A2CF:
	out (098h),a		;a2cf   ; y el segundo sprite, el de la sombra
	ld a,l			;a2d1
	jr L_A2D4		;a2d2
L_A2D4:
	out (098h),a		;a2d4
	ld a,004h		;a2d6   ; cuatro pixeles mas alla, en las dos direcciones
	jr L_A2DA		;a2d8
L_A2DA:
	out (098h),a		;a2da
	ld a,004h		;a2dc
	jr L_A2E0		;a2de
L_A2E0:
	out (098h),a		;a2e0
	ld a,h			;a2e2
	jr L_A2E5		;a2e3
L_A2E5:
	out (098h),a		;a2e5
	ld a,l			;a2e7
	jr L_A2EA		;a2e8
L_A2EA:
	out (098h),a		;a2ea
	ld a,000h		;a2ec
	jr L_A2F0		;a2ee
L_A2F0:
	out (098h),a		;a2f0
	ld a,001h		;a2f2
	jr L_A2F6		;a2f4
L_A2F6:
	out (098h),a		;a2f6
L_A2F8:
	ld a,0d0h		;a2f8   ; 0xD0 en la fila: el VDP deja de pintar sprites ahi
	jr L_A2FC		;a2fa
L_A2FC:
	out (098h),a		;a2fc
	ret			;a2fe
numero_a_digitos:
	ld hl,0865dh		;a2ff   ; el numero a tres digitos, a base de restar
	ld e,000h		;a302
L_A304:
	cp 064h		;a304   ; primero las centenas
	jr c,L_A30D		;a306
	sub 064h		;a308
	inc e			;a30a
	jr L_A304		;a30b
L_A30D:
	ld (hl),e			;a30d
	ld e,000h		;a30e
	dec hl			;a310
L_A311:
	cp 00ah		;a311   ; luego las decenas
	jr c,L_A31A		;a313
	sub 00ah		;a315
	inc e			;a317
	jr L_A311		;a318
L_A31A:
	ld (hl),e			;a31a
	ld e,000h		;a31b
	dec hl			;a31d
L_A31E:
	or a			;a31e   ; y lo que queda son las unidades
	jr z,L_A325		;a31f
	inc e			;a321
	dec a			;a322
	jr L_A31E		;a323
L_A325:
	ld (hl),e			;a325
suma_a_la_puntuacion:
	ld de,0865eh		;a326   ; la puntuacion, digito a digito
	ld b,003h		;a329   ; tres digitos
L_A32B:
	ld a,(de)			;a32b
	add a,(hl)			;a32c
	cp 00ah		;a32d   ; con acarreo cuando se pasa de diez
	push de			;a32f
	push hl			;a330
	jr nc,L_A33B		;a331
	pop hl			;a333
	pop de			;a334
	ld (de),a			;a335
L_A336:
	inc de			;a336
	inc hl			;a337
	djnz L_A32B		;a338
	ret			;a33a
L_A33B:
	ex de,hl			;a33b   ; se le quitan diez
	sub 00ah		;a33c
	ld (hl),a			;a33e
L_A33F:
	inc hl			;a33f
	inc (hl)			;a340   ; y se lleva una al de al lado
	ld a,(hl)			;a341
	cp 00ah		;a342
	jr nz,L_A34A		;a344
	ld (hl),000h		;a346
	jr L_A33F		;a348
L_A34A:
	pop hl			;a34a
	pop de			;a34b
	jr L_A336		;a34c
pinta_el_reloj:
	ld hl,0403ah		;a34e   ; la fila 0, columna 0x3A
	ld a,(08720h)		;a351   ; en la prueba de tres pistas el reloj va siempre en el mismo sitio
	or a			;a354
	jr nz,L_A365		;a355
	ld a,(08677h)		;a357   ; y en la partida entera, una fila por pista
	dec a			;a35a
	jr z,L_A365		;a35b
	add a,a			;a35d   ; por dos
	ld b,a			;a35e
	ld de,00020h		;a35f   ; treinta y dos casillas por fila
L_A362:
	add hl,de			;a362
	djnz L_A362		;a363
L_A365:
	ld de,0866ch		;a365   ; los cinco digitos del reloj, del ultimo al primero
	ld a,(de)			;a368
	add a,030h		;a369   ; mas 0x30, el ASCII
	call pinta_un_caracter		;a36b   ; el digito, pintado
	inc l			;a36e
	dec de			;a36f
	ld a,(de)			;a370
	add a,030h		;a371
	call pinta_un_caracter		;a373
	inc l			;a376
	dec de			;a377
	ld a,03ah		;a378   ; los dos puntos
	call pinta_un_caracter		;a37a
	inc l			;a37d
	ld a,(de)			;a37e
	add a,030h		;a37f
	call pinta_un_caracter		;a381   ; y los de la derecha
	inc l			;a384
	dec de			;a385
	ld a,(de)			;a386
	add a,030h		;a387
	jr pinta_un_caracter		;a389
pinta_la_puntuacion:
	ld hl,04026h		;a38b   ; la fila 0, columna 0x26
	ld de,08665h		;a38e
L_A391:
	ld bc,00800h		;a391   ; ocho digitos
L_A394:
	ld a,(de)			;a394
	bit 0,c		;a395   ; el bit 0 dice si ya salio una cifra distinta de cero
	jr nz,L_A3A2		;a397
	or a			;a399   ; los ceros de delante
	jr nz,L_A3A0		;a39a
	ld a,020h		;a39c   ; se pintan como espacios
	jr L_A3A4		;a39e
L_A3A0:
	set 0,c		;a3a0   ; y a partir del primer digito bueno, se pintan todos
L_A3A2:
	add a,030h		;a3a2
L_A3A4:
	call pinta_un_caracter		;a3a4
	dec de			;a3a7
	inc l			;a3a8
	djnz L_A394		;a3a9
	ret			;a3ab

; ----------------------------------------------------------------------
; PINTAR UNA LETRA, PATRON A PATRON
; ----------------------------------------------------------------------
pinta_un_caracter:
	push de			;a3ac
	push hl			;a3ad
	push af			;a3ae
	ld a,h			;a3af   ; la fila y la columna, a direccion de VRAM con el entrelazado de SCREEN 2
	and 007h		;a3b0   ; los tres bits bajos del byte alto
	push af			;a3b2
	ld a,h			;a3b3
	and 0f8h		;a3b4
	ld h,a			;a3b6
	ld a,l			;a3b7   ; el byte bajo, subido tres
	rlca			;a3b8
	rlca			;a3b9
	rlca			;a3ba
	push af			;a3bb
	and 007h		;a3bc
	or h			;a3be
	ld h,a			;a3bf
	pop af			;a3c0
	and 0f8h		;a3c1   ; y armados los dos, es la direccion de VRAM del patron
	ld l,a			;a3c3
	pop af			;a3c4
	or l			;a3c5
	ld l,a			;a3c6
	pop af			;a3c7
	push hl			;a3c8
	ld l,a			;a3c9   ; el caracter
	ld h,000h		;a3ca
	add hl,hl			;a3cc   ; por ocho: cada uno son ocho bytes
	add hl,hl			;a3cd
	add hl,hl			;a3ce
	ld de,(0a41eh)		;a3cf   ; la hoja de caracteres que este puesta
	add hl,de			;a3d3
	ex de,hl			;a3d4
	pop hl			;a3d5
	push bc			;a3d6
	ld b,008h		;a3d7   ; ocho filas
L_A3D9:
	ld a,l			;a3d9   ; ocho filas, byte a byte
	di			;a3da   ; sin interrupciones, byte a byte
	out (099h),a		;a3db
	ld a,h			;a3dd
	out (099h),a		;a3de
	ld a,(de)			;a3e0
	out (098h),a		;a3e1
	ei			;a3e3
	inc de			;a3e4
	inc l			;a3e5   ; con `inc l`: dentro del mismo patron
	djnz L_A3D9		;a3e6
	pop bc			;a3e8
	pop hl			;a3e9
	pop de			;a3ea
	ret			;a3eb
pinta_el_mejor_tiempo:
	ld hl,04070h		;a3ec   ; la fila 0, columna 0x70
	ld de,08671h		;a3ef
	ld a,(de)			;a3f2   ; el mejor tiempo, digito a digito
	add a,030h		;a3f3
	call pinta_un_caracter		;a3f5
	inc l			;a3f8   ; el digito siguiente
	dec de			;a3f9
	ld a,(de)			;a3fa
	add a,030h		;a3fb
	call pinta_un_caracter		;a3fd
	inc l			;a400
	dec de			;a401   ; y el de al lado
	ld a,(de)			;a402
	add a,030h		;a403
	call pinta_un_caracter		;a405
	inc l			;a408
	dec de			;a409
	ld a,03ah		;a40a   ; con los dos puntos en medio
	call pinta_un_caracter		;a40c
	inc l			;a40f
	ld a,(de)			;a410
	add a,030h		;a411
	call pinta_un_caracter		;a413   ; los dos ultimos
	inc l			;a416
	dec de			;a417
	ld a,(de)			;a418
	add a,030h		;a419
	jp pinta_un_caracter		;a41b

; ----------------------------------------------------------------------
; DATOS puntero_de_la_hoja_de_caracteres: la hoja que usa la rutina de texto
;   de 0x97D3; el arranque la deja en 0xBA2E y 0x9957 la cambia y la devuelve
;   0xa41e..0xa420  (2 bytes)
DATA_puntero_de_la_hoja_de_caracteres:
	defw 00000h	; a41e

; ======================================================================
; CODIGO 0xa420..0xa476  (86 bytes)
; ======================================================================


pinta_la_cabecera_de_la_pista:
	ld a,(08720h)		;a420   ; en la prueba de tres pistas, 'PLAY ARCADE'
	ld hl,0a476h		;a423
	or a			;a426
	jr nz,L_A42C		;a427
	ld hl,0a482h		;a429   ; y en la partida entera, '3 COURSE TEST'
L_A42C:
	ld bc,00c09h		;a42c
	call pinta_un_texto		;a42f
	ld a,(08676h)		;a432   ; la pista
	push af			;a435
	add a,041h		;a436   ; mas 'A': su letra
	set 7,a		;a438   ; con el bit 7, que es como se marca el final de una cadena
	ld (0a4a3h),a		;a43a   ; Y ESCRITA DENTRO del texto de 0xA4A3, que es la cadena de una sola letra que se pinta a continuacion
	ld hl,0a4a3h		;a43d
	ld bc,00307h		;a440
	call pinta_un_texto		;a443
	ld hl,0a48fh		;a446   ; 'ENTERING TRAIL ZONE'
	ld bc,00e05h		;a449
	call pinta_un_texto		;a44c
	ld bc,01007h		;a44f
	ld hl,0a4a4h		;a452   ; 'GET READY TO ROLL'
	call pinta_un_texto		;a455
	ld hl,0a4b5h		;a458
	ld bc,00501h		;a45b
	call pinta_un_texto		;a45e
	pop af			;a461
	ld hl,0a4cbh		;a462   ; y el nombre de la pista, de la lista de catorce
	or a			;a465
	jr z,L_A470		;a466
	ld b,a			;a468
L_A469:
	bit 7,(hl)		;a469
	inc hl			;a46b
	jr z,L_A469		;a46c
	djnz L_A469		;a46e
L_A470:
	ld bc,00502h		;a470
	jp pinta_un_texto		;a473

; ----------------------------------------------------------------------
; DATOS rotulos_del_menu: 'PLAY ARCADE', '3 COURSE TEST', 'ENTERING TRAIL
;   ZONE' y 'GET READY TO ROLL', con el final en el bit 7
;   0xa476..0xa4cb  (85 bytes)
DATA_rotulos_del_menu:
	defb 020h,050h,04ch,041h,059h,020h,041h,052h,043h,041h,044h,0c5h,033h,020h,043h,04fh	; a476   PLAY ARCAD.3 CO
	defb 055h,052h,053h,045h,020h,054h,045h,053h,0d4h,045h,04eh,054h,045h,052h,049h,04eh	; a486  URSE TES.ENTERIN
	defb 047h,020h,054h,052h,041h,049h,04ch,020h,05ah,04fh,04eh,045h,020h,000h,047h,045h	; a496  G TRAIL ZONE .GE
	defb 054h,020h,052h,045h,041h,044h,059h,020h,054h,04fh,020h,052h,04fh,04ch,0cch,020h	; a4a6  T READY TO ROL. 
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h	; a4b6                  
	defb 020h,020h,020h,020h,0a0h	; a4c6

; ----------------------------------------------------------------------
; DATOS nombres_de_los_niveles: los catorce nombres de pista, uno detras de
;   otro y con el final en el bit 7; llevan el nombre de los programadores del
;   juego
;   0xa4cb..0xa5af  (228 bytes)
DATA_nombres_de_los_niveles:
	defb 045h,041h,053h,059h,020h,047h,04fh,049h,04eh,047h,0a0h,057h,04fh,04fh,04ch,059h	; a4cb  EASY GOING.WOOLY
	defb 020h,04ah,055h,04dh,050h,045h,052h,0a0h,054h,045h,052h,052h,059h,027h,053h,020h	; a4db   JUMPER.TERRY'S 
	defb 054h,045h,053h,054h,0a0h,050h,045h,054h,045h,020h,053h,054h,052h,045h,045h,054h	; a4eb  TEST.PETE STREET
	defb 0a0h,048h,041h,043h,04bh,045h,052h,053h,020h,045h,056h,049h,04ch,020h,048h,04fh	; a4fb  .HACKERS EVIL HO
	defb 04ch,045h,053h,0a0h,047h,052h,045h,047h,020h,054h,048h,045h,020h,04eh,049h,050h	; a50b  LES.GREG THE NIP
	defb 050h,045h,052h,0a0h,053h,048h,041h,055h,04eh,020h,04eh,04fh,054h,020h,053h,045h	; a51b  PER.SHAUN NOT SE
	defb 041h,04eh,021h,021h,0a0h,04ah,041h,053h,04fh,04eh,027h,053h,020h,04ah,055h,04dh	; a52b  AN!!.JASON'S JUM
	defb 050h,041h,042h,04fh,055h,054h,0a0h,04dh,041h,052h,04bh,027h,053h,020h,04dh,04fh	; a53b  PABOUT.MARK'S MO
	defb 054h,04fh,052h,04fh,04ch,041h,0a0h,043h,048h,052h,049h,053h,027h,053h,020h,043h	; a54b  TOROLA.CHRIS'S C
	defb 055h,04ch,02dh,044h,045h,02dh,053h,041h,043h,0a0h,057h,045h,04ch,04ch,020h,049h	; a55b  UL-DE-SAC.WELL I
	defb 020h,04eh,045h,056h,045h,052h,0a0h,053h,048h,052h,049h,047h,047h,04ch,045h,053h	; a56b   NEVER.SHRIGGLES
	defb 027h,053h,020h,053h,048h,052h,049h,047h,047h,04ch,045h,0a0h,042h,04fh,049h,04eh	; a57b  'S SHRIGGLE.BOIN
	defb 047h,020h,042h,04fh,049h,04eh,047h,020h,053h,050h,04ch,041h,054h,021h,021h,0a0h	; a58b  G BOING SPLAT!!.
	defb 04ch,041h,053h,054h,020h,042h,055h,054h,020h,04eh,04fh,054h,020h,04ch,045h,041h	; a59b  LAST BUT NOT LEA
	defb 053h,054h,021h,0a0h	; a5ab

; ----------------------------------------------------------------------
; DATOS patrones_banco_0: 0x800 bytes literales a VRAM 0x0000; los vuelcan
;   0x89AB y 0x9C5D
;   0xa5af..0xadaf  (2048 bytes)
DATA_patrones_banco_0:
	defb 03fh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,000h	; a5af  ?...............
	defb 000h,000h,000h,000h,000h,000h,000h,0fch,000h,03fh,000h,000h,000h,000h,000h,0fch	; a5bf  .........?......
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a5cf  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a5df  ................
	defb 0ffh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,000h	; a5ef  ................
	defb 000h,000h,000h,000h,000h,000h,000h,0ffh,000h,0ffh,000h,000h,000h,000h,000h,0ffh	; a5ff  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a60f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a61f  ................
	defb 0ffh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,000h	; a62f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,0ffh,000h,0ffh,000h,000h,000h,000h,000h,0ffh	; a63f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a64f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a65f  ................
	defb 0feh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a66f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,07fh,000h,0feh,000h,000h,000h,000h,000h,07fh	; a67f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a68f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a69f  ................
	defb 041h,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,081h,07fh	; a6af  A...............
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,082h,000h,041h,07fh,0ffh,0ffh,0ffh,0feh,082h	; a6bf  .........A......
	defb 05eh,03ch,03ch,03ch,07ch,07eh,000h,000h,000h,000h,000h,000h,000h,000h,07ah,006h	; a6cf  ^<<<|~........z.
	defb 066h,042h,07ch,000h,000h,000h,000h,07ah,000h,05eh,01ch,01ch,000h,01ch,01ch,07ah	; a6df  fB|....z.^.....z
	defb 081h,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,081h,07fh	; a6ef  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,081h,000h,081h,07fh,0ffh,0ffh,0ffh,0feh,081h	; a6ff  ................
	defb 05eh,060h,07eh,066h,07eh,060h,000h,000h,000h,000h,000h,000h,000h,000h,07ah,000h	; a70f  ^`~f~`........z.
	defb 000h,000h,000h,000h,000h,000h,000h,07ah,000h,05eh,01ch,01ch,000h,01ch,01ch,07ah	; a71f  .......z.^.....z
	defb 081h,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0bfh,07fh	; a72f  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,081h,000h,081h,07fh,0ffh,0ffh,0ffh,0feh,081h	; a73f  ................
	defb 05eh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a74f  ^...............
	defb 000h,000h,000h,000h,000h,000h,000h,07ah,000h,05eh,01ch,01ch,000h,01ch,01ch,07ah	; a75f  .......z.^.....z
	defb 0bdh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a76f  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0bdh,000h,0bdh,07fh,0ffh,0ffh,0ffh,0feh,0bdh	; a77f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a78f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a79f  ................
	defb 09fh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,09fh,000h	; a7af  ................
	defb 000h,000h,000h,000h,000h,000h,000h,0f9h,000h,09fh,000h,000h,000h,000h,000h,0f9h	; a7bf  ................
	defb 05eh,066h,066h,066h,066h,062h,000h,000h,000h,000h,000h,000h,000h,000h,07ah,006h	; a7cf  ^ffffb........z.
	defb 066h,066h,066h,000h,000h,000h,000h,07ah,000h,05eh,036h,036h,000h,036h,036h,07ah	; a7df  fff....z.^66.66z
	defb 087h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,09fh,000h	; a7ef  ................
	defb 000h,000h,000h,000h,000h,000h,000h,0e1h,000h,087h,077h,0ffh,0ffh,0ffh,0eeh,0e1h	; a7ff  ..........w.....
	defb 05eh,060h,062h,066h,062h,060h,000h,000h,000h,000h,000h,000h,000h,000h,07ah,000h	; a80f  ^`bfb`........z.
	defb 000h,000h,000h,000h,000h,000h,000h,07ah,000h,05eh,036h,036h,000h,036h,036h,07ah	; a81f  .......z.^66.66z
	defb 087h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0bfh,000h	; a82f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,0e1h,000h,087h,000h,000h,000h,000h,000h,0e1h	; a83f  ................
	defb 05eh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a84f  ^...............
	defb 000h,000h,000h,000h,000h,000h,000h,07ah,000h,05eh,036h,036h,000h,036h,036h,07ah	; a85f  .......z.^66.66z
	defb 0bbh,077h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a86f  .w..............
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0eeh,0ddh,000h,0bbh,077h,0ffh,0ffh,0ffh,0eeh,0ddh	; a87f  ..........w.....
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a88f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a89f  ................
	defb 0afh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0bfh,07fh	; a8af  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f5h,000h,0afh,07fh,0ffh,0ffh,0ffh,0feh,0f5h	; a8bf  ................
	defb 05eh,060h,060h,066h,066h,060h,018h,000h,000h,000h,000h,000h,000h,000h,07ah,006h	; a8cf  ^``ff`........z.
	defb 066h,07eh,066h,018h,000h,000h,000h,07ah,000h,05eh,063h,063h,018h,063h,063h,07ah	; a8df  f~f....z.^cc.ccz
	defb 08fh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0bfh,07fh	; a8ef  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f1h,000h,08fh,07fh,0ffh,0ffh,0ffh,0feh,0f1h	; a8ff  ................
	defb 05eh,060h,060h,066h,060h,060h,018h,000h,000h,000h,000h,000h,000h,000h,07ah,000h	; a90f  ^``f``........z.
	defb 000h,000h,000h,000h,000h,000h,000h,07ah,000h,05eh,063h,063h,018h,063h,063h,07ah	; a91f  .......z.^cc.ccz
	defb 08fh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0bfh,07fh	; a92f  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f1h,000h,08fh,07fh,0ffh,0ffh,0ffh,0feh,0f1h	; a93f  ................
	defb 05eh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a94f  ^...............
	defb 000h,000h,000h,000h,000h,000h,000h,07ah,000h,05eh,063h,063h,018h,063h,063h,07ah	; a95f  .......z.^cc.ccz
	defb 0b7h,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a96f  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0edh,000h,0b7h,07fh,0ffh,0ffh,0ffh,0feh,0edh	; a97f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a98f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; a99f  ................
	defb 0b7h,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0bfh,07fh	; a9af  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0edh,000h,0b7h,07fh,0ffh,0ffh,0ffh,0feh,0edh	; a9bf  ................
	defb 05eh,03ch,060h,066h,064h,078h,018h,000h,000h,000h,000h,000h,000h,000h,07ah,066h	; a9cf  ^<`fdx........zf
	defb 066h,05ah,066h,018h,000h,000h,000h,07ah,000h,05eh,06bh,06bh,018h,06bh,06bh,07ah	; a9df  fZf....z.^kk.kkz
	defb 09fh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0bfh,07fh	; a9ef  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f9h,000h,09fh,07fh,0ffh,0ffh,0ffh,0feh,0f9h	; a9ff  ................
	defb 05eh,060h,078h,066h,078h,060h,018h,000h,000h,000h,000h,000h,000h,000h,07ah,000h	; aa0f  ^`xfx`........z.
	defb 000h,000h,000h,000h,000h,000h,000h,07ah,000h,05eh,06bh,06bh,018h,06bh,06bh,07ah	; aa1f  .......z.^kk.kkz
	defb 09fh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0bfh,07fh	; aa2f  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f9h,000h,09fh,07fh,0ffh,0ffh,0ffh,0feh,0f9h	; aa3f  ................
	defb 05eh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; aa4f  ^...............
	defb 000h,000h,000h,000h,000h,000h,000h,07ah,000h,05eh,06bh,06bh,018h,06bh,06bh,07ah	; aa5f  .......z.^kk.kkz
	defb 0afh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; aa6f  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f5h,000h,0afh,07fh,0ffh,0ffh,0ffh,0feh,0f5h	; aa7f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; aa8f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; aa9f  ................
	defb 0bbh,077h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0eeh,0bfh,077h	; aaaf  .w.............w
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0eeh,0ddh,000h,0bbh,077h,0ffh,0ffh,0ffh,0eeh,0ddh	; aabf  ..........w.....
	defb 05eh,006h,060h,066h,078h,060h,000h,000h,000h,000h,000h,000h,000h,000h,07ah,066h	; aacf  ^.`fx`........zf
	defb 066h,066h,07ch,000h,000h,000h,000h,07ah,000h,05eh,063h,063h,000h,063h,063h,07ah	; aadf  ff|....z.^cc.ccz
	defb 0bfh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0bfh,000h	; aaef  ................
	defb 000h,000h,000h,000h,000h,000h,000h,0fdh,000h,0bfh,000h,000h,000h,000h,000h,0fdh	; aaff  ................
	defb 05eh,060h,060h,024h,060h,060h,000h,000h,000h,000h,000h,000h,000h,000h,07ah,000h	; ab0f  ^``$``........z.
	defb 000h,000h,000h,000h,000h,000h,000h,07ah,000h,05eh,063h,063h,000h,063h,063h,07ah	; ab1f  .......z.^cc.ccz
	defb 0bfh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,09fh,000h	; ab2f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,0fdh,000h,0bfh,077h,0ffh,0ffh,0ffh,0eeh,0fdh	; ab3f  ..........w.....
	defb 05eh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ab4f  ^...............
	defb 000h,000h,000h,000h,000h,000h,000h,07ah,000h,05eh,063h,063h,000h,063h,063h,07ah	; ab5f  .......z.^cc.ccz
	defb 09fh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ab6f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,0f9h,000h,09fh,000h,000h,000h,000h,000h,0f9h	; ab7f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ab8f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ab9f  ................
	defb 0bdh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0bfh,07fh	; abaf  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0bdh,000h,0bdh,07fh,0ffh,0ffh,0ffh,0feh,0bdh	; abbf  ................
	defb 05eh,066h,066h,066h,06ch,062h,018h,000h,000h,000h,000h,000h,000h,000h,07ah,066h	; abcf  ^ffflb........zf
	defb 066h,066h,060h,018h,000h,000h,000h,07ah,000h,05eh,036h,036h,018h,036h,036h,07ah	; abdf  ff`....z.^66.66z
	defb 0bfh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0bfh,07fh	; abef  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0fdh,000h,0bfh,07fh,0ffh,0ffh,0ffh,0feh,0fdh	; abff  ................
	defb 05eh,062h,062h,03ch,062h,062h,018h,000h,000h,000h,000h,000h,000h,000h,07ah,000h	; ac0f  ^bb<bb........z.
	defb 000h,000h,000h,000h,000h,000h,000h,07ah,000h,05eh,036h,036h,018h,036h,036h,07ah	; ac1f  .......z.^66.66z
	defb 0bfh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,081h,07fh	; ac2f  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0fdh,000h,0bfh,07fh,0ffh,0ffh,0ffh,0feh,0fdh	; ac3f  ................
	defb 05eh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ac4f  ^...............
	defb 000h,000h,000h,000h,000h,000h,000h,07ah,000h,05eh,036h,036h,018h,036h,036h,07ah	; ac5f  .......z.^66.66z
	defb 041h,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ac6f  A...............
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,082h,000h,041h,07fh,0ffh,0ffh,0ffh,0feh,082h	; ac7f  .........A......
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ac8f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ac9f  ................
	defb 0feh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,000h	; acaf  ................
	defb 000h,000h,000h,000h,000h,000h,000h,07fh,000h,0feh,000h,000h,000h,000h,000h,07fh	; acbf  ................
	defb 000h,03ch,03ch,03ch,066h,07eh,018h,000h,000h,000h,000h,000h,000h,000h,000h,03ch	; accf  .<<<f~.........<
	defb 03ch,066h,060h,018h,000h,000h,000h,000h,000h,000h,01ch,01ch,018h,01ch,01ch,000h	; acdf  <f`.............
	defb 0ffh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,000h	; acef  ................
	defb 000h,000h,000h,000h,000h,000h,000h,0ffh,000h,0ffh,000h,000h,000h,000h,000h,0ffh	; acff  ................
	defb 000h,07eh,07eh,018h,07eh,07eh,018h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ad0f  .~~.~~..........
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01ch,01ch,018h,01ch,01ch,000h	; ad1f  ................
	defb 0ffh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,000h	; ad2f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,0ffh,000h,0ffh,000h,000h,000h,000h,000h,0ffh	; ad3f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ad4f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01ch,01ch,018h,01ch,01ch,000h	; ad5f  ................
	defb 03fh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ad6f  ?...............
	defb 000h,000h,000h,000h,000h,000h,000h,0fch,000h,03fh,000h,000h,000h,000h,000h,0fch	; ad7f  .........?......
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ad8f  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ad9f  ................

; ----------------------------------------------------------------------
; DATOS nombres_primer_tercio: 0x100 bytes a VRAM 0x1800; lo vuelca 0x9C69
;   0xadaf..0xaeaf  (256 bytes)
DATA_nombres_primer_tercio:
	defb 046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h	; adaf  FFFFFFFFFFFFFFFF
	defb 046h,046h,046h,046h,046h,046h,046h,046h,047h,045h,045h,045h,045h,045h,045h,045h	; adbf  FFFFFFFFGEEEEEEE
	defb 044h,04eh,04eh,04eh,04eh,04eh,04eh,04eh,04eh,04eh,04eh,04eh,04eh,04eh,044h,05fh	; adcf  DNNNNNNNNNNNNND_
	defb 05fh,05fh,05fh,05fh,078h,078h,078h,044h,047h,003h,04eh,04eh,04eh,04eh,04eh,003h	; addf  ____xxxDG.NNNNN.
	defb 04eh,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h	; adef  NFFFFFFFFFFFFFFF
	defb 046h,046h,046h,046h,046h,046h,046h,04eh,047h,045h,045h,045h,045h,045h,045h,045h	; adff  FFFFFFFNGEEEEEEE
	defb 044h,068h,068h,068h,068h,068h,068h,068h,068h,068h,068h,068h,068h,068h,044h,04fh	; ae0f  DhhhhhhhhhhhhhDO
	defb 04fh,04fh,04fh,04fh,04fh,04fh,04fh,044h,047h,003h,04eh,04eh,04eh,04eh,04eh,003h	; ae1f  OOOOOOODG.NNNNN.
	defb 04eh,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h	; ae2f  NFFFFFFFFFFFFFFF
	defb 046h,046h,046h,046h,046h,046h,046h,04eh,047h,045h,045h,045h,045h,045h,045h,045h	; ae3f  FFFFFFFNGEEEEEEE
	defb 044h,057h,057h,057h,057h,057h,057h,057h,057h,057h,057h,057h,057h,057h,057h,057h	; ae4f  DWWWWWWWWWWWWWWW
	defb 057h,057h,057h,057h,057h,057h,056h,044h,047h,003h,04eh,04eh,04eh,04eh,04eh,003h	; ae5f  WWWWWWVDG.NNNNN.
	defb 046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h	; ae6f  FFFFFFFFFFFFFFFF
	defb 046h,046h,046h,046h,046h,046h,046h,046h,047h,045h,045h,045h,045h,045h,045h,045h	; ae7f  FFFFFFFFGEEEEEEE
	defb 047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h	; ae8f  GGGGGGGGGGGGGGGG
	defb 047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h	; ae9f  GGGGGGGGGGGGGGGG

; ----------------------------------------------------------------------
; DATOS nombres_otros_dos_tercios: 0x200 bytes a VRAM 0x1900; lo vuelca 0x9CBB
;   0xaeaf..0xb0af  (512 bytes)
DATA_nombres_otros_dos_tercios:
	defb 044h,044h,044h,044h,044h,044h,044h,044h,044h,044h,044h,044h,044h,044h,044h,044h	; aeaf  DDDDDDDDDDDDDDDD
	defb 044h,044h,044h,044h,044h,044h,044h,044h,044h,044h,044h,044h,044h,044h,044h,044h	; aebf  DDDDDDDDDDDDDDDD
	defb 045h,045h,045h,045h,045h,045h,045h,045h,045h,045h,045h,045h,045h,045h,045h,045h	; aecf  EEEEEEEEEEEEEEEE
	defb 045h,045h,045h,045h,045h,045h,045h,045h,045h,045h,045h,045h,045h,045h,045h,045h	; aedf  EEEEEEEEEEEEEEEE
	defb 046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h	; aeef  FFFFFFFFFFFFFFFF
	defb 046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h	; aeff  FFFFFFFFFFFFFFFF
	defb 047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h	; af0f  GGGGGGGGGGGGGGGG
	defb 047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h	; af1f  GGGGGGGGGGGGGGGG
	defb 041h,041h,041h,041h,041h,041h,041h,041h,041h,041h,041h,041h,041h,041h,041h,041h	; af2f  AAAAAAAAAAAAAAAA
	defb 041h,041h,041h,041h,041h,041h,041h,041h,041h,041h,041h,041h,041h,041h,041h,041h	; af3f  AAAAAAAAAAAAAAAA
	defb 042h,042h,042h,042h,042h,042h,042h,042h,042h,042h,042h,042h,042h,042h,042h,042h	; af4f  BBBBBBBBBBBBBBBB
	defb 042h,042h,042h,042h,042h,042h,042h,042h,042h,042h,042h,042h,042h,042h,042h,042h	; af5f  BBBBBBBBBBBBBBBB
	defb 047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h	; af6f  GGGGGGGGGGGGGGGG
	defb 047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h	; af7f  GGGGGGGGGGGGGGGG
	defb 047h,047h,047h,047h,047h,043h,043h,043h,043h,047h,047h,047h,047h,046h,047h,047h	; af8f  GGGGGCCCCGGGGFGG
	defb 047h,047h,047h,047h,006h,046h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h	; af9f  GGGG.FGGGGGGGGGG
	defb 047h,046h,047h,043h,043h,043h,043h,043h,047h,047h,046h,045h,047h,047h,047h,045h	; afaf  GFGCCCCCGGFEGGGE
	defb 047h,047h,044h,047h,006h,046h,006h,047h,047h,047h,047h,047h,047h,047h,047h,047h	; afbf  GGDG.F.GGGGGGGGG
	defb 047h,047h,043h,043h,043h,043h,043h,043h,047h,046h,046h,046h,046h,046h,047h,045h	; afcf  GGCCCCCCGFFFFFGE
	defb 047h,047h,047h,047h,047h,047h,047h,045h,047h,047h,047h,047h,047h,047h,047h,047h	; afdf  GGGGGGGEGGGGGGGG
	defb 044h,044h,044h,044h,044h,044h,044h,044h,047h,047h,046h,046h,046h,046h,047h,045h	; afef  DDDDDDDDGGFFFFGE
	defb 047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h,047h	; afff  GGGGGGGGGGGGGGGG
	defb 044h,044h,044h,044h,044h,044h,047h,047h,047h,047h,046h,046h,046h,046h,047h,045h	; b00f  DDDDDDGGGGFFFFGE
	defb 047h,047h,047h,047h,047h,047h,045h,045h,047h,046h,046h,047h,047h,047h,047h,047h	; b01f  GGGGGGEEGFFGGGGG
	defb 044h,044h,044h,044h,044h,047h,047h,046h,047h,047h,046h,046h,046h,042h,047h,045h	; b02f  DDDDDGGFGGFFFBGE
	defb 047h,047h,047h,047h,047h,047h,045h,045h,047h,047h,047h,047h,047h,047h,047h,047h	; b03f  GGGGGGEEGGGGGGGG
	defb 047h,047h,047h,047h,045h,047h,047h,047h,047h,047h,045h,047h,047h,047h,047h,045h	; b04f  GGGGEGGGGGEGGGGE
	defb 047h,047h,047h,042h,047h,045h,045h,045h,047h,047h,047h,047h,047h,047h,047h,047h	; b05f  GGGBGEEEGGGGGGGG
	defb 046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h	; b06f  FFFFFFFFFFFFFFFF
	defb 046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,000h	; b07f  FFFFFFFFFFFFFFF.
	defb 046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h	; b08f  FFFFFFFFFFFFFFFF
	defb 046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,046h,000h	; b09f  FFFFFFFFFFFFFFF.

; ----------------------------------------------------------------------
; DATOS guion_de_patrones: RLE de 2678 bytes que da los 4096 de los bancos 1 y
;   2; lo lee 0x9C87 sobre la RAM en 0x4800 y de ahi 0x9CB2 lo vuelca a VRAM
;   0x0800. El formato: si el byte es 0x00 o 0xFF, el siguiente es la cuenta y
;   se repite ese byte; cualquier otro va literal. Ejecutado en Python acaba
;   EXACTAMENTE en 0xBB25, donde empieza la fuente
;   0xb0af..0xbb25  (2678 bytes)
DATA_guion_de_patrones:
	defb 0ffh,003h,0efh,0ffh,002h,0c1h,0ffh,002h,0f3h,0fch,0ffh,001h,000h,001h,007h,0ffh	; b0af  ................
	defb 002h,0c0h,0ffh,001h,000h,001h,001h,0ffh,002h,0f1h,0ffh,002h,0f8h,0ffh,002h,0feh	; b0bf  ................
	defb 03fh,0ffh,001h,0feh,000h,001h,07eh,080h,00fh,0d0h,03fh,021h,0fah,00fh,0d3h,0f4h	; b0cf  ?.....~...?!....
	defb 0fdh,000h,001h,007h,0d0h,01fh,040h,0fdh,000h,001h,001h,0fah,00fh,0d0h,000h,001h	; b0df  ......@.........
	defb 00fh,0d0h,0fdh,000h,002h,03fh,040h,0fdh,000h,001h,07eh,080h,00fh,0ffh,001h,0feh	; b0ef  .....?@...~.....
	defb 041h,0ffh,002h,0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh,040h,0fdh,000h,001h,001h	; b0ff  A..........@....
	defb 0ffh,002h,0d0h,000h,001h,0feh,080h,0ffh,001h,0fch,000h,001h,03fh,0ffh,001h,0f2h	; b10f  ............?...
	defb 000h,001h,07eh,080h,00fh,0d3h,0e8h,001h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h,007h	; b11f  ..~.............
	defb 0ffh,002h,0b0h,0fdh,000h,001h,001h,0fah,00fh,0d0h,00fh,0e8h,000h,001h,0fdh,000h	; b12f  ................
	defb 002h,03fh,04fh,040h,000h,001h,07eh,080h,00fh,0d0h,0fah,001h,0fah,00fh,0d3h,0f4h	; b13f  .?O@..~.........
	defb 0fdh,000h,001h,007h,0d0h,01fh,0e8h,0fdh,000h,001h,001h,0fah,00fh,0d0h,03fh,040h	; b14f  ..............?@
	defb 000h,001h,0fdh,000h,002h,03fh,043h,0d0h,000h,001h,07eh,080h,00fh,0d0h,03eh,081h	; b15f  .....?C...~...>.
	defb 0fah,00fh,0d3h,0f4h,0ffh,002h,047h,0ffh,002h,0e8h,0ffh,002h,0d1h,0fah,00fh,0d1h	; b16f  ......G.........
	defb 0ffh,002h,0e8h,0ffh,002h,0fah,03fh,040h,0f4h,000h,034h,082h,0a0h,000h,00ah,0ffh	; b17f  ......?@..4.....
	defb 003h,0afh,0ffh,002h,021h,0ffh,002h,0d3h,0f4h,0fdh,000h,001h,007h,0ffh,002h,040h	; b18f  ....!..........@
	defb 0fdh,000h,001h,001h,0ffh,002h,0d1h,0ffh,002h,0e8h,0ffh,002h,0fah,03fh,0ffh,001h	; b19f  .............?..
	defb 0f9h,000h,001h,07eh,080h,00fh,0d0h,03fh,041h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h	; b1af  ...~...?A.......
	defb 007h,0d0h,01fh,040h,0fdh,000h,001h,001h,0fah,00fh,0d0h,000h,001h,00fh,0d0h,0fdh	; b1bf  ...@............
	defb 000h,002h,03fh,040h,0f9h,000h,001h,07eh,080h,00fh,0ffh,001h,0feh,081h,0ffh,002h	; b1cf  ..?@...~........
	defb 0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh,040h,0fdh,000h,001h,001h,0ffh,002h,0d0h	; b1df  ........@.......
	defb 000h,001h,0fch,080h,0ffh,001h,0f4h,000h,001h,03fh,0ffh,001h,0f4h,000h,001h,07eh	; b1ef  .........?.....~
	defb 080h,00fh,0d3h,0e4h,001h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h,007h,0ffh,002h,0d8h	; b1ff  ................
	defb 0fdh,000h,001h,001h,0fah,00fh,0d0h,00fh,0c8h,000h,001h,0fdh,000h,002h,03fh,04fh	; b20f  ..............?O
	defb 020h,000h,001h,07eh,080h,00fh,0d0h,0f9h,001h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h	; b21f   ..~............
	defb 007h,0d0h,01fh,0e8h,0fdh,000h,001h,001h,0fah,00fh,0d0h,07fh,040h,000h,001h,0fdh	; b22f  ............@...
	defb 000h,002h,03fh,043h,0c8h,000h,001h,07eh,080h,00fh,0d0h,03eh,041h,0fah,00fh,0d3h	; b23f  ..?C...~...>A...
	defb 0f4h,0ffh,002h,047h,0ffh,002h,0e8h,0ffh,002h,0d1h,0fah,00fh,0d1h,0ffh,002h,0e8h	; b24f  ...G............
	defb 0ffh,002h,0fah,03fh,040h,0f2h,000h,034h,055h,0f8h,000h,00ah,0ffh,003h,0afh,0ffh	; b25f  ...?@..4U.......
	defb 002h,0a1h,0ffh,002h,0d3h,0f4h,0fdh,000h,001h,007h,0ffh,002h,040h,0fdh,000h,001h	; b26f  ............@...
	defb 001h,0ffh,002h,0d1h,0ffh,002h,0e8h,0ffh,002h,0fah,03fh,0ffh,001h,0fdh,000h,001h	; b27f  ..........?.....
	defb 07eh,080h,00fh,0d0h,03fh,041h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh	; b28f  ~...?A..........
	defb 040h,0fdh,000h,001h,001h,0fah,00fh,0d0h,000h,001h,01fh,090h,0fdh,000h,002h,03fh	; b29f  @..............?
	defb 040h,0fah,000h,001h,07eh,080h,00fh,0ffh,001h,0feh,081h,0ffh,002h,0d3h,0f4h,0fdh	; b2af  @...~...........
	defb 000h,001h,007h,0d0h,01fh,040h,0fdh,000h,001h,001h,0ffh,002h,0d0h,001h,0fdh,000h	; b2bf  .....@..........
	defb 001h,0ffh,001h,0f4h,000h,001h,03fh,0ffh,001h,0f4h,000h,001h,07eh,080h,00fh,0d3h	; b2cf  ......?.....~...
	defb 0f4h,001h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h,007h,0c0h,01fh,0e8h,0fdh,000h,001h	; b2df  ................
	defb 001h,0fah,00fh,0d0h,00fh,0d0h,000h,001h,0fdh,000h,002h,03fh,04fh,0a0h,000h,001h	; b2ef  ...........?O...
	defb 07eh,080h,00fh,0d0h,0fdh,001h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh	; b2ff  ~...............
	defb 0e8h,0fdh,000h,001h,001h,0fah,00fh,0d0h,07eh,040h,000h,001h,0fdh,000h,002h,03fh	; b30f  ........~@.....?
	defb 043h,0e8h,000h,001h,07eh,080h,00fh,0d0h,03fh,041h,0fah,00fh,0d3h,0f4h,0ffh,002h	; b31f  C...~...?A......
	defb 047h,0ffh,002h,0e8h,0ffh,002h,0d1h,0fah,00fh,0d1h,0ffh,002h,0e8h,0ffh,002h,0fah	; b32f  G...............
	defb 03fh,040h,0fah,000h,034h,02bh,0fch,000h,00ah,0ffh,003h,0afh,0ffh,002h,0a1h,0ffh	; b33f  ?@..4+..........
	defb 002h,0d3h,0f4h,0fdh,000h,001h,007h,0ffh,002h,040h,0fdh,000h,001h,001h,0ffh,002h	; b34f  .........@......
	defb 0d1h,0ffh,002h,0e8h,0ffh,002h,0fah,03fh,0ffh,001h,0fdh,000h,001h,07eh,080h,00fh	; b35f  .......?.....~..
	defb 0d0h,03fh,041h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh,040h,0fdh,000h	; b36f  .?A..........@..
	defb 001h,001h,0fah,00fh,0d0h,000h,001h,01fh,0a0h,0fdh,000h,002h,03fh,040h,0fah,000h	; b37f  ............?@..
	defb 001h,07eh,080h,00fh,0ffh,001h,0feh,081h,0ffh,002h,0d3h,0f4h,0fdh,000h,001h,007h	; b38f  .~..............
	defb 0ffh,002h,040h,0fdh,000h,001h,001h,0ffh,002h,0d0h,001h,0f9h,000h,001h,0ffh,001h	; b39f  ..@.............
	defb 0f4h,000h,001h,03fh,0ffh,001h,0f4h,000h,001h,07eh,080h,00fh,0d1h,0f4h,001h,0fah	; b3af  ...?.....~......
	defb 00fh,0d3h,0f4h,0fdh,000h,001h,007h,0dfh,0ffh,001h,0e8h,0fdh,000h,001h,001h,0fah	; b3bf  ................
	defb 00fh,0d0h,01fh,0d0h,000h,001h,0fdh,000h,002h,03fh,047h,0a0h,000h,001h,07eh,080h	; b3cf  .........?G...~.
	defb 00fh,0d0h,07dh,001h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh,0e8h,0fdh	; b3df  ..}.............
	defb 000h,001h,001h,0fah,00fh,0d0h,07eh,080h,000h,001h,0fdh,000h,002h,03fh,041h,0e8h	; b3ef  ......~......?A.
	defb 000h,001h,07eh,080h,00fh,0d0h,01fh,041h,0fah,00fh,0d3h,0f4h,0ffh,002h,047h,0ffh	; b3ff  ..~....A......G.
	defb 002h,0e8h,0ffh,002h,0d1h,0fah,00fh,0d1h,0ffh,002h,0e8h,0ffh,002h,0fah,03fh,040h	; b40f  ..............?@
	defb 07ah,000h,02dh,010h,000h,006h,017h,0feh,000h,00ah,0ffh,003h,0afh,0ffh,002h,0a1h	; b41f  z.-.............
	defb 0ffh,002h,0d3h,0f4h,0fdh,000h,001h,007h,0ffh,002h,040h,0fdh,000h,001h,001h,0ffh	; b42f  ..........@.....
	defb 002h,0d1h,0ffh,002h,0e8h,0ffh,002h,0fah,03fh,0ffh,001h,0fdh,000h,001h,07eh,080h	; b43f  ........?.....~.
	defb 00fh,0d0h,07fh,041h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh,040h,0fdh	; b44f  ...A..........@.
	defb 000h,001h,001h,0fah,00fh,0d0h,000h,001h,03fh,0a0h,0fdh,000h,002h,03fh,040h,0fah	; b45f  ........?....?@.
	defb 000h,001h,07eh,080h,00fh,0ffh,001h,0feh,081h,0ffh,002h,0d3h,0f4h,0fdh,000h,001h	; b46f  ..~.............
	defb 007h,0ffh,002h,040h,0fdh,000h,001h,001h,0ffh,002h,0d0h,003h,0fah,000h,001h,0ffh	; b47f  ...@............
	defb 001h,0f4h,000h,001h,03fh,0ffh,001h,0f4h,000h,001h,07eh,080h,00fh,0d1h,0f4h,001h	; b48f  ....?.....~.....
	defb 0fah,00fh,0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh,0e8h,0fdh,000h,001h,001h,0fah	; b49f  ................
	defb 00fh,0d0h,01fh,090h,000h,001h,0fdh,000h,002h,03fh,047h,0a0h,000h,001h,07eh,080h	; b4af  .........?G...~.
	defb 00fh,0d0h,07dh,001h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh,0e8h,0fdh	; b4bf  ..}.............
	defb 000h,001h,001h,0fah,00fh,0d0h,0feh,080h,000h,001h,0fdh,000h,002h,03fh,041h,0e8h	; b4cf  .............?A.
	defb 000h,001h,07eh,080h,00fh,0d0h,01fh,041h,0fah,00fh,0d3h,0f4h,0ffh,002h,047h,0ffh	; b4df  ..~....A......G.
	defb 002h,0e8h,0ffh,002h,0d1h,0fah,00fh,0d1h,0ffh,002h,0e8h,0ffh,002h,0fah,03fh,040h	; b4ef  ..............?@
	defb 07ah,000h,034h,00fh,0feh,000h,00ah,0ffh,003h,0afh,0ffh,002h,0a1h,0ffh,002h,0d3h	; b4ff  z.4.............
	defb 0f4h,0fdh,000h,001h,007h,0ffh,002h,040h,0fdh,000h,001h,001h,0ffh,002h,0d1h,0ffh	; b50f  .......@........
	defb 002h,0e8h,0ffh,002h,0fah,03fh,0ffh,001h,0fdh,000h,001h,07eh,080h,00fh,0d0h,07fh	; b51f  .....?.....~....
	defb 041h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh,040h,0fdh,000h,001h,001h	; b52f  A..........@....
	defb 0fah,00fh,0d0h,000h,001h,03fh,020h,0fdh,000h,002h,03fh,041h,0fah,000h,001h,07eh	; b53f  .....? ...?A...~
	defb 080h,00fh,0ffh,001h,0fch,081h,0ffh,002h,0d3h,0f4h,0fdh,000h,001h,007h,0ffh,002h	; b54f  ................
	defb 040h,0fdh,000h,001h,001h,0ffh,002h,0d0h,003h,0f2h,000h,001h,0ffh,001h,0f4h,000h	; b55f  @...............
	defb 001h,03fh,0ffh,001h,0e4h,000h,001h,07eh,080h,00fh,0d1h,0f2h,001h,0fah,00fh,0d3h	; b56f  .?.....~........
	defb 0f4h,0fdh,000h,001h,007h,0d0h,01fh,0e8h,0fdh,000h,001h,001h,0fah,00fh,0d0h,01fh	; b57f  ................
	defb 0a0h,000h,001h,0fdh,000h,002h,03fh,047h,090h,000h,001h,07eh,080h,00fh,0d0h,07ch	; b58f  ......?G...~...|
	defb 081h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh,0e8h,0fdh,000h,001h,001h	; b59f  ................
	defb 0fah,00fh,0d0h,0fch,080h,000h,001h,0fdh,000h,002h,03fh,041h,0e4h,000h,001h,07eh	; b5af  ..........?A...~
	defb 080h,00fh,0d0h,01fh,021h,0fah,00fh,0d3h,0f4h,0ffh,002h,047h,0ffh,002h,0e8h,0ffh	; b5bf  ....!......G....
	defb 002h,0d1h,0fah,00fh,0d1h,0ffh,002h,0e8h,0ffh,002h,0fah,03fh,040h,079h,000h,013h	; b5cf  ...........?@y..
	defb 080h,000h,020h,047h,0ffh,001h,000h,00ah,080h,07eh,000h,001h,02fh,0c0h,03fh,0a1h	; b5df  .. G.....~../.?.
	defb 0f8h,00fh,0d3h,0f4h,0fdh,000h,001h,007h,0c0h,01fh,040h,0fdh,000h,001h,001h,0f8h	; b5ef  ..........@.....
	defb 00fh,0d1h,000h,001h,007h,0e8h,0fch,000h,001h,002h,03fh,000h,001h,0fdh,000h,001h	; b5ff  ..........?.....
	defb 07eh,080h,00fh,0d0h,07fh,041h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh	; b60f  ~....A..........
	defb 040h,0fdh,000h,001h,001h,0fah,00fh,0d0h,000h,001h,07fh,040h,0fdh,000h,002h,03fh	; b61f  @..........@...?
	defb 041h,0fah,000h,001h,07eh,080h,00fh,0c7h,0e1h,081h,0f8h,00fh,0d3h,0f4h,0fdh,000h	; b62f  A...~...........
	defb 001h,007h,0ffh,002h,040h,0fdh,000h,001h,001h,0f8h,00fh,0d0h,007h,0f4h,000h,001h	; b63f  ....@...........
	defb 0fch,004h,000h,001h,03fh,01fh,00ch,000h,001h,07eh,080h,00fh,0d1h,0fah,001h,0fah	; b64f  ....?....~......
	defb 00fh,0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh,0e8h,0fdh,000h,001h,001h,0fah,00fh	; b65f  ................
	defb 0d0h,03fh,0a0h,000h,001h,0fdh,000h,002h,03fh,047h,0d0h,000h,001h,07eh,080h,00fh	; b66f  .?......?G...~..
	defb 0d0h,07eh,081h,0fah,00fh,0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh,0e8h,0fdh,000h	; b67f  .~..............
	defb 001h,001h,0fah,00fh,0d0h,0fdh,000h,002h,0fdh,000h,002h,03fh,041h,0f4h,000h,001h	; b68f  ...........?A...
	defb 040h,080h,008h,010h,010h,021h,002h,008h,012h,004h,000h,002h,044h,000h,002h,008h	; b69f  @....!......D...
	defb 080h,000h,001h,010h,002h,008h,011h,000h,002h,008h,080h,000h,001h,002h,020h,040h	; b6af  .............. @
	defb 041h,000h,025h,00fh,0ffh,002h,0feh,000h,00bh,0a3h,0ffh,001h,000h,00ah,0ffh,001h	; b6bf  A.%.............
	defb 0feh,0ffh,001h,0efh,0dfh,0ffh,001h,0a1h,0fbh,0ffh,001h,0d3h,0f4h,0fdh,000h,001h	; b6cf  ................
	defb 007h,0dfh,0ffh,001h,040h,0fdh,000h,001h,001h,0fbh,0ffh,001h,0d1h,0ffh,002h,0c8h	; b6df  ....@...........
	defb 0fdh,0ffh,001h,0feh,03fh,07fh,0fdh,000h,001h,07eh,080h,00fh,0ffh,002h,041h,0ffh	; b6ef  ....?....~....A.
	defb 002h,0d3h,0f4h,0fdh,000h,001h,007h,0d0h,01fh,040h,0fdh,000h,001h,001h,0ffh,002h	; b6ff  .........@......
	defb 0d0h,000h,001h,07eh,040h,0fdh,000h,002h,03fh,041h,0fah,000h,001h,07eh,080h,00fh	; b70f  ...~@...?A...~..
	defb 0dfh,0efh,001h,0fbh,0ffh,001h,0d3h,0f4h,0fdh,000h,001h,007h,0ffh,002h,060h,0fdh	; b71f  ..............`.
	defb 000h,001h,001h,0fbh,0ffh,001h,0d0h,007h,0e4h,000h,001h,0fdh,0fch,000h,001h,03fh	; b72f  ...............?
	defb 07fh,078h,000h,001h,07eh,080h,00fh,0d0h,0fah,001h,0fah,00fh,0d3h,0f4h,0fdh,000h	; b73f  .x..~...........
	defb 001h,007h,0d0h,01fh,0e8h,0fdh,000h,001h,001h,0fah,00fh,0d0h,03fh,020h,000h,001h	; b74f  ............? ..
	defb 0fdh,000h,002h,03fh,043h,0d0h,000h,001h,07eh,080h,00fh,0d0h,03eh,081h,0fah,00fh	; b75f  ...?C...~...>...
	defb 0d3h,0f4h,0ffh,002h,0c7h,0ffh,002h,0e8h,0ffh,002h,0f1h,0fah,00fh,0d1h,0ffh,002h	; b76f  ................
	defb 0f8h,0ffh,002h,0feh,03fh,040h,0f4h,000h,001h,07fh,080h,00fh,0f0h,01fh,0e1h,0feh	; b77f  ....?@..........
	defb 00fh,0f3h,0fch,0ffh,002h,0c7h,0ffh,002h,0f8h,0ffh,002h,0f1h,0feh,00fh,0f1h,0ffh	; b78f  ................
	defb 002h,0f8h,0ffh,002h,0feh,03fh,0c0h,07fh,000h,013h,001h,000h,011h,01fh,0ffh,002h	; b79f  .....?..........
	defb 0f0h,000h,00bh,051h,0ffh,001h,000h,00fh,07fh,0ffh,002h,00fh,0c0h,000h,00ah,0bah	; b7af  ...Q............
	defb 0ffh,001h,000h,00dh,007h,0ffh,004h,003h,03bh,0c0h,000h,004h,02fh,0c0h,000h,005h	; b7bf  ........;.../...
	defb 088h,000h,005h,040h,000h,005h,02ah,0aah,0aah,0aah,0aah,000h,003h,03fh,0dbh,06fh	; b7cf  ...@..*......?.o
	defb 080h,000h,001h,017h,080h,000h,00ah,001h,010h,000h,003h,002h,0aah,0aah,0aah,0aah	; b7df  ................
	defb 0a8h,000h,004h,07fh,0ffh,002h,0c0h,0d7h,017h,080h,000h,009h,010h,000h,005h,0aah	; b7ef  ................
	defb 0aah,0aah,0aah,080h,000h,005h,001h,0ffh,001h,0f0h,000h,001h,00ch,017h,080h,000h	; b7ff  ................
	defb 006h,040h,000h,001h,019h,0cdh,000h,001h,081h,000h,012h,017h,080h,000h,005h,001h	; b80f  .@..............
	defb 010h,000h,04dh,0ffh,002h,0feh,0ffh,001h,0e0h,000h,008h,008h,000h,001h,07dh,07fh	; b81f  ..M...........}.
	defb 000h,00dh,00fh,0ffh,004h,003h,001h,0e0h,000h,004h,02fh,0c0h,000h,00ah,002h,045h	; b82f  ........../....E
	defb 000h,005h,055h,055h,055h,055h,054h,000h,003h,03fh,0bbh,077h,080h,000h,001h,017h	; b83f  ..UUUUT..?.w....
	defb 080h,000h,00fh,005h,055h,055h,055h,055h,050h,000h,004h,03fh,0ffh,002h,080h,0e8h	; b84f  ....UUUUP..?....
	defb 017h,080h,000h,009h,010h,000h,005h,055h,055h,055h,055h,000h,007h,03fh,080h,008h	; b85f  .......UUUU..?..
	defb 000h,001h,017h,080h,000h,005h,002h,045h,000h,001h,00eh,038h,000h,001h,006h,000h	; b86f  .......E...8....
	defb 007h,008h,000h,00ah,017h,080h,000h,050h,010h,000h,002h,003h,0ffh,002h,0feh,0cfh	; b87f  .......P........
	defb 0ech,000h,005h,017h,080h,000h,001h,008h,000h,001h,0beh,0bfh,000h,00dh,03fh,0ffh	; b88f  ..............?.
	defb 003h,0feh,000h,001h,001h,0e0h,03fh,080h,000h,002h,02fh,0c0h,000h,006h,010h,000h	; b89f  ......?.../.....
	defb 003h,041h,0c8h,000h,005h,0aah,0aah,0aah,0aah,0a8h,000h,003h,03fh,0b4h,0b7h,0b0h	; b8af  .A..........?...
	defb 004h,017h,080h,000h,00fh,00ah,0aah,0aah,0aah,0aah,080h,000h,004h,03fh,0fch,07fh	; b8bf  .............?..
	defb 080h,06ch,017h,080h,000h,009h,020h,000h,005h,0aah,0aah,0aah,0aah,000h,003h,010h	; b8cf  .l.... .........
	defb 000h,005h,008h,000h,001h,017h,080h,000h,002h,010h,000h,002h,041h,0c8h,000h,001h	; b8df  ............A...
	defb 007h,0f0h,000h,009h,008h,000h,004h,010h,000h,005h,017h,080h,000h,050h,038h,000h	; b8ef  .............P8.
	defb 002h,007h,0ffh,003h,01fh,0eeh,000h,001h,010h,000h,003h,017h,080h,000h,001h,01ch	; b8ff  ................
	defb 000h,001h,07bh,05eh,000h,00dh,07fh,0ffh,003h,0f8h,000h,002h,0f1h,0ffh,001h,0f0h	; b90f  ..{^............
	defb 000h,009h,008h,038h,000h,003h,004h,0c0h,000h,004h,005h,055h,055h,055h,055h,050h	; b91f  ...8.......UUUUP
	defb 000h,003h,07fh,0b3h,037h,0deh,00eh,017h,080h,000h,00fh,055h,055h,055h,055h,055h	; b92f  ....7......UUUUU
	defb 000h,005h,03fh,0e0h,00fh,080h,00ch,017h,080h,000h,008h,001h,0c0h,000h,005h,055h	; b93f  ..?............U
	defb 055h,055h,054h,000h,003h,038h,000h,005h,01ch,000h,001h,017h,080h,000h,002h,038h	; b94f  UUT..8.........8
	defb 000h,002h,004h,0c0h,000h,00ch,01ch,000h,004h,038h,000h,005h,017h,080h,000h,00bh	; b95f  .........8......
	defb 010h,000h,044h,010h,000h,002h,01fh,0ffh,003h,07eh,0eeh,000h,005h,017h,080h,000h	; b96f  ..D......~......
	defb 001h,07fh,000h,001h,05fh,0aeh,000h,006h,010h,000h,005h,001h,0ffh,004h,0f0h,000h	; b97f  ...._...........
	defb 002h,0f7h,0efh,0bch,000h,002h,017h,080h,000h,006h,010h,000h,004h,090h,000h,004h	; b98f  ................
	defb 00ah,0aah,0aah,0aah,0aah,080h,000h,003h,07fh,0cfh,0cfh,0dfh,06ch,017h,080h,000h	; b99f  ............l...
	defb 00ah,002h,000h,004h,0aah,0aah,0aah,0aah,0aah,000h,005h,01fh,09fh,09fh,000h,001h	; b9af  ................
	defb 018h,017h,080h,000h,006h,010h,000h,001h,002h,060h,000h,001h,003h,000h,003h,0aah	; b9bf  .........`......
	defb 0aah,0aah,0a8h,000h,003h,010h,000h,005h,07fh,000h,001h,017h,080h,000h,002h,010h	; b9cf  ................
	defb 000h,003h,090h,000h,00ch,07fh,000h,004h,010h,000h,005h,017h,080h,000h,005h,002h	; b9df  ................
	defb 000h,04dh,03fh,0ffh,002h,0feh,0fch,0eeh,000h,005h,017h,080h,000h,001h,01ch,000h	; b9ef  .M?.............
	defb 001h,03fh,0d4h,000h,005h,040h,000h,006h,003h,0ffh,004h,0e0h,000h,002h,06fh,0dfh	; b9ff  .?...@........o.
	defb 0deh,000h,002h,017h,080h,000h,00bh,008h,000h,004h,015h,055h,055h,055h,055h,000h	; ba0f  ...........UUUU.
	defb 004h,07fh,0ffh,002h,0deh,0e8h,017h,080h,000h,00fh,055h,055h,055h,055h,054h,000h	; ba1f  ..........UUUUT.
	defb 005h,01eh,07fh,0ffh,001h,000h,001h,01ch,017h,080h,000h,005h,040h,000h,002h,005h	; ba2f  ............@...
	defb 070h,000h,001h,081h,080h,000h,002h,055h,055h,055h,050h,000h,009h,01ch,000h,001h	; ba3f  p......UUUP.....
	defb 017h,080h,000h,006h,008h,000h,00ch,01ch,000h,00ah,017h,080h,000h,053h,0ffh,003h	; ba4f  .............S..
	defb 0feh,0f1h,0deh,080h,000h,007h,008h,000h,001h,01fh,0eah,000h,005h,001h,004h,000h	; ba5f  ................
	defb 005h,007h,0ffh,004h,0c0h,000h,002h,01fh,0ffh,002h,000h,002h,017h,080h,000h,00bh	; ba6f  ................
	defb 082h,000h,004h,02ah,0aah,0aah,0aah,0aah,000h,004h,07fh,0ffh,002h,0ceh,0deh,017h	; ba7f  ...*............
	defb 080h,000h,00fh,0aah,0aah,0aah,0aah,0a8h,000h,005h,00fh,0bfh,0feh,000h,001h,01ch	; ba8f  ................
	defb 017h,080h,000h,005h,001h,004h,000h,001h,016h,0f4h,000h,001h,0c0h,080h,000h,002h	; ba9f  ................
	defb 0aah,0aah,0aah,080h,000h,009h,008h,000h,001h,017h,080h,000h,006h,082h,000h,00ch	; baaf  ................
	defb 008h,000h,00ah,017h,080h,000h,052h,001h,0ffh,003h,0feh,0e3h,0bch,080h,000h,004h	; babf  ......R.........
	defb 02fh,0c0h,000h,001h,008h,000h,001h,007h,0e1h,000h,005h,008h,020h,000h,00dh,01fh	; bacf  /........... ...
	defb 0e7h,09fh,000h,002h,017h,080h,000h,005h,001h,000h,009h,001h,055h,055h,055h,055h	; badf  ............UUUU
	defb 054h,000h,004h,07fh,0ffh,002h,0c2h,0dfh,017h,080h,000h,00fh,055h,055h,055h,055h	; baef  T...........UUUU
	defb 050h,000h,005h,007h,0ffh,001h,0fch,000h,001h,01ch,017h,080h,000h,005h,008h,020h	; baff  P.............. 
	defb 000h,001h,013h,0e5h,034h,055h,000h,010h,008h,000h,001h,017h,080h,000h,013h,008h	; bb0f  ....4U..........
	defb 000h,00ah,017h,080h,000h,04fh	; bb1f

; ----------------------------------------------------------------------
; DATOS fuente: ASCII completo, mayusculas y minusculas, ocho bytes por
;   caracter. Es la hoja que el arranque deja en (0xA41E), el puntero que usa
;   la rutina de texto de 0x97D3; 0x9957 y 0x9973 lo cambian a 0x99B7 y lo
;   devuelven aqui
;   0xbb25..0xbe0e  (745 bytes)
DATA_fuente:
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bb25  ................
	defb 000h,000h,00ch,01ch,018h,010h,000h,018h,018h,000h,06ch,06ch,024h,000h,000h,000h	; bb35  ..........ll$...
	defb 000h,000h,024h,07eh,024h,024h,07eh,024h,000h,000h,008h,03eh,028h,03eh,00ah,03eh	; bb45  ..$~$$~$...>(>.>
	defb 008h,000h,062h,064h,008h,010h,026h,046h,000h,000h,010h,028h,010h,02ah,044h,03ah	; bb55  ..bd..&F...(.*D:
	defb 000h,000h,008h,010h,000h,000h,000h,000h,000h,000h,004h,00ch,018h,018h,018h,00ch	; bb65  ................
	defb 004h,000h,020h,030h,018h,018h,018h,030h,020h,000h,000h,014h,008h,03eh,008h,014h	; bb75  .. 0...0 ....>..
	defb 000h,000h,000h,008h,008h,03eh,008h,008h,000h,000h,000h,000h,000h,018h,018h,008h	; bb85  .....>..........
	defb 010h,000h,000h,000h,000h,03eh,000h,000h,000h,000h,000h,000h,000h,000h,000h,018h	; bb95  .....>..........
	defb 018h,000h,002h,006h,00ch,018h,030h,060h,000h,000h,01ch,036h,063h,06bh,063h,036h	; bba5  ......0`...6ckc6
	defb 01ch,000h,008h,018h,038h,018h,018h,01ah,03eh,000h,03ch,066h,00eh,03ch,070h,062h	; bbb5  ....8...>.<f.<pb
	defb 07eh,000h,03ch,066h,00ch,006h,006h,066h,03ch,000h,01ch,03ch,06ch,04ch,07eh,00ch	; bbc5  ~.<f...f<..<lL~.
	defb 00eh,000h,07eh,060h,07ch,006h,006h,066h,03ch,000h,03ch,066h,060h,07ch,066h,066h	; bbd5  ..~`|..f<.<f`|ff
	defb 03ch,000h,07eh,046h,006h,00ch,00ch,018h,018h,000h,03ch,066h,066h,03ch,066h,066h	; bbe5  <.~F......<ff<ff
	defb 03ch,000h,03ch,066h,066h,03eh,006h,066h,03ch,000h,000h,000h,018h,018h,000h,018h	; bbf5  <.<ff>.f<.......
	defb 018h,000h,000h,030h,000h,030h,030h,010h,020h,000h,004h,00ch,018h,030h,018h,00ch	; bc05  ...0.00. ....0..
	defb 004h,000h,000h,000h,03eh,000h,03eh,000h,000h,000h,010h,018h,00ch,006h,00ch,018h	; bc15  ....>.>.........
	defb 010h,000h,03ch,066h,006h,00ch,018h,000h,018h,000h,03ch,04ah,056h,05eh,040h,03ch	; bc25  ..<f......<JV^@<
	defb 000h,000h,018h,03ch,024h,066h,07eh,066h,066h,000h,07ch,066h,066h,07ch,066h,066h	; bc35  ...<$f~ff.|ff|ff
	defb 07ch,000h,03ch,066h,060h,060h,060h,066h,03ch,000h,078h,06ch,066h,066h,066h,06ch	; bc45  |.<f```f<.xlfffl
	defb 078h,000h,07eh,062h,060h,078h,060h,062h,07eh,000h,07eh,062h,060h,078h,060h,060h	; bc55  x.~b`x`b~.~b`x``
	defb 060h,000h,03ch,066h,060h,06eh,066h,066h,03ch,000h,066h,066h,066h,07eh,066h,066h	; bc65  `.<f`nff<.fff~ff
	defb 066h,000h,07eh,05ah,018h,018h,018h,05ah,07eh,000h,006h,006h,006h,066h,066h,066h	; bc75  f.~Z...Z~....fff
	defb 03ch,000h,066h,06ch,078h,070h,078h,06ch,066h,000h,060h,060h,060h,060h,060h,062h	; bc85  <.flxpxlf.`````b
	defb 07eh,000h,042h,066h,07eh,05ah,066h,066h,066h,000h,066h,066h,076h,07ah,05eh,06eh	; bc95  ~.Bf~Zfff.ffvz^n
	defb 066h,000h,03ch,066h,066h,066h,066h,066h,03ch,000h,07ch,066h,066h,066h,07ch,060h	; bca5  f.<fffff<.|fff|`
	defb 060h,000h,03ch,066h,066h,062h,06ch,066h,03ah,000h,07ch,066h,066h,064h,078h,06ch	; bcb5  `.<ffblf:.|ffdxl
	defb 066h,000h,03ch,066h,060h,03ch,006h,066h,03ch,000h,07eh,05ah,018h,018h,018h,018h	; bcc5  f.<f`<.f<.~Z....
	defb 018h,000h,066h,066h,066h,066h,066h,066h,03ch,000h,066h,066h,066h,066h,024h,03ch	; bcd5  ..ffffff<.ffff$<
	defb 018h,000h,066h,066h,066h,05ah,07eh,066h,042h,000h,066h,066h,034h,018h,02ch,066h	; bce5  ..fffZ~fB.ff4.,f
	defb 066h,000h,066h,066h,066h,03ch,018h,018h,018h,000h,07eh,046h,00ch,018h,030h,062h	; bcf5  f.fff<....~F..0b
	defb 07eh,000h,00eh,00ch,00ch,00ch,00ch,00ch,00eh,000h,040h,060h,030h,018h,00ch,006h	; bd05  ~.........@`0...
	defb 000h,000h,070h,030h,030h,030h,030h,030h,070h,010h,038h,07ch,054h,010h,010h,010h	; bd15  ..p00000p.8|T...
	defb 010h,000h,000h,000h,000h,000h,000h,000h,0ffh,000h,01ch,022h,078h,020h,020h,07eh	; bd25  ..........."x  ~
	defb 000h,000h,000h,03ch,006h,03eh,066h,066h,03eh,000h,060h,060h,07ch,066h,066h,066h	; bd35  ...<.>ff>.``|fff
	defb 07ch,000h,000h,03ch,066h,060h,060h,066h,03ch,000h,006h,006h,03eh,066h,066h,066h	; bd45  |..<f``f<...>fff
	defb 03eh,000h,000h,03ch,066h,07eh,060h,066h,03ch,000h,01ch,034h,030h,038h,030h,030h	; bd55  >..<f~`f<..40800
	defb 030h,000h,000h,03eh,066h,066h,03eh,006h,03ch,000h,060h,060h,07ch,066h,066h,066h	; bd65  0..>ff>.<.``|fff
	defb 066h,000h,018h,000h,038h,018h,018h,01ah,07eh,000h,006h,000h,006h,006h,006h,066h	; bd75  f...8...~......f
	defb 03ch,000h,060h,06ch,078h,070h,078h,06ch,066h,000h,030h,030h,030h,030h,030h,036h	; bd85  <.`lxpxlf.000006
	defb 01ch,000h,000h,076h,07fh,06bh,063h,063h,063h,000h,000h,06ch,07eh,066h,066h,066h	; bd95  ...v.kccc..l~fff
	defb 066h,000h,000h,03ch,066h,066h,066h,066h,03ch,000h,000h,07ch,066h,066h,07ch,060h	; bda5  f..<ffff<..|ff|`
	defb 060h,000h,000h,03eh,066h,066h,03eh,007h,002h,000h,000h,06ch,07eh,066h,060h,060h	; bdb5  `..>ff>....l~f``
	defb 060h,000h,000h,038h,060h,03ch,006h,066h,03ch,000h,030h,030h,038h,030h,030h,036h	; bdc5  `..8`<.f<.008006
	defb 01ch,000h,000h,066h,066h,066h,066h,066h,03ch,000h,000h,063h,063h,036h,036h,01ch	; bdd5  ...fffff<..cc66.
	defb 008h,000h,000h,063h,063h,063h,06bh,07fh,036h,000h,000h,066h,034h,018h,02ch,066h	; bde5  ...ccck.6..f4.,f
	defb 042h,000h,000h,066h,066h,066h,03eh,006h,01ch,000h,000h,07eh,04eh,01ch,038h,072h	; bdf5  B..fff>....~N.8r
	defb 07eh,000h,00eh,008h,030h,008h,008h,00eh,000h	; be05  ~...0....

; ----------------------------------------------------------------------
; DATOS patrones_de_sprite (tramo): 0x400 bytes a VRAM 0x3800; los vuelca el
;   arranque en 0x80FC. Cotejados contra la VRAM de openMSX: CERO bytes
;   distintos
;   0xbe0e..0xbece  (192 bytes)  de 0xbe0e..0xc20e (1024 bytes)
DATA_patrones_de_sprite:
	defb 007h,01fh,03fh,07fh,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,07fh,07fh,03fh,01fh,007h	; be0e  ..?..........?..
	defb 080h,0e0h,0f0h,0f8h,0f8h,0fch,0fch,0fch,0fch,0fch,0fch,0f8h,0f8h,0f0h,0e0h,080h	; be1e  ................
	defb 000h,007h,01fh,03fh,03fh,07fh,07fh,07fh,07fh,07fh,07fh,03fh,03fh,01fh,007h,000h	; be2e  ...??......??...
	defb 000h,080h,0e0h,0f0h,0f0h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f0h,0f0h,0e0h,080h,000h	; be3e  ................
	defb 000h,007h,01ch,038h,03ch,07fh,05fh,00fh,05fh,07ch,078h,038h,03ch,01fh,007h,000h	; be4e  ...8<._._|x8<...
	defb 000h,080h,0e0h,070h,0f0h,0f8h,0e8h,0c0h,0e8h,0f8h,078h,070h,0f0h,0e0h,080h,000h	; be5e  ...p......xp....
	defb 000h,000h,01ch,03fh,01fh,00fh,05fh,07ch,078h,078h,07ch,03fh,01fh,00fh,007h,000h	; be6e  ...?.._|xx|?....
	defb 000h,000h,0e0h,0f0h,0e0h,0c0h,0e8h,0f8h,078h,078h,0f8h,0f0h,0e0h,0c0h,080h,000h	; be7e  ........xx......
	defb 000h,007h,01fh,01fh,03fh,07ch,078h,078h,07ch,07fh,05fh,00fh,01fh,01fh,004h,000h	; be8e  ....?|xx|._.....
	defb 000h,080h,0e0h,0e0h,0f0h,0f8h,078h,078h,0f8h,0f8h,0e8h,0c0h,0e0h,0e0h,080h,000h	; be9e  ......xx........
	defb 000h,007h,01fh,03ch,038h,078h,07ch,07fh,05fh,00fh,05fh,03fh,03ch,018h,004h,000h	; beae  ...<8x|._._?<...
	defb 000h,080h,0e0h,0f0h,070h,078h,0f8h,0f8h,0e8h,0c0h,0e8h,0f0h,0f0h,060h,080h,000h	; bebe  ....px.......`..

; ======================================================================
; CODIGO 0xbece..0xbf52  (132 bytes)
; ======================================================================


lee_el_teclado:
	call lee_el_mando_o_las_teclas		;bece   ; las teclas
	or a			;bed1
	ret nz			;bed2
	ld a,026h		;bed3   ; la 'Q' (fila 4, bit 6): IZQUIERDA. Los cinco bits del mando salen de la tabla de 0xBF52 con el orden dado la vuelta, asi que de aqui en adelante bit 0 es derecha, bit 1 izquierda, bit 2 abajo y bit 3 arriba
	ld b,000h		;bed5
	ld c,002h		;bed7
	call mira_una_tecla		;bed9
	jr nz,L_BEE1		;bedc
	ld a,b			;bede
	or c			;bedf
	ld b,a			;bee0
L_BEE1:
	ld a,021h		;bee1   ; la 'L' (fila 4, bit 1): ABAJO
	ld c,004h		;bee3
	call mira_una_tecla		;bee5
	jr nz,L_BEED		;bee8
	ld a,b			;beea
	or c			;beeb
	ld b,a			;beec
L_BEED:
	ld a,02ch		;beed   ; la 'W' (fila 5, bit 4): DERECHA
	ld c,001h		;beef
	bit 1,b		;bef1   ; si la izquierda ya esta puesta, la derecha ni se mira
	jr nz,L_BEFD		;bef3
	call mira_una_tecla		;bef5
	jr nz,L_BEFD		;bef8
	ld a,b			;befa
	or c			;befb
	ld b,a			;befc
L_BEFD:
	ld a,025h		;befd   ; la 'P' (fila 4, bit 5): ARRIBA
	ld c,008h		;beff
	call mira_una_tecla		;bf01
	jr nz,L_BF09		;bf04
	ld a,b			;bf06
	or c			;bf07
	ld b,a			;bf08
L_BF09:
	ld c,b			;bf09
	ld a,040h		;bf0a   ; la barra espaciadora (fila 8, bit 0), o el disparo del mando: SALTAR. Las cinco son las que el rotulo que desfila anuncia: 'the keys are Q-Left, W-right, P-Up, L-Down and Space to jump'
	call mira_una_tecla		;bf0c
	ld a,000h		;bf0f
	jr nz,L_BF15		;bf11
	ld a,010h		;bf13
L_BF15:
	or c			;bf15
	ret			;bf16

; ----------------------------------------------------------------------
; LOS MANDOS
; ----------------------------------------------------------------------
lee_el_mando_o_las_teclas:
	ld a,00fh		;bf17   ; el registro 15 del PSG es el que elige la fila del teclado
	out (0a0h),a		;bf19
	in a,(0a2h)		;bf1b
	and 0afh		;bf1d   ; se prepara para leer el puerto 1
	or 003h		;bf1f
	out (0a1h),a		;bf21
	ld a,00eh		;bf23   ; y el 14 devuelve lo leido
	out (0a0h),a		;bf25
	in a,(0a2h)		;bf27
	cpl			;bf29   ; viene invertido
	and 01fh		;bf2a   ; cinco bits: las cuatro direcciones y el disparo
	jr nz,traduce_lo_leido		;bf2c   ; si hay algo, ya esta
	ld a,00fh		;bf2e   ; y si no, se prueba el otro puerto
	out (0a0h),a		;bf30
	in a,(0a2h)		;bf32
	and 0dfh		;bf34
	or 04ch		;bf36
	out (0a1h),a		;bf38
	ld a,00eh		;bf3a
	out (0a0h),a		;bf3c
	in a,(0a2h)		;bf3e
	cpl			;bf40
	and 01fh		;bf41
traduce_lo_leido:
	ld c,a			;bf43   ; lo leido
	and 00fh		;bf44   ; el nibble bajo indexa la tabla de traduccion de 0xBF52
	ld l,a			;bf46
	ld h,000h		;bf47
	ld de,0bf52h		;bf49
	add hl,de			;bf4c
	ld a,c			;bf4d
	and 010h		;bf4e   ; y el bit 4 es el disparo
	or (hl)			;bf50
	ret			;bf51

; ----------------------------------------------------------------------
; DATOS patrones_de_sprite (tramo): 0x400 bytes a VRAM 0x3800; los vuelca el
;   arranque en 0x80FC. Cotejados contra la VRAM de openMSX: CERO bytes
;   distintos
;   0xbf52..0xbf62  (16 bytes)  de 0xbe0e..0xc20e (1024 bytes)
DATA_patrones_de_sprite_BF52:
	defb 000h,008h,004h,00ch,002h,00ah,006h,00eh,001h,009h,005h,00dh,003h,00bh,007h,00fh	; bf52  ................

; ======================================================================
; CODIGO 0xbf62..0xbf88  (38 bytes)
; ======================================================================


mira_una_tecla:
	push bc			;bf62   ; la tecla que se pide
	ld c,0aah		;bf63   ; el puerto 0xAA es el que elige la fila del teclado
	ld l,a			;bf65
	in h,(c)		;bf66   ; lo que hay puesto ahora
	and 078h		;bf68   ; se selecciona su fila
	rrca			;bf6a   ; los bits 3 a 6 del codigo de tecla son la FILA, bajados a los cuatro de abajo
	rrca			;bf6b
	rrca			;bf6c
	push af			;bf6d
	ld a,h			;bf6e
	and 0f0h		;bf6f   ; del valor de ahora se respeta el nibble alto
	ld h,a			;bf71
	pop af			;bf72
	or h			;bf73
	out (c),a		;bf74   ; y se pide esa fila
	ld a,l			;bf76
	and 007h		;bf77   ; los tres bits bajos son EL BIT dentro de la fila
	rlca			;bf79   ; subidos al hueco del `bit n,a`
	rlca			;bf7a
	rlca			;bf7b
	or 047h		;bf7c   ; con el 0x47 que lo convierte en `bit 0,a`
	ld (0bf85h),a		;bf7e   ; Y ESCRITO DENTRO DE LA INSTRUCCION DE 0xBF84: el opcode de `bit n,a` se fabrica al vuelo, y asi una sola rutina mira cualquiera de las 80 teclas sin tabla ni bucle
	dec c			;bf81
	in a,(c)		;bf82   ; la fila leida
	bit 0,a		;bf84   ; y aqui esta el `bit` recien fabricado
	pop bc			;bf86
	ret			;bf87

; ----------------------------------------------------------------------
; DATOS patrones_de_sprite (tramo): 0x400 bytes a VRAM 0x3800; los vuelca el
;   arranque en 0x80FC. Cotejados contra la VRAM de openMSX: CERO bytes
;   distintos
;   0xbf88..0xc20e  (646 bytes)  de 0xbe0e..0xc20e (1024 bytes)
DATA_patrones_de_sprite_BF88:
	defb 000h,000h,000h,07fh,0ffh,0ffh,0c0h,000h,000h,003h,0ffh,0ffh,0feh,000h,000h,000h	; bf88  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bf98  ................
	defb 000h,000h,07fh,0ffh,0ffh,0feh,000h,000h,000h,000h,07fh,0ffh,0ffh,0feh,000h,000h	; bfa8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bfb8  ................
	defb 000h,07fh,0ffh,0ffh,0ffh,0f8h,000h,000h,000h,000h,01fh,0ffh,0ffh,0ffh,0feh,000h	; bfc8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bfd8  ................
	defb 07fh,0ffh,0ffh,0ffh,0ffh,0c0h,000h,000h,000h,000h,003h,0ffh,0ffh,0ffh,0ffh,0feh	; bfe8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; bff8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c008  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c018  ................
	defb 000h,000h,000h,000h,000h,003h,0ffh,00fh,0f0h,0ffh,0c0h,000h,000h,000h,000h,000h	; c028  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c038  ................
	defb 000h,000h,000h,003h,0ffh,0ffh,000h,03fh,0fch,000h,0ffh,0ffh,0c0h,000h,000h,000h	; c048  .......?........
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c058  ................
	defb 000h,003h,0ffh,0ffh,0ffh,000h,001h,0ffh,0ffh,080h,000h,0ffh,0ffh,0ffh,0c0h,000h	; c068  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,003h	; c078  ................
	defb 0ffh,0ffh,0ffh,0ffh,000h,000h,00fh,0ffh,0ffh,0f0h,000h,000h,0ffh,0ffh,0ffh,0ffh	; c088  ................
	defb 0c0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,003h,0ffh,0ffh	; c098  ................
	defb 0ffh,0ffh,0ffh,000h,000h,000h,03fh,0ffh,0ffh,0fch,000h,000h,000h,0ffh,0ffh,0ffh	; c0a8  ......?.........
	defb 0ffh,0ffh,0c0h,000h,000h,000h,000h,000h,000h,000h,000h,003h,0ffh,0ffh,0ffh,0ffh	; c0b8  ................
	defb 0ffh,0ffh,000h,000h,000h,001h,0ffh,0ffh,0ffh,0ffh,080h,000h,000h,000h,0ffh,0ffh	; c0c8  ................
	defb 0ffh,0ffh,0ffh,0ffh,0c0h,000h,000h,000h,000h,003h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; c0d8  ................
	defb 0ffh,000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,0f0h,000h,000h,000h,000h,0ffh	; c0e8  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0c0h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c0f8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c108  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c118  ................
	defb 000h,000h,000h,000h,000h,000h,000h,0f0h,00fh,000h,000h,000h,000h,000h,000h,000h	; c128  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c138  ................
	defb 000h,000h,000h,000h,000h,000h,0ffh,0c0h,003h,0ffh,000h,000h,000h,000h,000h,000h	; c148  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c158  ................
	defb 000h,000h,000h,000h,000h,0ffh,0feh,000h,000h,07fh,0ffh,000h,000h,000h,000h,000h	; c168  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c178  ................
	defb 000h,000h,000h,000h,0ffh,0ffh,0f0h,000h,000h,00fh,0ffh,0ffh,000h,000h,000h,000h	; c188  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c198  ................
	defb 000h,000h,000h,0ffh,0ffh,0ffh,0c0h,000h,000h,003h,0ffh,0ffh,0ffh,000h,000h,000h	; c1a8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c1b8  ................
	defb 000h,000h,0ffh,0ffh,0ffh,0feh,000h,000h,000h,000h,07fh,0ffh,0ffh,0ffh,000h,000h	; c1c8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c1d8  ................
	defb 000h,0ffh,0ffh,0ffh,0ffh,0f0h,000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,000h	; c1e8  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c1f8  ................
	defb 000h,000h,000h,000h,000h,000h	; c208

; ----------------------------------------------------------------------
; DATOS tabla_de_la_perspectiva: 3570 bytes leidos con la direccion calculada,
;   no escrita: 0x8C14 fabrica el byte alto (0xC0 mas el doble de los tres
;   bits bajos de e) y el bucle baja con `dec l` mientras el byte sea 0xFF.
;   Los siete sitios que la leen estan medidos con un punto de vigilancia del
;   emulador
;   0xc20e..0xd000  (3570 bytes)
DATA_tabla_de_la_perspectiva:
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c20e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00fh	; c21e  ................
	defb 0feh,00fh,0f0h,07fh,0f0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c22e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00fh,0ffh,0feh	; c23e  ................
	defb 000h,07fh,0feh,000h,07fh,0ffh,0f0h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c24e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00fh,0ffh,0ffh,0feh,000h	; c25e  ................
	defb 001h,0ffh,0ffh,080h,000h,07fh,0ffh,0ffh,0f0h,000h,000h,000h,000h,000h,000h,000h	; c26e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0feh,000h,000h	; c27e  ................
	defb 00fh,0ffh,0ffh,0f0h,000h,000h,07fh,0ffh,0ffh,0ffh,0f0h,000h,000h,000h,000h,000h	; c28e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,0feh,000h,000h,000h	; c29e  ................
	defb 07fh,0ffh,0ffh,0feh,000h,000h,000h,07fh,0ffh,0ffh,0ffh,0ffh,0f0h,000h,000h,000h	; c2ae  ................
	defb 000h,000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,000h,000h,000h,001h	; c2be  ................
	defb 0ffh,0ffh,0ffh,0ffh,080h,000h,000h,000h,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0f0h,000h	; c2ce  ................
	defb 000h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,000h,000h,000h,000h,00fh	; c2de  ................
	defb 0ffh,0ffh,0ffh,0ffh,0f0h,000h,000h,000h,000h,07fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; c2ee  ................
	defb 0f0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c2fe  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c30e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c31e  ................
	defb 001h,0f0h,00fh,080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c32e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h	; c33e  ................
	defb 0ffh,080h,001h,0ffh,080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c34e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,0ffh	; c35e  ................
	defb 0feh,000h,000h,07fh,0ffh,080h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c36e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,0ffh,0ffh	; c37e  ................
	defb 0f0h,000h,000h,00fh,0ffh,0ffh,080h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c38e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,0ffh,0ffh,0ffh	; c39e  ................
	defb 080h,000h,000h,001h,0ffh,0ffh,0ffh,080h,000h,000h,000h,000h,000h,000h,000h,000h	; c3ae  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,0ffh,0ffh,0ffh,0feh	; c3be  ................
	defb 000h,000h,000h,000h,07fh,0ffh,0ffh,0ffh,080h,000h,000h,000h,000h,000h,000h,000h	; c3ce  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,0ffh,0ffh,0ffh,0ffh,0f0h	; c3de  ................
	defb 000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,080h,000h,000h,000h,000h,000h,000h	; c3ee  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c3fe  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c40e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03fh	; c41e  ...............?
	defb 0fch,00fh,0f0h,03fh,0fch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c42e  ...?............
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03fh,0ffh,0fch	; c43e  .............?..
	defb 000h,07fh,0feh,000h,03fh,0ffh,0fch,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c44e  ....?...........
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03fh,0ffh,0ffh,0fch,000h	; c45e  ...........?....
	defb 003h,0ffh,0ffh,0c0h,000h,03fh,0ffh,0ffh,0fch,000h,000h,000h,000h,000h,000h,000h	; c46e  .....?..........
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0fch,000h,000h	; c47e  .........?......
	defb 00fh,0ffh,0ffh,0f0h,000h,000h,03fh,0ffh,0ffh,0ffh,0fch,000h,000h,000h,000h,000h	; c48e  ......?.........
	defb 000h,000h,000h,000h,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0ffh,0fch,000h,000h,000h	; c49e  .......?........
	defb 07fh,0ffh,0ffh,0feh,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0ffh,0fch,000h,000h,000h	; c4ae  .......?........
	defb 000h,000h,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0ffh,0ffh,0fch,000h,000h,000h,003h	; c4be  .....?..........
	defb 0ffh,0ffh,0ffh,0ffh,0c0h,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0ffh,0ffh,0fch,000h	; c4ce  ........?.......
	defb 000h,000h,000h,03fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fch,000h,000h,000h,000h,00fh	; c4de  ...?............
	defb 0ffh,0ffh,0ffh,0ffh,0f0h,000h,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; c4ee  .........?......
	defb 0fch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c4fe  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c50e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c51e  ................
	defb 003h,0f0h,00fh,0c0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c52e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,003h	; c53e  ................
	defb 0ffh,080h,001h,0ffh,0c0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c54e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,003h,0ffh	; c55e  ................
	defb 0fch,000h,000h,03fh,0ffh,0c0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c56e  ...?............
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,003h,0ffh,0ffh	; c57e  ................
	defb 0f0h,000h,000h,00fh,0ffh,0ffh,0c0h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c58e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,003h,0ffh,0ffh,0ffh	; c59e  ................
	defb 080h,000h,000h,001h,0ffh,0ffh,0ffh,0c0h,000h,000h,000h,000h,000h,000h,000h,000h	; c5ae  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,003h,0ffh,0ffh,0ffh,0fch	; c5be  ................
	defb 000h,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0c0h,000h,000h,000h,000h,000h,000h,000h	; c5ce  ....?...........
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,003h,0ffh,0ffh,0ffh,0ffh,0f0h	; c5de  ................
	defb 000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,0c0h,000h,000h,000h,000h,000h,000h	; c5ee  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c5fe  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c60e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh	; c61e  ................
	defb 0f8h,01fh,0f8h,01fh,0ffh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c62e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,0f8h	; c63e  ................
	defb 000h,07fh,0feh,000h,01fh,0ffh,0ffh,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c64e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,0ffh,0f8h,000h	; c65e  ................
	defb 003h,0ffh,0ffh,0c0h,000h,01fh,0ffh,0ffh,0ffh,000h,000h,000h,000h,000h,000h,000h	; c66e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0f8h,000h,000h	; c67e  ................
	defb 01fh,0ffh,0ffh,0f8h,000h,000h,01fh,0ffh,0ffh,0ffh,0ffh,000h,000h,000h,000h,000h	; c68e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0f8h,000h,000h,000h	; c69e  ................
	defb 07fh,0ffh,0ffh,0feh,000h,000h,000h,01fh,0ffh,0ffh,0ffh,0ffh,0ffh,000h,000h,000h	; c6ae  ................
	defb 000h,000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f8h,000h,000h,000h,003h	; c6be  ................
	defb 0ffh,0ffh,0ffh,0ffh,0c0h,000h,000h,000h,01fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,000h	; c6ce  ................
	defb 000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f8h,000h,000h,000h,000h,01fh	; c6de  ................
	defb 0ffh,0ffh,0ffh,0ffh,0f8h,000h,000h,000h,000h,01fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; c6ee  ................
	defb 0ffh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c6fe  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c70e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c71e  ................
	defb 007h,0e0h,007h,0e0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c72e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,007h	; c73e  ................
	defb 0ffh,080h,001h,0ffh,0e0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c74e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,007h,0ffh	; c75e  ................
	defb 0fch,000h,000h,03fh,0ffh,0e0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c76e  ...?............
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,007h,0ffh,0ffh	; c77e  ................
	defb 0e0h,000h,000h,007h,0ffh,0ffh,0e0h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c78e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,007h,0ffh,0ffh,0ffh	; c79e  ................
	defb 080h,000h,000h,001h,0ffh,0ffh,0ffh,0e0h,000h,000h,000h,000h,000h,000h,000h,000h	; c7ae  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,007h,0ffh,0ffh,0ffh,0fch	; c7be  ................
	defb 000h,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0e0h,000h,000h,000h,000h,000h,000h,000h	; c7ce  ....?...........
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,007h,0ffh,0ffh,0ffh,0ffh,0e0h	; c7de  ................
	defb 000h,000h,000h,000h,007h,0ffh,0ffh,0ffh,0ffh,0e0h,000h,000h,000h,000h,000h,000h	; c7ee  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c7fe  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c80e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,003h,0ffh	; c81e  ................
	defb 0f0h,01fh,0f8h,00fh,0ffh,0c0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c82e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,003h,0ffh,0ffh,0f0h	; c83e  ................
	defb 000h,0ffh,0ffh,000h,00fh,0ffh,0ffh,0c0h,000h,000h,000h,000h,000h,000h,000h,000h	; c84e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,003h,0ffh,0ffh,0ffh,0f0h,000h	; c85e  ................
	defb 003h,0ffh,0ffh,0c0h,000h,00fh,0ffh,0ffh,0ffh,0c0h,000h,000h,000h,000h,000h,000h	; c86e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,003h,0ffh,0ffh,0ffh,0ffh,0f0h,000h,000h	; c87e  ................
	defb 01fh,0ffh,0ffh,0f8h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,0c0h,000h,000h,000h,000h	; c88e  ................
	defb 000h,000h,000h,000h,000h,000h,003h,0ffh,0ffh,0ffh,0ffh,0ffh,0f0h,000h,000h,000h	; c89e  ................
	defb 0ffh,0ffh,0ffh,0ffh,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,0ffh,0c0h,000h,000h	; c8ae  ................
	defb 000h,000h,000h,000h,003h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f0h,000h,000h,000h,003h	; c8be  ................
	defb 0ffh,0ffh,0ffh,0ffh,0c0h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0c0h	; c8ce  ................
	defb 000h,000h,003h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f0h,000h,000h,000h,000h,01fh	; c8de  ................
	defb 0ffh,0ffh,0ffh,0ffh,0f8h,000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; c8ee  ................
	defb 0ffh,0c0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c8fe  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c90e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c91e  ................
	defb 00fh,0e0h,007h,0f0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c92e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00fh	; c93e  ................
	defb 0ffh,000h,000h,0ffh,0f0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c94e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00fh,0ffh	; c95e  ................
	defb 0fch,000h,000h,03fh,0ffh,0f0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c96e  ...?............
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00fh,0ffh,0ffh	; c97e  ................
	defb 0e0h,000h,000h,007h,0ffh,0ffh,0f0h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c98e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh	; c99e  ................
	defb 000h,000h,000h,000h,0ffh,0ffh,0ffh,0f0h,000h,000h,000h,000h,000h,000h,000h,000h	; c9ae  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0fch	; c9be  ................
	defb 000h,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0f0h,000h,000h,000h,000h,000h,000h,000h	; c9ce  ....?...........
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,0e0h	; c9de  ................
	defb 000h,000h,000h,000h,007h,0ffh,0ffh,0ffh,0ffh,0f0h,000h,000h,000h,000h,000h,000h	; c9ee  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c9fe  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ca0e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00fh,0ffh	; ca1e  ................
	defb 0e0h,01fh,0f8h,007h,0ffh,0f0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ca2e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00fh,0ffh,0ffh,0e0h	; ca3e  ................
	defb 000h,0ffh,0ffh,000h,007h,0ffh,0ffh,0f0h,000h,000h,000h,000h,000h,000h,000h,000h	; ca4e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0e0h,000h	; ca5e  ................
	defb 007h,0ffh,0ffh,0e0h,000h,007h,0ffh,0ffh,0ffh,0f0h,000h,000h,000h,000h,000h,000h	; ca6e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,0e0h,000h,000h	; ca7e  ................
	defb 01fh,0ffh,0ffh,0f8h,000h,000h,007h,0ffh,0ffh,0ffh,0ffh,0f0h,000h,000h,000h,000h	; ca8e  ................
	defb 000h,000h,000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,0ffh,0e0h,000h,000h,000h	; ca9e  ................
	defb 0ffh,0ffh,0ffh,0ffh,000h,000h,000h,007h,0ffh,0ffh,0ffh,0ffh,0ffh,0f0h,000h,000h	; caae  ................
	defb 000h,000h,000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0e0h,000h,000h,000h,007h	; cabe  ................
	defb 0ffh,0ffh,0ffh,0ffh,0e0h,000h,000h,000h,007h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f0h	; cace  ................
	defb 000h,000h,00fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0e0h,000h,000h,000h,000h,01fh	; cade  ................
	defb 0ffh,0ffh,0ffh,0ffh,0f8h,000h,000h,000h,000h,007h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; caee  ................
	defb 0ffh,0f0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cafe  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cb0e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cb1e  ................
	defb 01fh,0e0h,007h,0f8h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cb2e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01fh	; cb3e  ................
	defb 0ffh,000h,000h,0ffh,0f8h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cb4e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01fh,0ffh	; cb5e  ................
	defb 0f8h,000h,000h,01fh,0ffh,0f8h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cb6e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01fh,0ffh,0ffh	; cb7e  ................
	defb 0e0h,000h,000h,007h,0ffh,0ffh,0f8h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cb8e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01fh,0ffh,0ffh,0ffh	; cb9e  ................
	defb 000h,000h,000h,000h,0ffh,0ffh,0ffh,0f8h,000h,000h,000h,000h,000h,000h,000h,000h	; cbae  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01fh,0ffh,0ffh,0ffh,0f8h	; cbbe  ................
	defb 000h,000h,000h,000h,01fh,0ffh,0ffh,0ffh,0f8h,000h,000h,000h,000h,000h,000h,000h	; cbce  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,01fh,0ffh,0ffh,0ffh,0ffh,0e0h	; cbde  ................
	defb 000h,000h,000h,000h,007h,0ffh,0ffh,0ffh,0ffh,0f8h,000h,000h,000h,000h,000h,000h	; cbee  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cbfe  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cc0e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03fh,0ffh	; cc1e  ..............?.
	defb 0c0h,03fh,0fch,003h,0ffh,0fch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cc2e  .?..............
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03fh,0ffh,0ffh,0c0h	; cc3e  ............?...
	defb 000h,0ffh,0ffh,000h,003h,0ffh,0ffh,0fch,000h,000h,000h,000h,000h,000h,000h,000h	; cc4e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0c0h,000h	; cc5e  ..........?.....
	defb 007h,0ffh,0ffh,0e0h,000h,003h,0ffh,0ffh,0ffh,0fch,000h,000h,000h,000h,000h,000h	; cc6e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0ffh,0c0h,000h,000h	; cc7e  ........?.......
	defb 03fh,0ffh,0ffh,0fch,000h,000h,003h,0ffh,0ffh,0ffh,0ffh,0fch,000h,000h,000h,000h	; cc8e  ?...............
	defb 000h,000h,000h,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0ffh,0ffh,0c0h,000h,000h,000h	; cc9e  ......?.........
	defb 0ffh,0ffh,0ffh,0ffh,000h,000h,000h,003h,0ffh,0ffh,0ffh,0ffh,0ffh,0fch,000h,000h	; ccae  ................
	defb 000h,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0c0h,000h,000h,000h,007h	; ccbe  ....?...........
	defb 0ffh,0ffh,0ffh,0ffh,0e0h,000h,000h,000h,003h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fch	; ccce  ................
	defb 000h,000h,03fh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0c0h,000h,000h,000h,000h,03fh	; ccde  ..?............?
	defb 0ffh,0ffh,0ffh,0ffh,0fch,000h,000h,000h,000h,003h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ccee  ................
	defb 0ffh,0fch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ccfe  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cd0e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cd1e  ................
	defb 03fh,0c0h,003h,0fch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cd2e  ?...............
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03fh	; cd3e  ...............?
	defb 0ffh,000h,000h,0ffh,0fch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cd4e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03fh,0ffh	; cd5e  ..............?.
	defb 0f8h,000h,000h,01fh,0ffh,0fch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cd6e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03fh,0ffh,0ffh	; cd7e  .............?..
	defb 0c0h,000h,000h,003h,0ffh,0ffh,0fch,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cd8e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03fh,0ffh,0ffh,0ffh	; cd9e  ............?...
	defb 000h,000h,000h,000h,0ffh,0ffh,0ffh,0fch,000h,000h,000h,000h,000h,000h,000h,000h	; cdae  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0f8h	; cdbe  ...........?....
	defb 000h,000h,000h,000h,01fh,0ffh,0ffh,0ffh,0fch,000h,000h,000h,000h,000h,000h,000h	; cdce  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03fh,0ffh,0ffh,0ffh,0ffh,0c0h	; cdde  ..........?.....
	defb 000h,000h,000h,000h,003h,0ffh,0ffh,0ffh,0ffh,0fch,000h,000h,000h,000h,000h,000h	; cdee  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cdfe  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ce0e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh	; ce1e  ................
	defb 080h,03fh,0fch,001h,0ffh,0ffh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ce2e  .?..............
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,0ffh,080h	; ce3e  ................
	defb 001h,0ffh,0ffh,080h,001h,0ffh,0ffh,0ffh,000h,000h,000h,000h,000h,000h,000h,000h	; ce4e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh,080h,000h	; ce5e  ................
	defb 007h,0ffh,0ffh,0e0h,000h,001h,0ffh,0ffh,0ffh,0ffh,000h,000h,000h,000h,000h,000h	; ce6e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,080h,000h,000h	; ce7e  ................
	defb 03fh,0ffh,0ffh,0fch,000h,000h,001h,0ffh,0ffh,0ffh,0ffh,0ffh,000h,000h,000h,000h	; ce8e  ?...............
	defb 000h,000h,000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,080h,000h,000h,001h	; ce9e  ................
	defb 0ffh,0ffh,0ffh,0ffh,080h,000h,000h,001h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,000h,000h	; ceae  ................
	defb 000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,080h,000h,000h,000h,007h	; cebe  ................
	defb 0ffh,0ffh,0ffh,0ffh,0e0h,000h,000h,000h,001h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; cece  ................
	defb 000h,000h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,080h,000h,000h,000h,000h,03fh	; cede  ...............?
	defb 0ffh,0ffh,0ffh,0ffh,0fch,000h,000h,000h,000h,001h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ceee  ................
	defb 0ffh,0ffh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cefe  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cf0e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cf1e  ................
	defb 07fh,0c0h,003h,0feh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cf2e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,07fh	; cf3e  ................
	defb 0feh,000h,000h,07fh,0feh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cf4e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,07fh,0ffh	; cf5e  ................
	defb 0f8h,000h,000h,01fh,0ffh,0feh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cf6e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,07fh,0ffh,0ffh	; cf7e  ................
	defb 0c0h,000h,000h,003h,0ffh,0ffh,0feh,000h,000h,000h,000h,000h,000h,000h,000h,000h	; cf8e  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,07fh,0ffh,0ffh,0feh	; cf9e  ................
	defb 000h,000h,000h,000h,07fh,0ffh,0ffh,0feh,000h,000h,000h,000h,000h,000h,000h,000h	; cfae  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,07fh,0ffh,0ffh,0ffh,0f8h	; cfbe  ................
	defb 000h,000h,000h,000h,01fh,0ffh,0ffh,0ffh,0feh,000h,000h,000h,000h,000h,000h,000h	; cfce  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,07fh,0ffh,0ffh,0ffh,0ffh,0c0h	; cfde  ................
	defb 000h,000h,000h,000h,003h,0ffh,0ffh,0ffh,0ffh,0feh,000h,000h,000h,000h,000h,000h	; cfee  ................
	defb 000h,000h	; cffe

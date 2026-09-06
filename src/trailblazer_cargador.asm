; ==========================================================================
; TRAILBLAZER - Gremlin Graphics 1986 - MSX1 - el turbo loader de cinta
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x0d800


; ======================================================================
; CODIGO 0xd800..0xd8ed  (237 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL CARGADOR: lo unico que el BIOS mete en memoria
; ----------------------------------------------------------------------
arranca:
	ld a,002h		;d800   ; modo 2, o sea SCREEN 2
	call 0005fh		;d802   ; BIOS CHGMOD - Switches to given screen mode
carga_la_pieza_siguiente:
	di			;d805   ; y a partir de aqui, sin interrupciones: el BIOS de cinta las quiere quitadas
	ld ix,0d8edh		;d806   ; la cabecerita se lee a este bufer
	ld de,00004h		;d80a   ; cuatro bytes: direccion de carga y longitud
	ld a,0feh		;d80d   ; 0xFE es el byte de sincronismo que la abre
	scf			;d80f   ; el acarreo puesto dice "esto es una cabecera"
	call lee_de_la_cinta		;d810
	jr nc,carga_la_pieza_siguiente		;d813   ; si algo fallo, se vuelve a empezar por la misma
	ld ix,(0d8edh)		;d815   ; la direccion de carga que acaba de leer
	ld de,(0d8efh)		;d819   ; y cuantos bytes vienen
	ld a,0ffh		;d81d   ; el cuerpo se abre con 0xFF, no con 0xFE
	scf			;d81f
	call lee_de_la_cinta		;d820
	jr nc,carga_la_pieza_siguiente		;d823
	ld hl,(0d8edh)		;d825   ; y al acabar, a la direccion de carga
	call salta_a_lo_cargado		;d828   ; el `jp (hl)` de ahi al lado
	ld hl,04000h		;d82b   ; y si la pieza vuelve, se espera un rato largo
L_D82E:
	dec hl			;d82e   ; 0x4000 vueltas de nada
	ld a,h			;d82f
	or l			;d830
	jr nz,L_D82E		;d831
	jp carga_la_pieza_siguiente		;d833   ; antes de intentar la siguiente
salta_a_lo_cargado:
	jp (hl)			;d836   ; el salto a la pieza recien cargada: la unica salida del cargador que no vuelve

; ----------------------------------------------------------------------
; LA LECTURA DE CINTA, Y EL PUENTE QUE SE MONTA EN LA PILA
; ----------------------------------------------------------------------
lee_de_la_cinta:
	di			;d837   ; otra vez, que se entra por aqui desde los dos sitios
	ex af,af'			;d838   ; se guardan los dos juegos de registros enteros
	exx			;d839
	push bc			;d83a
	push de			;d83b
	push hl			;d83c
	ld hl,0fca6h		;d83d   ; LO QUE HAY EN 0xFC8A..0xFCA5 SE APARTA A LA PILA: son variables del BIOS y hay que devolverlas
	ld b,00ch		;d840   ; doce words
L_D842:
	dec hl			;d842
	ld d,(hl)			;d843
	dec hl			;d844
	ld e,(hl)			;d845
	push de			;d846
	djnz L_D842		;d847
	ld a,h			;d849   ; h vale 0xFC, que es la pagina donde va a vivir el puente
	ld h,b			;d84a
	ld l,b			;d84b
	add hl,sp			;d84c   ; hl se queda con el SP de ahora, para poder volver
	ld sp,0fca4h		;d84d   ; y la pila baja hasta 0xFCA4
	ld de,0c961h		;d850   ; AQUI EMPIEZA EL TRUCO: los cinco `push` siguientes no meten datos, meten CODIGO. De abajo arriba sale esto en 0xFC9A: `out (c),l / exx / call 000e1h / exx / out (c),h / ret`
	push de			;d853
	ld de,0edd9h		;d854
	push de			;d857
	ld de,000e1h		;d858   ; y este es el `call 000E1h`, que es TAPION del BIOS
	push de			;d85b
	ld de,0cdd9h		;d85c
	push de			;d85f
	ld de,069edh		;d860
	push de			;d863
	push hl			;d864   ; el SP viejo, para recuperarlo al final
	exx			;d865
	ld c,0a8h		;d866   ; c queda con el puerto de las ranuras
	in h,(c)		;d868   ; h con lo que hay puesto ahora
	and h			;d86a   ; y l con la configuracion que deja ver la ROM del BIOS
	ld l,a			;d86b
	call 0fc9ah		;d86c   ; BIOS RTYCNT - Interrupt control. | a la pila. Y ahi esta la gracia: el puente CONMUTA LA RANURA, llama al BIOS y la devuelve. Vive en 0xFC9A porque la pagina 3 es RAM con las dos configuraciones
	jr c,remata_la_lectura		;d86f   ; si TAPION no encontro el tono, se remata
	ld a,0e4h		;d871   ; y AQUI SE REESCRIBE EL PUENTE: 0xE4 en el operando del `call` lo convierte en TAPIN, o sea leer un byte
	ld (0fc9eh),a		;d873
	call 0fc9ah		;d876   ; BIOS RTYCNT - Interrupt control. | el primero
	jr c,remata_la_lectura		;d879
	ld b,a			;d87b   ; se guarda
	ex af,af'			;d87c   ; el byte que se esperaba
	cp b			;d87d   ; si no es ese, esto no es lo que tocaba
	scf			;d87e
	jr nz,remata_la_lectura		;d87f
	jr lee_un_byte_mas		;d881   ; y si lo es, a leer el cuerpo
guarda_el_byte:
	pop af			;d883   ; el byte que acaba de llegar
	push ix		;d884   ; la direccion donde va
	exx			;d886
	pop bc			;d887
	ld hl,00372h		;d888   ; EL FILTRO: solo se escribe si el destino esta por debajo de 0xFC8E, o sea si no pisa la zona del BIOS ni el propio puente
	add hl,bc			;d88b
	jr nc,L_D89A		;d88c
	ex de,hl			;d88e
	ld hl,0ffe8h		;d88f   ; ni por encima de 0x0018
	add hl,de			;d892
	jr c,L_D89A		;d893
	pop hl			;d895
	push hl			;d896
	add hl,de			;d897   ; la direccion buena
	ld (hl),a			;d898   ; y el byte a su sitio
	ld a,(bc)			;d899
L_D89A:
	ld (bc),a			;d89a
	exx			;d89b   ; el byte siguiente
	inc ix		;d89c   ; un byte menos
	dec de			;d89e
lee_un_byte_mas:
	call 0fc9ah		;d89f   ; BIOS RTYCNT - Interrupt control. | otra llamada al puente, ya convertido en TAPIN
	jr c,remata_la_lectura		;d8a2
	push af			;d8a4
	xor b			;d8a5   ; la suma de control se va llevando en b
	ld b,a			;d8a6
	ld a,e			;d8a7   ; y el byte bajo de lo que queda...
	out (099h),a		;d8a8   ; ...sale por el REGISTRO 7 del VDP: la barra de color del borde es lo que queda por cargar
	or d			;d8aa
	ld a,087h		;d8ab
	out (099h),a		;d8ad
	jr nz,guarda_el_byte		;d8af   ; mientras queden bytes
	pop af			;d8b1
remata_la_lectura:
	sbc a,a			;d8b2   ; el acarreo, que dice si hubo error
	or b			;d8b3
	ex af,af'			;d8b4
	ld a,0f3h		;d8b5   ; y el puente se reescribe una vez mas: 0xF3 es STMOTR
	ld (0fc9eh),a		;d8b7
	xor a			;d8ba   ; con a a cero
	call 0fc9ah		;d8bb   ; BIOS RTYCNT - Interrupt control. | o sea PARAR EL MOTOR
	exx			;d8be
	pop hl			;d8bf   ; el SP de antes
	ld sp,hl			;d8c0
	ld hl,0fc8eh		;d8c1   ; y las doce words del BIOS, de vuelta a su sitio
	ld b,00ch		;d8c4
L_D8C6:
	pop de			;d8c6
	ld (hl),e			;d8c7
	inc hl			;d8c8
	ld (hl),d			;d8c9
	inc hl			;d8ca
	djnz L_D8C6		;d8cb
	pop hl			;d8cd   ; los registros
	pop de			;d8ce
	pop bc			;d8cf
	exx			;d8d0
	ex af,af'			;d8d1
	cp 001h		;d8d2   ; y el acarreo sale diciendo si la lectura fue bien
	ret			;d8d4
lee_un_bit_a_mano:
	inc b			;d8d5   ; A PARTIR DE AQUI NO SE EJECUTA NADA: es un cargador rapido que lee el bit a mano y que quedo sin usar (ver src/cargador.entries)
	ret z			;d8d6
	ld a,07fh		;d8d7
	in a,(0a2h)		;d8d9   ; el puerto 0xA2 es por donde el PSG devuelve la entrada de casete
	rra			;d8db
	xor c			;d8dc
	and 040h		;d8dd   ; y el bit 6 es el que trae la senal
	jr z,lee_un_bit_a_mano		;d8df
	ld a,c			;d8e1
	cpl			;d8e2
	ld c,a			;d8e3
	exx			;d8e4
	out (c),b		;d8e5   ; de paso saca dos bytes por el PSG: el chasquido de la carga
	out (c),d		;d8e7
	inc b			;d8e9
	exx			;d8ea
	scf			;d8eb
	ret			;d8ec

; ----------------------------------------------------------------------
; DATOS bufer_de_la_cabecerita: cuatro bytes: direccion de carga y longitud de
;   la pieza que se esta leyendo
;   0xd8ed..0xd8f1  (4 bytes)
DATA_bufer_de_la_cabecerita:
	defw 00000h,00000h	; d8ed

; ----------------------------------------------------------------------
; DATOS cola_del_cargador: 143 bytes que no lee nadie; la pieza mide 385 y el
;   codigo acaba en 0xD8EC
;   0xd8f1..0xd981  (144 bytes)
DATA_cola_del_cargador:
	defb 06ah,086h,086h,000h,000h,000h,064h,083h,084h,084h,084h,085h,087h,088h,06ah,000h	; d8f1  j.....d.......j.
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; d901  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; d911  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; d921  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; d931  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; d941  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; d951  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; d961  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh	; d971  ................

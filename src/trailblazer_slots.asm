; ==========================================================================
; TRAILBLAZER - Gremlin Graphics 1986 - MSX1 - el buscador de RAM
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x09000


; ======================================================================
; CODIGO 0x9000..0x9052  (82 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; EL BUSCADOR DE RAM: donde esta y como se encuentra
; ----------------------------------------------------------------------
busca_la_ram:
	di			;9000   ; nada de interrupciones mientras se anda con las ranuras
	in a,(0a8h)		;9001   ; el PPI de ranuras: dice que hay conectado en cada una de las cuatro paginas
	ld b,a			;9003
	ex af,af'			;9004   ; se guarda entero, para dejarlo como estaba al salir
	ld a,b			;9005   ; y una copia de trabajo
	and 030h		;9006   ; de lo que habia solo interesan los bits 4 y 5: la ranura de la PAGINA 2, que hay que respetar al tocar 0xFFFF
	ld b,a			;9008
	in a,(0a8h)		;9009   ; se relee
	and 0f3h		;900b   ; y se quitan los dos bits de la pagina 1, que es la que se va a probar
	sub 004h		;900d   ; menos cuatro, porque la primera vuelta del bucle suma antes de nada
	ld hl,04000h		;900f   ; 0x4000 es la pagina 1: es ahi donde tiene que haber RAM
prueba_una_ranura:
	add a,004h		;9012   ; la ranura siguiente
	out (0a8h),a		;9014   ; puesta en la pagina 1
	ld c,a			;9016   ; y guardada, que el bucle la necesita entera
	ld a,(hl)			;9017   ; la prueba de siempre: se lee lo que haya
	cpl			;9018   ; se le da la vuelta a los ocho bits
	ld (hl),a			;9019   ; se escribe
	cp (hl)			;901a   ; y se relee. Si vuelve lo escrito, es RAM; si no, es ROM o no hay nada
	ld a,c			;901b   ; la ranura que estaba probando
	jr z,aqui_hay_ram		;901c   ; y si valia, ya esta
	ld e,000h		;901e   ; si no, hay que mirar sus cuatro SUBRANURAS: 0, 4, 8 y 12
prueba_una_subranura:
	ld a,c			;9020
	rrca			;9021   ; la ranura de ahora, con sus dos bits subidos al hueco de arriba
	rrca			;9022
	rrca			;9023
	rrca			;9024
	and 0c0h		;9025   ; solo esos dos
	or b			;9027   ; y con ellos la ranura de la pagina 2, que es la que decide a que 0xFFFF se escribe
	out (0a8h),a		;9028   ; puesto
	ld a,(0ffffh)		;902a   ; el registro de subranuras vive en 0xFFFF y se lee INVERTIDO: asi lo devuelve el hardware
	cpl			;902d   ; por eso se le da la vuelta
	and 0f3h		;902e   ; se quitan los dos bits de la pagina 1
	or e			;9030   ; y se ponen los de la subranura que toca
	ld (0ffffh),a		;9031   ; escrito de vuelta
	ld a,c			;9034   ; se recupera la ranura normal
	out (0a8h),a		;9035   ; para poder volver a mirar la pagina 1
	ld a,(hl)			;9037   ; y la misma prueba: leer, invertir, escribir, comparar
	cpl			;9038
	ld (hl),a			;9039
	cp (hl)			;903a
	ld a,c			;903b
	jr z,aqui_hay_ram		;903c   ; si cuadra, hay RAM
	ld a,e			;903e   ; la subranura siguiente
	add a,004h		;903f   ; de cuatro en cuatro
	ld e,a			;9041
	cp 010h		;9042   ; cuatro subranuras y se acaban
	jr nz,prueba_una_subranura		;9044
	ld a,c			;9046   ; con la ranura siguiente
	jr prueba_una_ranura		;9047
aqui_hay_ram:
	ex af,af'			;9049   ; el PPI tal y como estaba al entrar
	out (0a8h),a		;904a   ; se devuelve
	ex af,af'			;904c
	ld (0fffeh),a		;904d   ; y en 0xFFFE queda el valor que hay que meter en el PPI para tener esa RAM. Es lo PRIMERO que hacen las otras tres piezas de la cinta: `ld a,(0fffeh) / out (0a8h),a`
	ei			;9050   ; ya se pueden admitir interrupciones otra vez
	ret			;9051

; ----------------------------------------------------------------------
; DATOS cola_del_buscador_de_ram: 175 bytes que no lee nadie; la pieza mide
;   257 y el `ret` del codigo esta en 0x9051
;   0x9052..0x9101  (175 bytes)
DATA_cola_del_buscador_de_ram:
	defb 000h,000h,000h,000h,001h,003h,000h,000h,000h,00eh,000h,000h,000h,000h,001h,000h	; 9052  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,008h,00ch,004h,004h,000h,000h	; 9062  ................
	defb 000h,000h,000h,000h,001h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh	; 9072  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 9082  ................
	defb 0f4h,0fch,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fbh,0ffh,0f5h,0fbh,0ffh,0ffh	; 9092  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f7h,0ffh,0ffh,0ffh	; 90a2  ................
	defb 0fch,0ffh,0ffh,0ffh,0fah,0ffh,0f7h,0ffh,0ffh,0ffh,0fbh,0ffh,0f7h,0feh,0fch,0f7h	; 90b2  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f3h,0ffh,0ffh,0fbh,0ffh,0ffh,0ffh,0ffh	; 90c2  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f2h,0ffh,0ffh,0ffh,0ffh,0ffh	; 90d2  ................
	defb 0fdh,0ffh,0ffh,0ffh,0fch,0f1h,0feh,0ffh,0f3h,0ffh,0f4h,0ffh,0f2h,0f2h,0ffh,0ffh	; 90e2  ................
	defb 0ffh,0ffh,0ffh,0ffh,0f7h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,000h	; 90f2  ...............

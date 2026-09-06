# CARGA LA CINTA DE TRAILBLAZER EN openMSX Y VUELCA LA VRAM Y LA RAM.
#
# Para que: los dibujos de este repositorio salen de leer la cinta con la
# geometria del TMS9918, y eso puede estar bien "de vista" y mal de verdad.
# Mirar la imagen no basta. Lo que cierra el asunto es volcar la VRAM de la
# maquina y compararla byte a byte con la que monta el script.
#
# Aqui hace falta ademas para otra cosa: **los registros del VDP**. El juego no
# los pone todos en un sitio, asi que en vez de deducir la geometria de una
# lectura del codigo se lee de la maquina, que es donde esta la verdad.
#
# La maquina tiene que ser un MSX1 con ROM real -aqui el Philips VG-8020-,
# porque el arranque pasa por el BASIC y por el BLOAD de la BIOS. A partir de
# ahi el juego usa su propio cargador y el BIOS ya no pinta nada.
#
# Uso:  TB_CAS=<ruta.cas> TB_OUT=<dir> [TB_TOPE=<segundos emulados>]
#           openmsx -machine Philips_VG_8020 -script este.tcl

set CAS  $::env(TB_CAS)
set OUT  $::env(TB_OUT)
set TOPE [expr {[info exists ::env(TB_TOPE)] ? $::env(TB_TOPE) : 900}]
file mkdir $OUT
set LOG [open "$OUT/carga.log" w]
proc say {m} {
    global LOG
    puts $LOG "\[emu [format %8.2f [machine_info time]]\] $m"
    flush $LOG
}

say "maquina: [machine_info config_name]"
set r [catch {cassetteplayer insert $CAS} msg]
say "cassetteplayer insert rc=$r: $msg"
if {$r} { say "ABORTADO"; exit 1 }
set renderer none
set throttle off
set speed 10000

proc arranca {} {
    say "tecleo BLOAD\"CAS:\",R"
    type "BLOAD\\\"CAS:\\\",R\r"
    after time 2 vigila
}
after time 6 arranca

# El juego vive en 0x80E8-0xCFFF. Se espera a que el PC lleve un buen rato ahi
# dentro: mientras carga esta en el turbo loader, que vive en 0xD800.
set ::dentro 0
set ::hecho 0
proc vigila {} {
    global OUT TOPE
    set pc [reg PC]
    if {$pc >= 0x80E8 && $pc < 0xD000} { incr ::dentro } else { set ::dentro 0 }
    if {$::dentro >= 8 && !$::hecho} {
        set ::hecho 1
        say [format "PC estable dentro del juego (0x%04X)" $pc]
        after time 5 vuelca
        return
    }
    if {[machine_info time] > $TOPE} {
        say [format "TOPE alcanzado sin ver el juego; PC=0x%04X" $pc]
        exit 1
    }
    after time 1 vigila
}

# Se vuelca DOS veces: una con la pantalla del titulo, que es a lo que llega
# el juego solo, y otra ya en la partida. La segunda hace falta porque los
# graficos de la pista no se montan hasta que se pulsa el 3 del menu ('3 :
# Play the game', lo dice el propio rotulo).
proc vuelca {} {
    global OUT LOG
    guarda "titulo"
    # El propio rotulo que desfila lo explica: "Press any key for options".
    # Primero una tecla cualquiera para entrar en el menu, y ya alli el 3, que
    # es "3 : Play the game".
    # `type` no sirve aqui: el juego lee el teclado a mano por el PPI y la
    # pulsacion que inyecta el BASIC dura menos que su barrido. Se aprieta la
    # tecla en la MATRIZ y se mantiene medio segundo.
    say "aprieto ESPACIO para las opciones"
    keymatrixdown 8 0x01
    after time 0.5 {keymatrixup 8 0x01}
    after time 4 al_menu
}

proc al_menu {} {
    say "aprieto el 3 para empezar la partida"
    keymatrixdown 0 0x08
    after time 0.5 {keymatrixup 0 0x08}
    after time 14 segunda
}

proc segunda {} {
    guarda "juego"
    say "FIN"
    exit 0
}

proc guarda {que} {
    global OUT
    say "vuelco la VRAM, la RAM y los registros del VDP ($que)"
    set f [open "$OUT/vram_$que.bin" wb]
    fconfigure $f -translation binary
    puts -nonewline $f [debug read_block VRAM 0 16384]
    close $f
    set g [open "$OUT/ram64k_$que.bin" wb]
    fconfigure $g -translation binary
    for {set a 0} {$a < 65536} {incr a} {
        puts -nonewline $g [binary format c [debug read "memory" $a]]
    }
    close $g
    # Los ocho registros del VDP, que es de donde sale la geometria de verdad
    set h [open "$OUT/vdp_$que.txt" w]
    for {set r 0} {$r < 8} {incr r} {
        puts $h [format "R%d = 0x%02X" $r [debug read "VDP regs" $r]]
    }
    puts $h [format "PC = 0x%04X" [reg PC]]
    close $h
    say [format "PC=0x%04X" [reg PC]]
}

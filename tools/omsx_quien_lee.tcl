# QUIEN LEE UNA ZONA DE MEMORIA, preguntandoselo a la maquina.
#
# El analisis estatico dice de donde sale cada tabla mientras la direccion
# aparezca escrita en un `ld hl,nnnn`. Cuando el juego la calcula -base mas
# indice, o el byte alto en un registro- no aparece en ninguna instruccion y no
# hay forma de encontrarla leyendo. Entonces se le pregunta al emulador: se
# pone un punto de vigilancia sobre la zona y se anota el PC de cada lectura.
#
# Uso:  TB_CAS=<ruta.cas> TB_OUT=<dir> TB_ZONA=<ini> TB_FIN=<fin>
#           openmsx -machine Philips_VG_8020 -script este.tcl

set CAS  $::env(TB_CAS)
set OUT  $::env(TB_OUT)
set INI  [expr {[info exists ::env(TB_ZONA)] ? $::env(TB_ZONA) : 0xC20E}]
set FIN  [expr {[info exists ::env(TB_FIN)]  ? $::env(TB_FIN)  : 0xD000}]
set TOPE [expr {[info exists ::env(TB_TOPE)] ? $::env(TB_TOPE) : 400}]
file mkdir $OUT
set LOG [open "$OUT/quien_lee.txt" w]

set r [catch {cassetteplayer insert $CAS} msg]
if {$r} { puts $LOG "no se pudo poner la cinta: $msg" ; close $LOG ; exit 1 }
set renderer none
set throttle off
set speed 10000

# Los PC que ya se han visto, para no llenar el fichero con el mismo bucle
array set ::vistos {}
set ::cuantos 0

proc anota {} {
    global OUT LOG
    set pc [reg PC]
    if {![info exists ::vistos($pc)]} {
        set ::vistos($pc) 1
        incr ::cuantos
        puts $LOG [format "PC=0x%04X" $pc]
        flush $LOG
    }
}

proc arranca {} {
    type "BLOAD\\\"CAS:\\\",R\r"
    # el punto de vigilancia se pone DESPUES de teclear, para no cazar al
    # propio cargador escribiendo la pieza en su sitio
    after time 175 al_menu
}
after time 6 arranca

# En el titulo hay menu, y lo dicen sus propios rotulos: 'Press any key for
# options' primero y '3 : Play the game' despues. Y el teclado NO se lee con el
# BIOS sino a mano por el PPI, asi que `type` no vale: hay que apretar la tecla
# en la MATRIZ y mantenerla medio segundo.
proc al_menu {} {
    global LOG
    puts $LOG "aprieto ESPACIO para las opciones"
    flush $LOG
    keymatrixdown 8 0x01
    after time 0.5 {keymatrixup 8 0x01}
    after time 4 a_jugar
}

proc a_jugar {} {
    global LOG
    puts $LOG "aprieto el 3 para empezar la partida"
    flush $LOG
    # la vigilancia se pone ANTES de arrancar la partida: lo que interesa
    # -montar la pista- pasa justo al empezar
    pon_vigilancia
    keymatrixdown 0 0x08
    after time 0.5 {keymatrixup 0 0x08}
}

proc pon_vigilancia {} {
    global INI FIN LOG
    puts $LOG [format "vigilando lecturas de 0x%04X a 0x%04X" $INI $FIN]
    flush $LOG
    debug set_watchpoint [expr {[info exists ::env(TB_ESCRIBE)] ? "write_mem" : "read_mem"}] [list $INI $FIN] {} {anota}
    after time 40 remata
}

proc remata {} {
    global LOG
    puts $LOG "FIN: $::cuantos sitios distintos leen la zona"
    close $LOG
    exit 0
}

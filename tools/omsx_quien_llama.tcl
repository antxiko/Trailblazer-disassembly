# QUIEN LLAMA A UNA RUTINA, preguntandoselo a la maquina.
#
# Hermano de omsx_quien_lee.tcl. Cuando una rutina no aparece en ningun `call`
# ni `jp` -porque se llega a ella por un salto relativo desde codigo que el
# trazador aun no ve, o porque el destino se calcula-, el analisis estatico se
# queda sin nada que mirar. Aqui se pone un punto de ruptura en la rutina y se
# anota **quien acaba de dejar la direccion de vuelta en la pila**, que es
# quien la ha llamado.
#
# Ojo con lo que se anota: si a la rutina se llega por un salto y no por un
# `call`, lo que hay en la pila es el retorno de QUIEN LLAMO ANTES, no de quien
# salto. Por eso se guarda tambien el PC anterior, que openMSX no da, y en su
# lugar se apunta el contenido de la pila entero para poder decidir despues.
#
# Uso:  TB_CAS=<ruta.cas> TB_OUT=<dir> TB_PUNTOS="0x81A5 0x8CBE ..."
#           openmsx -machine Philips_VG_8020 -script este.tcl

set CAS  $::env(TB_CAS)
set OUT  $::env(TB_OUT)
set PUNTOS [expr {[info exists ::env(TB_PUNTOS)] ? $::env(TB_PUNTOS) : ""}]
file mkdir $OUT
set LOG [open "$OUT/quien_llama.txt" w]

set r [catch {cassetteplayer insert $CAS} msg]
if {$r} { puts $LOG "no se pudo poner la cinta: $msg" ; close $LOG ; exit 1 }
set renderer none
set throttle off
set speed 10000

array set ::visto {}
set ::n 0

proc cazado {pc} {
    global LOG
    set sp [reg SP]
    set ret [expr {[debug read memory $sp] | ([debug read memory [expr {$sp+1}]] << 8)}]
    set clave "$pc-$ret"
    if {![info exists ::visto($clave)]} {
        set ::visto($clave) 1
        incr ::n
        puts $LOG [format "0x%04X  se entra con la pila apuntando a 0x%04X" $pc $ret]
        flush $LOG
    }
}

proc arranca {} {
    type "BLOAD\\\"CAS:\\\",R\r"
    after time 175 al_menu
}
after time 6 arranca

proc al_menu {} {
    global LOG PUNTOS
    keymatrixdown 8 0x01
    after time 0.5 {keymatrixup 8 0x01}
    after time 4 a_jugar
}

proc a_jugar {} {
    global LOG PUNTOS
    keymatrixdown 0 0x08
    after time 0.5 {keymatrixup 0 0x08}
    puts $LOG "puntos de ruptura en: $PUNTOS"
    flush $LOG
    foreach p $PUNTOS {
        debug set_bp $p {} "cazado $p"
    }
    after time 90 remata
}

proc remata {} {
    global LOG
    puts $LOG "FIN: $::n parejas distintas"
    close $LOG
    exit 0
}

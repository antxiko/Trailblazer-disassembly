# MUESTREA EL PC MIENTRAS CARGA LA CINTA.
#
# Para saber que trozos del cargador se ejecutan de verdad. Un punto de ruptura
# es mas exacto, pero con cientos de muestras basta para separar el codigo vivo
# del que no se toca nunca.
#
# Uso:  TB_CAS=<ruta.cas> TB_OUT=<dir> openmsx -machine ... -script este.tcl
set CAS $::env(TB_CAS)
set OUT $::env(TB_OUT)
file mkdir $OUT
set LOG [open "$OUT/muestreo.txt" w]
catch {cassetteplayer insert $CAS}
set renderer none
set throttle off
set speed 10000
array set ::pc {}
set ::n 0
proc mira {} {
    set p [reg PC]
    if {$p >= 0xD800 && $p < 0xD981} {
        if {[info exists ::pc($p)]} { incr ::pc($p) } else { set ::pc($p) 1 }
    }
    incr ::n
    if {$::n < 4000} { after time 0.05 mira } else { remata }
}
proc arranca {} { type "BLOAD\\\"CAS:\\\",R\r" ; after time 2 mira }
after time 6 arranca
proc remata {} {
    global LOG
    puts $LOG "muestras dentro del cargador, por direccion:"
    foreach a [lsort -integer [array names ::pc]] {
        puts $LOG [format "  0x%04X  %d" $a $::pc($a)]
    }
    close $LOG
    exit 0
}

# Trailblazer (Gremlin Graphics, 1986, MSX1) - desensamblado
#
# `make` trocea la cinta en sus cinco piezas, las traza desde sus puntos de
# entrada, genera los listados y comprueba que al reensamblarlos y volver a
# envolverlos sale EXACTAMENTE el .cas original, byte a byte.
#
# Lo que hace raro a esta cinta: el BIOS del MSX solo carga la PRIMERA pieza.
# Las otras cuatro las lee un cargador propio que monta EN LA PILA un puente de
# seis instrucciones -conmutar la ranura, llamar al BIOS de cinta, devolver la
# ranura- y se lo reescribe tres veces sobre la marcha. Por eso aqui hay cinco
# listados y no uno, y por eso el .cas no tiene la pinta de un .cas normal a
# partir del segundo bloque.

CAS     := trailblazer.cas
CAS_SHA := 779b662747fdd04b641fbf898124611562d9913e570f5050b5d73580ce63cf50
SYMS    := work/msx.sym
PY      := python3

PIEZAS  := cargador slots portada datos juego
ASMS    := $(patsubst %,src/trailblazer_%.asm,$(PIEZAS))

# Donde carga cada pieza. Sale de la cabecerita que la precede en la cinta, no
# de suponerlo: lo imprime tools/cinta.py.
ORG_cargador := 0xD800
ORG_slots    := 0x9000
ORG_portada  := 0x8800
ORG_datos    := 0x8800
ORG_juego    := 0x80E8

export PYTHONIOENCODING=utf-8

.PHONY: all cinta piezas trazado listados verify sanity test densidad \
        imagenes web emulador clean

all: verify sanity test densidad

# ---------------------------------------------------------------- la cinta
cinta:
	@if [ ! -f "$(CAS)" ]; then \
	  echo ""; \
	  echo "  Falta la imagen de cinta: $(CAS)"; \
	  echo ""; \
	  echo "  No se distribuye con este repositorio, solo el trabajo de"; \
	  echo "  documentacion. Para reconstruirlo todo hace falta tu propia"; \
	  echo "  copia del .cas, con ese nombre y en la raiz del proyecto."; \
	  echo "  Debe dar este sha256:"; \
	  echo "      $(CAS_SHA)"; \
	  echo ""; \
	  exit 1; \
	fi
	@echo "$(CAS_SHA)  $(CAS)" | sha256sum -c -

piezas: work/inventario.json
work/inventario.json: tools/cinta.py $(CAS)
	@mkdir -p work
	$(PY) tools/cinta.py $(CAS) work

$(SYMS): src/msx.sym
	@mkdir -p work
	cp $< $@

# ------------------------------------------------------------------ trazado
# Cada pieza se traza desde sus propios puntos de entrada. Los que no se pueden
# deducir -el salto que hace el cargador a la direccion de carga, los ganchos
# de interrupcion, los destinos de un `jp (hl)`- estan declarados en su
# .entries, cada uno con su justificacion escrita.
define TRAZA
work/$(1).trace.json: tools/z80trace.py src/$(1).entries src/$(1).nocode \
                      work/inventario.json
	$(PY) tools/z80trace.py work/$(1).bin $(ORG_$(1)) src/$(1).entries \
	      work/$(1) src/$(1).nocode
endef
$(foreach P,$(PIEZAS),$(eval $(call TRAZA,$(P))))

trazado: $(patsubst %,work/%.trace.json,$(PIEZAS))

# ----------------------------------------------------------------- listados
listados: $(ASMS)

define LISTADO
src/trailblazer_$(1).asm: work/$(1).trace.json src/$(1).notes tools/mkasm.py \
                          $(SYMS)
	$(PY) tools/mkasm.py work/$(1).bin $(ORG_$(1)) work/$(1).trace.json \
	      src/$(1).notes $(SYMS) $$@ \
	      "TRAILBLAZER - Gremlin Graphics 1986 - MSX1 - $(2)"
endef
$(eval $(call LISTADO,cargador,el turbo loader de cinta))
$(eval $(call LISTADO,slots,el buscador de RAM))
$(eval $(call LISTADO,portada,la pantalla de carga))
$(eval $(call LISTADO,datos,los textos y las pistas))
$(eval $(call LISTADO,juego,el juego))

# La prueba que decide si el desensamblado es fiable.
verify: listados
	@$(PY) tools/verifica.py src work $(CAS)

# Lo que el reensamblado NO puede cazar: que unos datos se esten leyendo como
# codigo. Los bytes no cambian; lo unico que cambia es lo que decimos de ellos.
sanity: listados
	@echo "=================================================================="
	@echo " ningun byte declarado como datos puede salir como codigo"
	@echo "=================================================================="
	@for p in $(PIEZAS); do \
	  $(PY) tools/check_trace.py work/$$p.trace.json src/$$p.nocode || exit 1; \
	done
	@$(PY) tools/check_datos.py work src
	@echo "=================================================================="
	@echo " ningun punto de entrada puede caer dentro de una zona de datos"
	@echo "=================================================================="
	@for p in $(PIEZAS); do \
	  $(PY) tools/check_entradas.py src/$$p.entries src/$$p.notes \
	        src/$$p.nocode || exit 1; \
	done
	@echo "=================================================================="
	@echo " ni un byte de la cinta sin asignar"
	@echo "=================================================================="
	@$(PY) tools/presupuesto.py work src $(CAS)

densidad:
	@$(PY) tools/densidad.py src

test:
	@echo "=================================================================="
	@echo " Tests"
	@echo "=================================================================="
	@$(PY) -m unittest discover -s tests -v

# Las imagenes, montadas ejecutando en Python los pasos del propio juego. No
# hay ni una captura de pantalla en este repositorio.
imagenes: work/inventario.json
	@mkdir -p work/gfx
	$(PY) tools/graficos.py work work/gfx

# El cotejo contra la maquina de verdad: se carga la cinta en openMSX, se
# vuelca su VRAM -y sus ocho registros del VDP, que es de donde salio la
# geometria- y se compara BYTE A BYTE con lo que dibujamos.
OPENMSX := C:/Program Files/openMSX/openmsx.exe
MAQUINA := Philips_VG_8020
emulador:
	@rm -rf work/omsx && mkdir -p work/omsx
	TB_CAS="$(CURDIR)/$(CAS)" TB_OUT="$(CURDIR)/work/omsx" \
	  "$(OPENMSX)" -machine $(MAQUINA) -script "$(CURDIR)/tools/omsx_carga.tcl"
	@$(PY) tools/coteja.py work

# LA WEB. Bilingue: el ingles en docs/ y el castellano en docs/es/.
web:
	$(PY) tools/pagina_pistas.py work docs
	$(PY) tools/md2html.py docs en
	$(PY) tools/md2html.py docs/es es
	$(PY) tools/make_web.py docs/imagenes docs/index.html en
	$(PY) tools/make_web.py docs/imagenes docs/es/index.html es
	$(PY) tools/check_enlaces.py docs

clean:
	rm -f work/*.bin work/*.json work/*.blocks work/*.log work/*.pasmo.bin

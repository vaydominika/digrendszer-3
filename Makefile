PRJ		= $(realpath ./)
PMON		= $(PRJ)/sw/pmon
LIB		= $(PRJ)/sw/lib
INCLUDES	= -I hw

TB		= hw/tm
TOP		= tm

include prj.mk
AW		?= 16

TOOLS		= sw/tools

MODS		= hw/defs hw/hwconf hw/version \
		  hw/computer/decoder \
		  hw/computer/comp \
		    hw/computer/addrdec1 \
		    hw/computer/addrdec2 \
		    hw/computer/memory \
		    hw/computer/mems \
		    hw/computer/reset_2btn \
		    hw/cpu1/cpu1 \
		      hw/cpu1/regm \
		      hw/cpu1/adder \
		      hw/cpu1/alu1 \
		      hw/cpu1/pc1 \
		      hw/cpu1/rfm1 \
		      hw/cpu1/schedm \
		    hw/cpu2/cpu2 \
		      hw/cpu2/alu2 \
		      hw/cpu2/reg2in \
		      hw/cpu2/rfm2 \
                      hw/cpu2/getb \
                      hw/cpu2/putb \
		      hw/cpu2/sfr \
		    hw/computer/gpio_out4 \
		    hw/computer/brd_ctrl \
		    hw/computer/gpio_in \
		    hw/computer/timer \
		    hw/computer/simif \
		    hw/computer/arm_fifo \
		    hw/computer/uart \
		    hw/computer/uart_rx \
		    hw/computer/uart_tx \
		    hw/computer/clock


TB_VER		= $(patsubst %,%.v,$(TB))

MODS_VER	= $(patsubst %,%.v,$(MODS))

VVP		= $(patsubst %,%.vvp,$(TB))

VCD		= $(patsubst %,%.vcd,$(TB))

GTKW		= $(patsubst %,%.gtkw,$(TB))

include $(PRJ)/sw/common.mk

.PHONY: sw hw pmon

all: progs sw show

compile: sw hw

progs:
	$(MAKE) -C sw/lib all
	$(MAKE) -C sw/pmon all
	$(MAKE) -C sw/examples all
	$(MAKE) -C sw/progs2 all

comp_pmon:
	$(MAKE) -C sw/pmon all

comp_mon: comp_pmon

comp_lib:
	$(MAKE) -C sw/lib all

comp_app: $(PRG).p2h $(PRG).asc $(PRG).cdb

$(PRG).p2h: $(PRG).asm $(LIB)/plib.p2l $(PMON)/pmon.p2h
	php $(TOOLS)/p2as.php -l -o $@ $(PRG).asm $(LIB)/plib.p2l

sw: comp_pmon comp_lib comp_app

source:
	php $(TOOLS)/source.php $(PRG).asc

show: simul
	gtkwave $(VCD) $(GTKW)

simul: $(VCD)

sim: $(VCD)

synth: $(VVP)

hw: synth

iss: sw
	$(ISS) $(PRG)

$(VCD): $(VVP)
	vvp -n $(VVP)

$(VVP): $(TB_VER) $(MODS_VER) prj.mk $(PRG).asc
	iverilog \
		-DPRG='"$(PRG).asc"' \
		-DINSTS=$(INSTS) \
		-DIVERILOG=1 \
		$(INCLUDES) \
		-o $(VVP) -s $(TOP) $(TB_VER) $(MODS_VER)

hw/version.v: .version $(TOOLS)/tool.php
	php $(TOOLS)/tool.php -vg >$@

#compile: $(HEX_FILES) $(ASC_FILES) $(CDB_FILES)



clean_files	= *~ .cproject .project \
		*.cmd_log *.html *.lso *.ngc *.ngr *.prj \
		*.stx \
		hex2asc source.txt

clean:
	$(MAKE) -C sw/examples clean
	$(MAKE) -C sw/progs2 clean
	$(MAKE) -C sw/pmon clean
	$(MAKE) -C sw/tools clean
	$(MAKE) -C hw/implement clean
	$(MAKE) -C sw/lib clean
	$(RM) $(clean_files)
	$(RM) ./computer/*~ ./cpu1/*~ ./cpu2/*~
	$(RM) ./hw/computer/*~ ./hw/cpu1/*~ ./hw/cpu2/*~
	$(RM) ./hw/cpu2/*.asc ./hw/cpu2/*.cdb ./hw/cpu2/*.lst ./hw/cpu2/*.p2*
	$(RM) ./hw/version.v  $(VCD) $(VVP)
	$(RM) ./docs/*bak ./docs/*~
	$(RM) vivado*.jou vivado*.log

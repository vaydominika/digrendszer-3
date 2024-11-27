PRJ		= ../..

include $(PRJ)/sw/common.mk

AW		?= 16

all: pmon_app

pmon_app: pmon.p2h pmon.asc pmon.cdb pmon.cc pmon_chip.asc
	php $(TOOLS)/hex2asc.php -gl -l 0xff00 pmon.p2h

pmon.p2h: pmon.asm eof_pmon.asm
	php $(TOOLS)/p2as.php -l -k -o $@ $^

pmon.cc: pmon.p2h $(PRJ)/.version
	php $(TOOLS)/hex2c.php -v $(PRJ)/.version $< >$@

pmon_chip.asc: pmon.p2h
	php $(TOOLS)/hex2asc.php -m 17 -c 0xf000 -cs 4096 $< >$@

clean:
	$(RM) *.hex *.p2h *.asc *.cdb *~ *.lst pmon.cc

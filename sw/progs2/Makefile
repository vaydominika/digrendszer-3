PRJ		= ../..

include $(PRJ)/sw/common.mk

AW		?= 16

PLIB		= $(LIB)/plib.p2l

all: pmonitor lib \
	counter2.asc counter2.cdb \
	counter3.asc counter3.cdb \
	uart.asc uart.cdb \
	uart2.asc uart2.cdb \
	test.asc test.cdb \
	regsave.asc regsave.cdb \
	msblink2.asc msblink2.cdb \
	div.asc div.cdb \
	ff.asc ff.cdb \
	game.asc game.cdb \
	bufout.asc bufout.cdb \
	le_test.asc le_test.cdb \
	rnd_test.asc rnd_test.cdb \
	strtest.asc strtest.cdb \
	dtoi_test.asc dtoi_test.cdb  \
	bugtest.asc bugtest.cdb \
	led.asc led.cdb \
	printbin.asc printbin.cdb \
	segmode.asc segmode.cdb \
	edges.asc edges.cdb \
	tudemo.asc tudemo.cdb


pmonitor:
	$(MAKE) -C $(PMON) pmon_app

lib:
	$(MAKE) -C $(LIB) all


counter2.p2h: counter2.asm $(PLIB)

counter3.p2h: counter3.asm $(PLIB)

uart.p2h: uart.asm $(PLIB)

uart2.p2h: uart2.asm $(PLIB)

regsave.p2h: regsave.asm $(PLIB)

msblink2.p2h: msblink2.asm $(PLIB)

test.p2h: test.asm $(PLIB)

div.p2h: div.asm $(PLIB)

ff.p2h: ff.asm $(PLIB)

game.p2h: game.asm $(PLIB)

bufout.p2h: bufout.asm $(PLIB)

strtest.p2h: strtest.asm $(PLIB)

led.p2h: led.asm $(PLIB)

le_test.p2h: le_test.asm $(PLIB)

rnd_test.p2h: rnd_test.asm $(PLIB)

bugtest.p2h: bugtest.asm $(PLIB)

dtoi_test.p2h: dtoi_test.asm $(PLIB)

printbin.p2h: printbin.asm $(LIB)

segmode.p2h: segmode.asm $(LIB)

edges.p2h: edges.asm $(LIB)

tudemo.p2h: tudemo.asm $(LIB)

clean:
	$(RM) *.hex *.p2h *.asc *.cdb *~ *.lst *.log pmon.cc

PRJ		= ../..

include	$(PRJ)/sw/common.mk

include $(PRJ)/prj.mk
AW		?= 16

PLIB		= $(LIB)/plib.p2l

all: pmonitor lib \
	simif_print \
	simif_print2.asc simif_print2.cdb \
	counter \
	counter2.asc counter2.cdb \
	array_sum \
	array_sum2.asc array_sum2.cdb \
	ff2ir \
	ff2ir2.asc ff2ir2.cdb \
	light1 \
	light12.asc light12.cdb \
	light2 \
	light22.asm light22.cdb \
	poll \
	poll2.asc poll2.cdb \
	shift_digit \
	blink_fr2.asc blink_fr2.cdb


pmonitor:
	$(MAKE) -C $(PMON) pmon.p2h

lib:
	$(MAKE) -C $(LIB) all

simif_print: simif_print.p2h simif_print.asc simif_print.cdb

simif_print2.p2h: simif_print2.asm $(PLIB)

shift_digit: shift_digit.p2h shift_digit.asc shift_digit.cdb

counter: counter.p2h counter.asc counter.cdb

counter2.p2h: counter2.asm $(PLIB)

array_sum: array_sum.p2h array_sum.asc array_sum.cdb

array_sum2.p2h: array_sum2.asm $(PLIB)

ff2ir: ff2ir.p2h ff2ir.asc ff2ir.cdb

ff2ir2.p2h: ff2ir2.asm $(PLIB)

light1: light1.p2h light1.asc light1.cdb

light12.p2h: light12.asm $(PLIB)

light2: light2.p2h light2.asc light2.cdb

light22.p2h: light22.asm $(PLIB)

poll: poll.p2h poll.asc poll.cdb

poll2.p2h: poll2.asm $(PLIB)

blink_fr2.p2h: blink_fr2.asm $(PLIB)


clean:
	$(RM) *.hex *.p2h *.asc *.cdb *~ *.lst

PRJ		= ../..

include $(PRJ)/sw/common.mk

AW		?= 16

OBJECTS		= \
		std.p2o \
		math.p2o \
		str.p2o \
		dev.p2o \
		char.p2o \
		inout.p2o \
		mon.p2o \
		bsp.p2o \
		terminal.p2o


all: lib

lib: plib.p2l

plib.p2l: plib.asm $(OBJECTS)
	php $(TOOLS)/p2as.php -c -l -dd -o plib.p2l $^

clean:
	$(RM) *.hex *.p2h *.p2o *.p2l *.cdb *.lst *.log *~

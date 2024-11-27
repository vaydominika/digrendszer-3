PRJ		= ../..

include $(PRJ)/sw/common.mk

all: mk_libs test2.asc test2.cdb test3

mk_libs:
	$(MAKE) -C $(LIB) all

test2.p2h: test2.asm p2as.php
	php p2as.php $< -l -dd -o $@

test2.asc: test2.p2h hex2asc.php
	php hex2asc.php $< >$@

test2.cdb: test2.p2h hex2cdb.php
	php hex2cdb.php $< >$@

TEST3_LIBS	= fn_div fn_rand fn_pmon
TEST3_LIBS_FN	= $(addprefix $(LIB)/,$(addsuffix .p2o,$(TEST3_LIBS)))

STDLIB		= $(LIB)/plib.p2l

test3: test3_byo.p2h test3_byo.cdb test3_byl.p2h test3_byl.cdb

test3_byo.p2h: p2as.php test3.asm $(TEST3_LIBS_FN)
	php p2as.php -l -dd -o test3_byo.p2h test3.asm $(TEST3_LIBS_FN)

test3_byo.cdb: test3_byo.p2h hex2cdb.php
	php hex2cdb.php $< >$@

test3_byl.p2h: p2as.php test3.asm $(STDLIB)
	php p2as.php -l -dd -o test3_byl.p2h test3.asm $(STDLIB)

test3_byl.cdb: test3_byl.p2h hex2cdb.php
	php hex2cdb.php $< >$@

clean:
	$(RM) *~ *.cdb *.hex *.p2h *.asc *.lst *.log

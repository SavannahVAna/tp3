LIBFLEX	= /usr/local/opt/flex/lib
CC	?= gcc
RM	= rm -f

.PHONY: all clean check default generate all

default:
	@echo "gmake check.flex|check.basic|check.race|generate|test6|test7|test8|test9|test10"

all: check.flex check.basic check.race test6 test7 test8 test9 test10

%:%.l
	flex -B -t -F $< > $(basename $<).c
	$(CC) -O3 $(basename $<).c -o $(basename $<)
	$(RM) -f lex.yy.c

%:%.c
	$(CC) -O3 $(basename $<).c -o $(basename $<)

clean:
	$(RM) -f *.core check.flex check.basic check.race test6 test7 test8 test9 test10
	$(RM) -f check*.c test10.c test8.c test7.c test6.c
	$(RM) -f zz.output*
	$(RM) -r conf
	$(RM) -r tmp
	mkdir conf
	mkdir tmp

generate: clean
	./generate.sh

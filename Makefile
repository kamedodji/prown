CFLAGS ?= -Wall
EXEC = prown
PROWN_SRC = $(wildcard src/*.c)
TESTS_SRC = $(wildcard tests/*.c)
SRC = $(PROWN_SRC) $(TESTS_SRC)
INDENT_FLAGS = --no-tabs \
               --indent-level4 \
               --braces-on-if-line \
               --cuddle-else \
               --continue-at-parentheses \
               --dont-break-procedure-type \
               --no-space-after-function-call-names \
               --braces-on-func-def-line \
               --blank-lines-after-declarations
CHECK = cppcheck
CHECKFLAGS ?= -I /usr/include -I /usr/include/linux --enable=all --language=c
prefix = /usr/local
all:src/$(EXEC)
doc:doc/man/$(EXEC).1

src/prown: $(PROWN_SRC)
	$(CC) $(CFLAGS) -o $@ $^ -lbsd -lacl

po: po/fr/$(EXEC).mo

po/fr/$(EXEC).mo: po/fr/$(EXEC).po
	msgfmt --output-file=$@ $<

po/fr/$(EXEC).po: po/$(EXEC).pot
	msgmerge --update $@ $<

po/$(EXEC).pot: $(PROWN_SRC)
	xgettext --keyword=_ --language=C --add-comments --sort-output --package-name=$(EXEC) --output $@ $(PROWN_SRC)

install: src/prown
	install -D src/prown \
                $(DESTDIR)$(prefix)/bin/prown
%.1: %.1.md
	pandoc --standalone --from markdown --to=man $^ --output $@

clean:
	-rm -f src/prown tests/isolate */*~ po/*/*.mo

indent:
	indent $(INDENT_FLAGS) $(SRC)
	sed -i 's/ *$$//;' $(SRC)  # remove trailing whitespaces

check:
	$(CHECK) $(CHECKFLAGS) $(PROWN_SRC)

tests/isolate: $(TESTS_SRC)
	$(CC) $(CFLAGS) -o $@ $^

tests: src/prown tests/isolate
	tests/run.sh

distclean: clean

uninstall:
	-rm -f $(DESTDIR)$(prefix)/bin/prown

.PHONY: all po install clean distclean indent check uninstall tests

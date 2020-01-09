.PHONY: all install build test run clean

ifdef USEINSTALL
INSTALLEXEC := install -Dm755
INSTALL := install -Dm644
else
INSTALLEXEC := sudo cp -f
INSTALL := sudo cp -f
endif

UNAME := $(shell uname)

ifeq ($(UNAME),Darwin)
	OS_FLAG := OSX
endif

all: build test

DESTDIR?=
install: build
ifeq ($(OS_FLAG),OSX)
	$(INSTALLEXEC) "./announce" "${DESTDIR}/usr/local/bin/announce"
else
	$(INSTALLEXEC) "./announce" "${DESTDIR}/usr/bin/announce"
	$(INSTALL) "./LICENSE" "${DESTDIR}/usr/share/licenses/announce/LICENSE"
endif

build:
	dub build

test:
	dub test

run: aight
	./announce

clean:
	rm -rf pkg/
	rm -rf src/
	rm -rf announce/
	rm -f announce-*.pkg.tar
	rm -f announce-test-library
	rm -f announce

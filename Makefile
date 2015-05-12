.PHONY: itests tests install all

PYENV ?= . .pyenv/bin/activate &&
TESTS ?= tests
PREFIX ?= /usr/local

itests:
	${MAKE} tests CRAM_OPTS=-i

tests:
	${PYENV} ZDOTDIR="${PWD}/tests" cram ${CRAM_OPTS} --shell=zsh ${TESTS}

install:
	mkdir -p ${PREFIX}/share && cp ./antigen.zsh ${PREFIX}/share/antigen.zsh

clean:
	rm -f ${PREFIX}/share/antigen.zsh

all: clean install

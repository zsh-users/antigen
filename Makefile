.PHONY: itests tests install all

PYENV ?= . .pyenv/bin/activate &&
TESTS ?= tests
PREFIX ?= /usr/local
SHELL ?= zsh
PROJECT ?= .
BIN ?= ${PROJECT}/bin

itests:
	${MAKE} tests CRAM_OPTS=-i

tests:
	${PYENV} ZDOTDIR="${ANTIGEN}/tests" cram ${CRAM_OPTS} --shell=${SHELL} ${TESTS}

stats:
	cp ${PROJECT}/tests/.zshrc ${HOME}/.zshrc
	for i in $$(seq 1 10); do /usr/bin/time -f "#$$i \t%es real \t%Us user \t%Ss system \t%x status" "${SHELL}" -ic exit; done

install:
	mkdir -p ${PREFIX}/share && cp ${BIN}/antigen.zsh ${PROJECT}/share/antigen.zsh

build:
	sed -e '/source.*\/ext\/.*\.zsh.*/d' ${PROJECT}/src/antigen.zsh > ${BIN}/antigen.zsh
	cat ${PROJECT}/src/ext/*.zsh >> ${BIN}/antigen.zsh

clean:
	rm -f ${PROJECT}/share/antigen.zsh

all: clean build install

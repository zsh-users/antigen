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
	${PYENV} ZDOTDIR="${PROJECT}/tests" cram ${CRAM_OPTS} --shell=${SHELL} ${TESTS}

stats:
	cp ${PROJECT}/tests/.zshrc ${HOME}/.zshrc
	rm -f /tmp/mtime
	for x in {1..20}; do /usr/bin/time -f "real %e user %U sys %S" -a -o /tmp/mtime ${SHELL} -ic exit; tail -1 /tmp/mtime; done	
	awk '{ et += $$2; ut += $$4; st += $$6; count++ } END {  printf "Average:\nreal %.3f user %.3f sys %.3f\n", et/count, ut/count, st/count }' /tmp/mtime

install:
	mkdir -p ${PREFIX}/share && cp ${BIN}/antigen.zsh ${PROJECT}/share/antigen.zsh

build:
	sed -e '/source.*\/ext\/.*\.zsh.*/d' ${PROJECT}/src/antigen.zsh > ${BIN}/antigen.zsh
	cat ${PROJECT}/src/ext/*.zsh >> ${BIN}/antigen.zsh

release:
	git describe --abbrev=0 --tags > ${PROJECT}/VERSION
	
clean:
	rm -f ${PROJECT}/share/antigen.zsh

all: clean release build install

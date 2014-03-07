.PHONY: itests tests

TESTS ?= tests

itests:
	${MAKE} tests CRAM_OPTS=-i

tests:
	. .pyenv/bin/activate && ZDOTDIR="${PWD}/tests" cram ${CRAM_OPTS} --shell=zsh ${TESTS}

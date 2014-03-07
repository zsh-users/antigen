.PHONY: itests tests

PYENV ?= . .pyenv/bin/activate &&
TESTS ?= tests

itests:
	${MAKE} tests CRAM_OPTS=-i

tests:
	${PYENV} ZDOTDIR="${PWD}/tests" cram ${CRAM_OPTS} --shell=zsh ${TESTS}

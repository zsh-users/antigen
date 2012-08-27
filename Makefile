.PHONY: itests tests

itests:
	ZDOTDIR="${PWD}/tests" cram -i --shell=zsh tests

tests:
	ZDOTDIR="${PWD}/tests" cram --shell=zsh tests

.PHONY: tests itests

tests:
	ZDOTDIR="${PWD}/tests" cram --shell=zsh tests

itests:
	ZDOTDIR="${PWD}/tests" cram -i --shell=zsh tests

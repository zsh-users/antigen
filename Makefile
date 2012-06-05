.PHONY: tests itests

tests:
	ZDOTDIR="${PWD}/tests" cram --shell=zsh tests

itests:
	cram -i --shell=zsh tests

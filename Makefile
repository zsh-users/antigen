.PHONY: tests

tests:
	ZDOTDIR="${PWD}/tests" cram -i --shell=zsh tests/branch-bundle.t

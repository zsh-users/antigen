.PHONY: tests

tests:
	ZDOTDIR="${PWD}/tests" cram -i --shell=zsh tests/branch-bundle.t \
			tests/bundle.t tests/url-resolver.t tests/antigen-wrapper.t

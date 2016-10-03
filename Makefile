.PHONY: itests tests install all

PYENV ?= . .pyenv/bin/activate &&
TESTS ?= tests
PREFIX ?= /usr/local
SHELL ?= zsh
PROJECT ?= $$PWD
BIN ?= ${PROJECT}/bin
CRAM_OPTS ?= '-v'

define ised
	sed $(1) $(2) > "$(2).1"
	mv "$(2).1" "$(2)"
endef

itests:
	${MAKE} tests CRAM_OPTS=-i

tests:
	${PYENV} ZDOTDIR="${PROJECT}/tests" cram ${CRAM_OPTS} --shell=${SHELL} ${TESTS}

install:
	mkdir -p ${PREFIX}/share && cp ${BIN}/antigen.zsh ${PREFIX}/share/antigen.zsh

build:
	cat ${PROJECT}/src/antigen.zsh > ${BIN}/antigen.zsh
	cat ${PROJECT}/src/helpers/*.zsh >> ${BIN}/antigen.zsh
	cat ${PROJECT}/src/lib/*.zsh >> ${BIN}/antigen.zsh
	cat ${PROJECT}/src/commands/*.zsh >> ${BIN}/antigen.zsh
	cat ${PROJECT}/src/_antigen >> ${BIN}/antigen.zsh
	cat ${PROJECT}/src/ext/*/*.zsh >> ${BIN}/antigen.zsh
	cat ${PROJECT}/src/ext/*.zsh >> ${BIN}/antigen.zsh
	$(call ised,"s/{{ANTIGEN_VERSION}}/$$(cat ${PROJECT}/VERSION)/",${BIN}/antigen.zsh)

release: build
	# Move to release branch
	vi VERSION
	git checkout develop
	git checkout -b release/$$(cat ${PROJECT}/VERSION)
	
	# make build and tests
	make build && make tests PYENV= SHELL=zsh
	
	# Update versions
	vi README.mkd
	
	# Update changelog
	vi CHANGELOG.md
	
publish:
	# Build release commit
	git add .
	git commit -m "Build release $$(cat ${PROJECT}/VERSION)"
	git push origin release/$$(cat ${PROJECT}/VERSION)

clean:
	rm -f ${PREFIX}/share/antigen.zsh

deps:
	pip install cram==0.6.*

stats:
	${PROJECT}/tests/stats.sh "${PROJECT}" "${SHELL}"

all: clean build install

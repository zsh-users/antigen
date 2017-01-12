.PHONY: itests tests install all

PYENV ?= . .pyenv/bin/activate &&
TESTS ?= tests
PREFIX ?= /usr/local
SHELL ?= zsh
PROJECT ?= $$PWD
BIN ?= ${PROJECT}/bin
CRAM_OPTS ?= '-v'

VERSION=$$(cat ${PROJECT}/VERSION)

define ised
	sed $(1) $(2) > "$(2).1"
	mv "$(2).1" "$(2)"
endef

build:
	cat ${PROJECT}/src/antigen.zsh > ${BIN}/antigen.zsh
	cat ${PROJECT}/src/helpers/*.zsh >> ${BIN}/antigen.zsh
	cat ${PROJECT}/src/lib/*.zsh >> ${BIN}/antigen.zsh
	cat ${PROJECT}/src/commands/*.zsh >> ${BIN}/antigen.zsh
	cat ${PROJECT}/src/_antigen >> ${BIN}/antigen.zsh
	cat ${PROJECT}/src/ext/*/*.zsh >> ${BIN}/antigen.zsh
	cat ${PROJECT}/src/ext/*.zsh >> ${BIN}/antigen.zsh
	$(call ised,"s/{{ANTIGEN_VERSION}}/$$(cat ${PROJECT}/VERSION)/",${BIN}/antigen.zsh)

release:
	# Move to release branch
	git checkout develop
	git checkout -b release/$(version)

	# Update release version
	echo "$(version)" > ${PROJECT}/VERSION

	# Make build and tests
	make build && make tests PYENV= SHELL=zsh
	
	# Update version references in README.md
	$(call ised, "s/${VERSION}/$(version)/",README.mkd)
	
	# Update changelog
	vi CHANGELOG.md

	# Build release commit
	git add CHANGELOG.md VERSION README.mkd bin/antigen.zsh
	git commit -S -m "Build release $(version)"

publish:
	git push origin release/${VERSION}
	# Merge release branch into develop before deploying

deploy:
	git checkout develop
	git tag -m "Build release ${VERSION}" -s ${VERSION}
	git push upstream ${VERSION}
	git archive --output=${VERSION}.tar.gz --prefix=antigen-$$(echo ${VERSION}|sed s/v//)/ ${VERSION}
	zcat ${VERSION}.tar.gz | gpg --armor --detach-sign >${VERSION}.tar.gz.sign
	# Verify signature
	zcat ${VERSION}.tar.gz | gpg --verify ${VERSION}.tar.gz.sign -

clean:
	rm -f ${PREFIX}/share/antigen.zsh

itests:
	${MAKE} tests CRAM_OPTS=-i

tests:
	${PYENV} ZDOTDIR="${PROJECT}/tests" cram ${CRAM_OPTS} --shell=${SHELL} ${TESTS}

install:
	mkdir -p ${PREFIX}/share && cp ${BIN}/antigen.zsh ${PREFIX}/share/antigen.zsh

deps:
	pip install cram==0.6.*

stats:
	"${SHELL}" ${PROJECT}/tests/stats.sh "${PROJECT}" "${SHELL}"

all: clean build install

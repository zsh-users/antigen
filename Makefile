.PHONY: itests tests install all

PYENV ?= 
TESTS ?= tests
PREFIX ?= /usr/local
SH ?= zsh
PROJECT ?= $$PWD
BIN ?= ${PROJECT}/bin
CRAM_OPTS ?= -v

TARGET ?= ${BIN}/antigen.zsh
SRC ?= ${PROJECT}/src
GLOB ?= ${SRC}/*.zsh $(sort $(wildcard ${PWD}/src/helpers/*.zsh)) \
        ${SRC}/lib/*.zsh $(sort $(wildcard ${PWD}/src/commands/*.zsh)) \
        ${SRC}/_antigen ${SRC}/ext/**/*.zsh ${SRC}/ext/*.zsh

VERSION_FILE=${PROJECT}/VERSION

define ised
	sed $(1) $(2) > "$(2).1"
	mv "$(2).1" "$(2)"
endef

build:
	:> ${TARGET}
	for src in ${GLOB}; do echo "$$src"; cat "$$src" >> ${TARGET}; done
	$(call ised,"s/{{ANTIGEN_VERSION}}/$$(cat ${VERSION_FILE})/",${TARGET})

readme:
	$(call ised, "s/$$(cat ${VERSION_FILE})/$(version)/",README.mkd)

release:
	# Move to release branch
	git checkout develop
	git checkout -b release/$(version)
	
	# Update version references in README.md
	$(call ised, "s/$$(cat ${VERSION_FILE})/$(version)/",README.mkd)
	
	# Update release version
	echo "$(version)" > ${VERSION_FILE}
	
	# Make build and tests
	make build && make tests
	
	# Update changelog
	${EDITOR} CHANGELOG.md
	
	# Build release commit
	git add CHANGELOG.md ${VERSION_FILE} README.mkd ${TARGET}
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
	${PYENV} ZDOTDIR="${PROJECT}/tests" cram ${CRAM_OPTS} --shell=${SH} ${TESTS}

install:
	mkdir -p ${PREFIX}/share && cp ${TARGET} ${PREFIX}/share/antigen.zsh

deps:
	pip install cram==0.6.*

stats:
	"${SH}" ${PROJECT}/tests/stats.sh "${PROJECT}" "${SH}"

all: clean build install

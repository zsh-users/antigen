SHELL     ?= sh
PREFIX    ?= /usr/local

CRAM_OPTS ?= -v

PROJECT   ?= $(CURDIR)
BIN       ?= ${PROJECT}/bin
SRC       ?= ${PROJECT}/src
TESTS     ?= ${PROJECT}/tests
TOOLS     ?= ${PROJECT}/tools
TEST      ?= ${PROJECT}/tests

ZSH_VERSION     ?= zsh-5.3
CONTAINER_ROOT  ?= /antigen
USE_CONTAINER   ?= docker
CONTAINER_IMAGE ?= desyncr/zsh-docker-

TARGET     ?= ${BIN}/antigen.zsh
SRC        ?= ${SRC}
DEBUG      ?= no
EXTENSIONS ?= 

# If debug is enabled then load debug functions
ifeq (${DEBUG}, yes)
EXTENSIONS += ${SRC}/lib/log.zsh
endif

# Use extension system
USE_EXT    ?= yes
ifeq (${USE_EXT}, yes)
EXTENSIONS += ${SRC}/ext/ext.zsh
endif

# Compile with defer extension
EXT_DEFER  ?= yes
ifeq (${EXT_DEFER}, yes)
EXTENSIONS += ${SRC}/ext/defer.zsh
endif

# Compile with lock extension
EXT_LOCK   ?= yes
ifeq (${EXT_LOCK}, yes)
EXTENSIONS += ${SRC}/ext/lock.zsh
endif

# Compile with parallel extension
EXT_PARALLEL ?= yes
ifeq (${EXT_PARALLEL}, yes)
EXTENSIONS += ${SRC}/ext/parallel.zsh
endif

# Compile with cache extension
EXT_CACHE   ?= yes
ifeq (${EXT_CACHE}, yes)
EXTENSIONS += ${SRC}/ext/cache.zsh
endif

GLOB         ?= ${SRC}/boot.zsh ${SRC}/antigen.zsh $(sort $(wildcard ${PWD}/src/helpers/*.zsh)) \
        ${SRC}/lib/*.zsh $(sort $(wildcard ${PWD}/src/commands/*.zsh)) ${EXTENSIONS} \
        ${SRC}/_antigen

VERSION      ?= develop
VERSION_FILE  = ${PROJECT}/VERSION

BANNER_SEP    =$(shell printf '%*s' 70 | tr ' ' '\#')
BANNER_TEXT   =This file was autogenerated by \`make\`. Do not edit it directly!
BANNER        =${BANNER_SEP}\n\# ${BANNER_TEXT}\n${BANNER_SEP}\n

define ised
	sed $(1) $(2) > "$(2).1"
	mv "$(2).1" "$(2)"
endef

define isede
	sed -E $(1) $(2) > "$(2).1"
	mv "$(2).1" "$(2)"
endef

.PHONY: itests tests install all

build:
	@echo Building Antigen...
	@printf "${BANNER}" > ${BIN}/antigen.zsh
	@for src in ${GLOB}; do echo "----> $$src"; cat "$$src" >> ${TARGET}; done
	@echo "${VERSION}" > ${VERSION_FILE}
	@$(call ised,"s/{{ANTIGEN_VERSION}}/$$(cat ${VERSION_FILE})/",${TARGET})
ifeq (${DEBUG}, no)
	@$(call isede,"s/(WARN|LOG|ERR|TRA) .*& //",${TARGET})
	@$(call isede,"/(WARN|LOG|ERR|TRA) .*/d",${TARGET})
endif
	@echo Done.
	@ls -sh ${TARGET}

release:
	git checkout develop
	${MAKE} build tests
	git checkout -b release/${VERSION}
	# Update changelog
	${EDITOR} CHANGELOG.md
	# Build release commit
	git add CHANGELOG.md ${VERSION_FILE} README.mkd ${TARGET}
	git commit -S -m "Build release ${VERSION}"

publish:
	git push origin release/${VERSION}
	# Merge release branch into develop before deploying

deploy:
	git checkout develop
	git tag -m "Build release ${VERSION}" -s ${VERSION}
	git archive --output=${VERSION}.tar.gz --prefix=antigen-$$(echo ${VERSION}|sed s/v//)/ ${VERSION}
	zcat ${VERSION}.tar.gz | gpg --armor --detach-sign >${VERSION}.tar.gz.sign
	# Verify signature
	zcat ${VERSION}.tar.gz | gpg --verify ${VERSION}.tar.gz.sign -
	# Push upstream
	git push upstream ${VERSION}

.container:
ifeq (${USE_CONTAINER}, docker)
	@docker run --rm --privileged=true -it -v ${PROJECT}:/antigen ${CONTAINER_IMAGE}${ZSH_VERSION} $(shell echo "${COMMAND}" | sed "s|${PROJECT}|${CONTAINER_ROOT}|g")
else ifeq (${USE_CONTAINER}, no)
	${COMMAND}
endif

info:
	@${MAKE} .container COMMAND="sh -c 'cat ${PROJECT}/VERSION; zsh --version; git --version; env'"

itests:
	@${MAKE} tests CRAM_OPTS=-i

tests:
	@${MAKE} .container COMMAND="sh -c 'ZDOTDIR=${TESTS} ANTIGEN=${PROJECT} cram ${CRAM_OPTS} --shell=zsh ${TEST}'"

stats:
	@${MAKE} .container COMMAND="${TOOLS}/stats --zsh zsh --antigen ${PROJECT}"

install:
	mkdir -p ${PREFIX}/share && cp ${TARGET} ${PREFIX}/share/antigen.zsh

clean:
	rm -f ${PREFIX}/share/antigen.zsh

install-deps:
	sudo pip install cram=='0.6.*'

all: clean build install

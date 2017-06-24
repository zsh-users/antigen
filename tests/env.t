Should display Antigen defined environment variables.

  $ antigen-env
  ANTIGEN_OMZ_REPO_URL=https://github.com/robbyrussell/oh-my-zsh.git
  ANTIGEN_PREZTO_REPO_URL=https://github.com/sorin-ionescu/prezto.git
  ANTIGEN_DEFAULT_REPO_URL=https://github.com/robbyrussell/oh-my-zsh.git
  ADOTDIR=.* (re)
  ANTIGEN_BUNDLES=.* (re)
  ANTIGEN_COMPDUMP=.* (re)
  ANTIGEN_LOG=/dev/null
  ANTIGEN_CLONE_ENV=GIT_TERMINAL_PROMPT=0
  ANTIGEN_CLONE_OPTS=--single-branch --recursive --depth=1
  ANTIGEN_SUBMODULE_OPTS=--recursive --depth=1
  _ANTIGEN_WARN_DUPLICATES=.* (re)
  _ANTIGEN_THEME_COMPAT=true
  _ANTIGEN_BUILTIN_EXTENSIONS=lock parallel defer cache

Should list any variable defined through -set-default.

  $ -antigen-set-default ANTIGEN_ENV_TEST antigen-env-test
  $ echo $ANTIGEN_ENV_TEST
  antigen-env-test
  $ antigen env | grep ANTIGEN_ENV_TEST
  ANTIGEN_ENV_TEST=antigen-env-test

Keep listing it even when the variable was unset.

  $ -antigen-set-default ANTIGEN_UNSET_VARIABLE unset-value
  $ echo $ANTIGEN_UNSET_VARIABLE
  unset-value
  $ unset ANTIGEN_UNSET_VARIABLE
  $ echo $ANTIGEN_UNSET_VARIABLE
  
  $ antigen env | grep ANTIGEN_UNSET_VARIABLE
  ANTIGEN_UNSET_VARIABLE=

No need to use ANTIGEN prefix.

  $ -antigen-set-default EXT_DEFAULT ext-name
  $ -antigen-set-default CUSTOM_BUNDLES 'multiple bundle names'
  $ antigen env | grep CUSTOM_BUNDLES
  CUSTOM_BUNDLES=multiple bundle names
  $ antigen env | grep EXT_DEFAULT
  EXT_DEFAULT=ext-name

Only support scalar values to be set (no array).

  $ typeset -a arr; arr=(1 2 3)
  $ -antigen-set-default ARR_VARIABLE $arr
  $ antigen env | grep ARR_VARIABLE
  ARR_VARIABLE=1

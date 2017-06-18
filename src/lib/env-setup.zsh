# Helper function: Same as `$1=$2`, but will only happen if the name
# specified by `$1` is not already set.
-antigen-set-default () {
  local arg_name="$1"
  local arg_value="$2"
  eval "test -z \"\$$arg_name\" && typeset -g $arg_name='$arg_value'"
}

-antigen-env-setup () {
  typeset -gU fpath path

  # Pre-startup initializations.
  -antigen-set-default ANTIGEN_OMZ_REPO_URL \
    https://github.com/robbyrussell/oh-my-zsh.git
  -antigen-set-default ANTIGEN_PREZTO_REPO_URL \
    https://github.com/sorin-ionescu/prezto.git
  -antigen-set-default ANTIGEN_DEFAULT_REPO_URL $ANTIGEN_OMZ_REPO_URL

  # Default Antigen directory.
  -antigen-set-default ADOTDIR $HOME/.antigen
  [[ ! -d $ADOTDIR ]] && mkdir -p $ADOTDIR

  # Defaults bundles directory.
  -antigen-set-default ANTIGEN_BUNDLES $ADOTDIR/bundles

  # If there is no bundles directory, create it.
  if [[ ! -d $ANTIGEN_BUNDLES ]]; then
    mkdir -p $ANTIGEN_BUNDLES
    # Check for v1 repos directory, transform it to v2 format.
    [[ -d $ADOTDIR/repos ]] && -antigen-update-repos
  fi

  -antigen-set-default ANTIGEN_COMPDUMP "${ADOTDIR:-$HOME}/.zcompdump"
  -antigen-set-default ANTIGEN_LOG /dev/null

  # CLONE_OPTS uses ${=CLONE_OPTS} expansion so don't use spaces
  # for arguments that can be passed as `--key=value`.
  -antigen-set-default ANTIGEN_CLONE_ENV "GIT_TERMINAL_PROMPT=0"
  -antigen-set-default ANTIGEN_CLONE_OPTS "--single-branch --recursive --depth=1"
  -antigen-set-default ANTIGEN_SUBMODULE_OPTS "--recursive --depth=1"

  # Complain when a bundle is already installed.
  -antigen-set-default _ANTIGEN_WARN_DUPLICATES true

  # Compatibility with oh-my-zsh themes.
  -antigen-set-default _ANTIGEN_THEME_COMPAT true
  
  # Add default built-in extensions to load at start up
  -antigen-set-default _ANTIGEN_BUILTIN_EXTENSIONS 'lock parallel defer cache'

  # Setup antigen's own completion.
  if -antigen-interactive-mode; then
    TRACE "Gonna create compdump file @ env-setup" COMPDUMP
    autoload -Uz compinit
    compinit -d "$ANTIGEN_COMPDUMP"
    compdef _antigen antigen
  else
    (( $+functions[antigen-ext-init] )) && antigen-ext-init
  fi
}

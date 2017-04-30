-antigen-env-setup () {
  # Helper function: Same as `$1=$2`, but will only happen if the name
  # specified by `$1` is not already set.
  -set-default () {
    local arg_name="$1"
    local arg_value="$2"
    eval "test -z \"\$$arg_name\" && typeset -g $arg_name='$arg_value'"
  }

  typeset -gU fpath path

  # Pre-startup initializations.
  -set-default ANTIGEN_DEFAULT_REPO_URL \
      https://github.com/robbyrussell/oh-my-zsh.git
  -set-default ANTIGEN_PREZTO_REPO_URL \
      https://github.com/sorin-ionescu/prezto.git

  -set-default ADOTDIR $HOME/.antigen
  [[ ! -d $ADOTDIR ]] && mkdir -p $ADOTDIR

  -set-default ANTIGEN_BUNDLES $ADOTDIR/bundles
  if [[ ! -d $ANTIGEN_BUNDLES ]]; then
    mkdir -p $ANTIGEN_BUNDLES
    [[ -d $ADOTDIR/repos ]] && -antigen-update-repos
  fi

  -set-default ANTIGEN_COMPDUMP "${ADOTDIR:-$HOME}/.zcompdump"

  -set-default ANTIGEN_LOG /dev/null

  # CLONE_OPTS uses ${=CLONE_OPTS} expansion so don't use spaces
  # for arguments that can be passed as `--key=value`.
  -set-default ANTIGEN_GIT_ENV "GIT_TERMINAL_PROMPT=0"
  -set-default ANTIGEN_CLONE_OPTS "--single-branch --recursive --depth=1"
  -set-default ANTIGEN_SUBMODULE_OPTS "--recursive --depth=1"

  -set-default _ANTIGEN_WARN_DUPLICATES true

  # Compatibility with oh-my-zsh themes.
  -set-default _ANTIGEN_THEME_COMPAT true

  # Cache auto config files to check for changes (.zshrc, .antigenrc etc)
  -set-default ANTIGEN_AUTO_CONFIG true
  
  # Default cache path.
  -set-default ANTIGEN_CACHE $ADOTDIR/init.zsh
  -set-default ANTIGEN_RSRC $ADOTDIR/.resources
  
  # Default lock path.
  -set-default ANTIGEN_LOCK $ADOTDIR/.lock

  # Setup antigen's own completion.
  autoload -Uz compinit
  compinit -C -d "$ANTIGEN_COMPDUMP"
  compdef _antigen antigen

  # Remove private functions.
  unfunction -- -set-default

  # Initialize cache unless disabled
  if [[ ! $ANTIGEN_CACHE == false ]] && ! -antigen-interactive-mode; then
    -antigen-cache-init
  fi
  
  # Initialize lock. It doesn't make sense to activate it in interactive mode.
  if ! -antigen-interactive-mode; then
    -antigen-lock-init
  fi

}

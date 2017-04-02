-antigen-env-setup () {
  # Helper function: Same as `$1=$2`, but will only happen if the name
  # specified by `$1` is not already set.
  -set-default () {
    local arg_name="$1"
    local arg_value="$2"
    eval "test -z \"\$$arg_name\" && $arg_name='$arg_value'"
  }

  # Pre-startup initializations.
  -set-default ANTIGEN_DEFAULT_REPO_URL \
      https://github.com/robbyrussell/oh-my-zsh.git
  -set-default ANTIGEN_PREZTO_REPO_URL \
      https://github.com/zsh-users/prezto.git

  -set-default ADOTDIR $HOME/.antigen
  [[ ! -d $ADOTDIR ]] && mkdir -p $ADOTDIR

  -set-default ANTIGEN_BUNDLES $ADOTDIR/bundles
  [[ ! -d $ANTIGEN_BUNDLES ]] && mkdir -p $ANTIGEN_BUNDLES

  -set-default ANTIGEN_COMPDUMP "${ADOTDIR:-$HOME}/.zcompdump"

  -set-default ANTIGEN_LOG /dev/null

  # CLONE_OPTS uses ${=CLONE_OPTS} expansion so don't use spaces
  # for arguments that can be passed as `--key=value`.
  -set-default ANTIGEN_CLONE_OPTS "--single-branch --recursive --depth=1"
  -set-default ANTIGEN_SUBMODULE_OPTS "--recursive --depth=1"

  # Setup antigen's own completion.
  autoload -Uz compinit
  compinit -C -d "$ANTIGEN_COMPDUMP"
  compdef _antigen antigen

  # Remove private functions.
  unfunction -- -set-default
}

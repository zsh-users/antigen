# Loads a given theme.
#
# Shares the same syntax as antigen-bundle command.
#
# Usage
#   antigen-theme [path] [zsh/theme[.zsh-theme]]
#
# Returns
#   0 if everything was succesfully
antigen-theme () {
  local name=$1 result=0 record=$1

  # Verify arguments are passed properly.
  if [[ -z "$name" ]]; then
    printf "Antigen: Must provide a theme url or name.\n" >&2
    return 1
  fi

  # Generate record name based off path and name for themes loaded from local paths,
  # this also supports themes loaded from the same repository.
  if [[ $name = */* ]]; then
     record="$1 ${2:-/}"
  fi

  local match mbegin mend MATCH MBEGIN MEND

  # Verify theme hasn't been loaded previously.
  if [[ "$_ANTIGEN_THEME" == "$record" ]]; then
    printf "Antigen: Theme \"%s\" is already active.\n" $name >&2
    return 1
  fi

  # Remove currently active hooks, this may leave the prompt broken if the
  # new theme is not found/can not be loaded. We should have a way to test if
  # a theme/bundle can be loaded/exists.
  #-antigen-theme-reset-hooks

  if [[ "$1" != */* && "$1" != --* ]]; then
    # The first argument is just a name of the plugin, to be picked up from
    # the default repo.
    antigen-bundle --loc=themes/$name --btype=theme

  else
    antigen-bundle "$@" --btype=theme

  fi
  result=$?

  # Do remove theme record if we're successful at loading this one.
  if [[ $result == 0 ]]; then
    # Remove theme from record if there was one registered.
    if [[ "$_ANTIGEN_THEME" != "" && $_ANTIGEN_BUNDLE_RECORD[(I)*$_ANTIGEN_THEME*] > 0 ]]; then
      _ANTIGEN_BUNDLE_RECORD[$_ANTIGEN_BUNDLE_RECORD[(I)*$_ANTIGEN_THEME*]]=()
    fi
    
    # Set new theme as active.
    _ANTIGEN_THEME=$record
  fi

  return $result
}

-antigen-theme-reset-hooks () {
  # This is only needed on interactive mode
  autoload -U add-zsh-hook is-at-least
  local hook

  # Clear out prompts
  PROMPT=""
  if [[ -n $RPROMPT ]]; then
    RPROMPT=""
  fi

  for hook in chpwd precmd preexec periodic; do
    add-zsh-hook -D "${hook}" "prompt_*"
    # common in omz themes
    add-zsh-hook -D "${hook}" "*_${hook}"
    add-zsh-hook -d "${hook}" "vcs_info"
  done
}

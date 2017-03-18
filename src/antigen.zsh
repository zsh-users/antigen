# Antigen: A simple plugin manager for zsh
# Authors: Shrikant Sharat Kandula
#          and Contributors <https://github.com/zsh-users/antigen/contributors>
# Homepage: http://antigen.sharats.me
# License: MIT License <mitl.sharats.me>

# Each line in this string has the following entries separated by a space
# character.
# <repo-url>, <plugin-location>, <bundle-type>, <has-local-clone>
_ANTIGEN_BUNDLE_RECORD=${_ANTIGEN_BUNDLE_RECORD:-""}
[[ -z "$_ANTIGEN_INSTALL_DIR" ]] && _ANTIGEN_INSTALL_DIR=${0:A:h}
_ANTIGEN_COMP_ENABLED=${_ANTIGEN_COMP_ENABLED:-true}
_ANTIGEN_INTERACTIVE=${_ANTIGEN_INTERACTIVE_MODE:-false}
_ANTIGEN_RESET_THEME_HOOKS=${_ANTIGEN_RESET_THEME_HOOKS:-true}
_ANTIGEN_FORCE_RESET_COMPDUMP=${_ANTIGEN_FORCE_RESET_COMPDUMP:-true}

# Do not load anything if git is not available.
if (( ! $+commands[git] )); then
    echo 'Antigen: Please install git to use Antigen.' >&2
    return 1
fi

# Used to defer compinit/compdef
typeset -a __deferred_compdefs
compdef () { __deferred_compdefs=($__deferred_compdefs "$*") }

# A syntax sugar to avoid the `-` when calling antigen commands. With this
# function, you can write `antigen-bundle` as `antigen bundle` and so on.
antigen () {
  local cmd="$1"
  if [[ -z "$cmd" ]]; then
    echo 'Antigen: Please give a command to run.' >&2
    return 1
  fi
  shift

  if (( $+functions[antigen-$cmd] )); then
      "antigen-$cmd" "$@"
  else
      echo "Antigen: Unknown command: $cmd" >&2
  fi
}

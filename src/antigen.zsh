[[ -z "$_ANTIGEN_INSTALL_DIR" ]] && _ANTIGEN_INSTALL_DIR=${0:A:h}

# Each line in this string has the following entries separated by a space
# character.
# <repo-url>, <plugin-location>, <bundle-type>, <has-local-clone>
[[ $_ANTIGEN_CACHE_LOADED != true ]] && typeset -aU _ANTIGEN_BUNDLE_RECORD

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
      return $?
  else
      echo "Antigen: Unknown command: $cmd" >&2
      return 1
  fi
}

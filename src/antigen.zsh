# Antigen: A simple plugin manager for zsh
# Authors: Shrikant Sharat Kandula
#          and Contributors <https://github.com/zsh-users/antigen/contributors>
# Homepage: http://antigen.sharats.me
# License: MIT License <mitl.sharats.me>

# Each line in this string has the following entries separated by a space
# character.
# <repo-url>, <plugin-location>, <bundle-type>, <has-local-clone>
local _ANTIGEN_BUNDLE_RECORD=""
local _ANTIGEN_INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
local _ANTIGEN_CACHE_ENABLED=${_ANTIGEN_CACHE_ENABLED:-true}
local _ANTIGEN_COMP_ENABLED=${_ANTIGEN_COMP_ENABLED:-true}
local _ANTIGEN_INTERACTIVE=${_ANTIGEN_INTERACTIVE_MODE:-false}
local _ANTIGEN_RESET_THEME_HOOKS=${_ANTIGEN_RESET_THEME_HOOKS:-true}
local _ANTIGEN_AUTODETECT_CONFIG_CHANGES=${_ANTIGEN_AUTODETECT_CONFIG_CHANGES:-true}
local _ANTIGEN_FORCE_RESET_COMPDUMP=${_ANTIGEN_FORCE_RESET_COMPDUMP:-true}

# Do not load anything if git is not available.
if ! which git &> /dev/null; then
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

    if functions "antigen-$cmd" > /dev/null; then
        "antigen-$cmd" "$@"
    else
        echo "Antigen: Unknown command: $cmd" >&2
    fi
}

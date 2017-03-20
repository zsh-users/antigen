# Antigen: A simple plugin manager for zsh
# Authors: Shrikant Sharat Kandula
#          and Contributors <https://github.com/zsh-users/antigen/contributors>
# Homepage: http://antigen.sharats.me
# License: MIT License <mitl.sharats.me>

_ANTIGEN_CACHE="${_ANTIGEN_CACHE:-${ADOTDIR:-$HOME/.antigen}/init.zsh}"

if [[ -n $_ANTIGEN_CHECK_FILES ]]; then
  # Used to do full boostrap
  check_timestamp="${ADOTDIR:-$HOME/.antigen}/.timestamp"

  # source: http://stackoverflow.com/q/17878684
  if stat -c %Y . >/dev/null 2>&1; then
    -antigen-get-timestamp() { stat -c %Y "$1" 2>/dev/null; }
  elif stat -f %m . >/dev/null 2>&1; then
    -antigen-get-timestamp() { stat -f %m "$1" 2>/dev/null; }
  elif date -r . +%s >/dev/null 2>&1; then
    -antigen-get-timestamp() { stat -r "$1" +%s 2>/dev/null; }
  else
    echo '-antigen-get-timestamp() is unsupported' >&2
    -antigen-get-timestamp() { printf '%s' 0; }
  fi
  timestamp=0
  for config in $_ANTIGEN_CHECK_FILES; do
    config_timestamp=$(-antigen-get-timestamp $config)
    if [ $timestamp -lt "$config_timestamp" ]; then
      timestamp=$config_timestamp
    fi
  done

  if [ -f $_ANTIGEN_CHECK_TIMESTAMP ]; then
    saved=$(cat $check_timestamp)
    if [ $saved -lt $timestamp ]; then
      # Do full bootstrap
      echo $timestamp>!$check_timestamp
      [[ -f "$_ANTIGEN_CACHE" ]] && \rm -f "$_ANTIGEN_CACHE"
    fi
  else
    echo $timestamp>!$check_timestamp
  fi

  unset check_timestamp timestamp saved
fi

[[ -f $_ANTIGEN_CACHE && ! $_ANTIGEN_CACHE_LOADED == true ]] && source "$_ANTIGEN_CACHE" && return;

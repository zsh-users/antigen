# Used to fastboot antigen
# Enable or disable timestamp checks
_ANTIGEN_CHECK_CHANGES=${_ANTIGEN_CHECK_CHANGES:-false}
[[ -z $_ANTIGEN_CHECK_FILES ]] && _ANTIGEN_CHECK_FILES=($HOME/.zshrc ${ADOTDIR:-$HOME}/.antigenrc)

# Used to do full boostrap
_ANTIGEN_CHECK_TIMESTAMP="${ADOTDIR:-$HOME/.antigen}/.timestamp"

if [[ $_ANTIGEN_CHECK_CHANGES == true ]]; then
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
    saved=$(cat $_ANTIGEN_CHECK_TIMESTAMP)
    if [ $saved -lt $timestamp ]; then
      # Do full bootstrap
      echo $timestamp>!$_ANTIGEN_CHECK_TIMESTAMP
      [[ -f "$_ANTIGEN_CACHE" ]] && \rm -f "$_ANTIGEN_CACHE"
    fi
  else
    echo $timestamp>!$_ANTIGEN_CHECK_TIMESTAMP
  fi
fi

_ANTIGEN_CACHE="${_ANTIGEN_CACHE:-${ADOTDIR:-$HOME/.antigen}/init.zsh}"
[[ -f $_ANTIGEN_CACHE && ! $_ANTIGEN_CACHE_LOADED == true ]] && source "$_ANTIGEN_CACHE" && return;
_ANTIGEN_INSTALL_DIR=${0:A:h}
source $_ANTIGEN_INSTALL_DIR/bin/antigen.zsh

# Used for lazy-loading.
_ANTIGEN_SOURCE="$_ANTIGEN_INSTALL_DIR/antigen.zsh"

# Enable or disable timestamp checks
_ZCACHE_TIMESTAMP_CHECK_ENABLED=${_ZCACHE_TIMESTAMP_CHECK_ENABLED:-true}
_ZCACHE_TIMESTAMP_CHECK=${_ZCACHE_TIMESTAMP_CHECK:-($HOME/.zshrc ${ADOTDIR:-$HOME}/.antigenrc)}

# Used to do full boostrap
_ZCACHE_TIMESTAMP="${ADOTDIR:-$HOME/.antigen}/.timestamp"

if [[ $_ZCACHE_TIMESTAMP_CHECK_ENABLED == true ]]; then
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

  local timestamp=0
  for config in $_ZCACHE_TIMESTAMP_CHECK; do
    config_timestamp=$(-antigen-get-timestamp $config)
    if [ $timestamp -lt "$config_timestamp" ]; then
      timestamp=$config_timestamp
    fi
  done

  if [ -r $_ZCACHE_TIMESTAMP ]; then
    saved=$(cat $_ZCACHE_TIMESTAMP)
    if [ $saved -lt $timestamp ]; then
      # Do full bootstrap
      echo $timestamp > $_ZCACHE_TIMESTAMP
      _ANTIGEN_FAST_BOOT_ENABLED=false
      [[ -f "$_ZCACHE_PAYLOAD" ]] && rm -f "$_ZCACHE_PAYLOAD"
    fi
  else
    echo $timestamp > $_ZCACHE_TIMESTAMP
  fi
fi

[[ -f $_ZCACHE_PAYLOAD && ! $_ZCACHE_CACHE_LOADED == true ]] && source "$_ZCACHE_PAYLOAD" && return;


# Used for lazy-loading.
_ANTIGEN_SOURCE="$_ANTIGEN_INSTALL_DIR/antigen.zsh"
# Used to fastboot antigen
_ZCACHE_PAYLOAD="${ADOTDIR:-$HOME/.antigen}/.cache/.zcache-payload"

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

# Use this functionallity only if both CACHE and FASTBOOT options are enabled.
if [[ $_ANTIGEN_CACHE_ENABLED == true && $_ANTIGEN_FAST_BOOT_ENABLED == true ]]; then

  # If there is cache (zcache payload), and it wasn't loaded then procced.

  # The condition "$_ZCACHE_CACHE_LOADED != true" was crafted this way because
  # $_ZCACHE_CACHE_LOADED variable is otherwise undefined, so it seems easier to
  # check for a known value.
  if [[ $_ZCACHE_CACHE_LOADED != true && -f "$_ZCACHE_PAYLOAD" ]]; then

    # Do load zcache payload, this has the following effects:
    #   - _ANTIGEN_BUNDLE_RECORD is updated from cache
    #   - _ZCACHE_CACHE_LOADED is set to TRUE
    #   - _antigen is updated from cache
    #   - fpath is updated from cache
    #   - autoload compinit && compinit -id $ANTIGEN_COMPDUMPFILE
    source "$_ZCACHE_PAYLOAD"

    # Lazyload wrapper
    -antigen-lazyloader () {
      # Hook antigen functions to lazy load antigen itself
      for command in ${(Mok)functions:#antigen*}; do
        # Once any of the hooked functions are called and antigen is finally
        # loaded what will happen is that antigen overwrittes the hooked functions
        # so no other call to them will be executed, thus no need to
        # 'unhook' or uninitialize them.
        eval "$command () { source "$_ANTIGEN_SOURCE"; eval $command \$@ }"
      done
      unfunction -- '-antigen-lazyloader'
    }

    # Disable antigen commands
    typeset -a _commands
    _commands=('use' 'bundle' 'bundles' 'theme' 'list' 'apply' 'cleanup' \
     'help' 'list' 'reset' 'restore' 'revert' 'snapshot' 'selfupdate' 'update' 'version')
    for command in $_commands; do
      eval "antigen-$command () {}"
    done

    # On antigen apply or init
    antigen () {
      if [[ "$1" == "apply" || "$1" == "init" ]]; then
        -antigen-lazyloader
      fi
    }

    # On antigen-apply
    antigen-apply () {
      -antigen-lazyloader
    }

    # On antigen-init
    antigen-init () {
      -antigen-lazyloader $@
    }

    return
  fi
fi

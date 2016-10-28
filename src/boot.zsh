# Used for lazy-loading.
_ANTIGEN_SOURCE="$(cd "$(dirname "$0")" && pwd)/antigen.zsh"
# Used to fastboot antigen
_ZCACHE_PAYLOAD="${ADOTDIR:-$HOME/.antigen}/.cache/.zcache-payload"

ANTIGEN_COMPDUMPFILE=${ANTIGEN_COMPDUMPFILE:-${ZDOTDIR:-$HOME}/.zcompdump}

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
        _commands=('use' 'bundle' 'bundles' 'init' 'theme' 'list' 'apply' 'cleanup' \
         'help' 'list' 'reset' 'restore' 'revert' 'snapshot' 'selfupdate' 'update' 'version')
        for command in $_commands; do
            eval "antigen-$command () {}"
        done

        # On antigen apply
        antigen () {
            if [[ "$1" == "apply" ]]; then
                -antigen-lazyloader
            fi
        }
        # On antigen-apply
        antigen-apply () {
            -antigen-lazyloader
        }

        return
    fi
fi

_ANTIGEN_SOURCE="$(cd "$(dirname "$0")" && pwd)/antigen.zsh"
_ZCACHE_PAYLOAD="${ADOTDIR:-$HOME/.antigen}/.cache/.zcache-payload"
_ANTIGEN_COMPDUMPFILE=${ANTIGEN_COMPDUMPFILE:-$HOME/.zcompdump}

if [[ $_ANTIGEN_CACHE_ENABLED == true && $_ANTIGEN_FAST_BOOT_ENABLED == true ]]; then
    if [[ $_ZCACHE_CACHE_LOADED != true && -f "$_ZCACHE_PAYLOAD" ]]; then
        source "$_ZCACHE_PAYLOAD"

        -antigen-lazyloader () {
            for command in ${(Mok)functions:#antigen*}; do
                eval "$command () { echo 'from lazy load'; source "$_ANTIGEN_SOURCE"; eval $command \$@ }"
            done
            unfunction -- '-antigen-lazyloader'
        }

        # Disable antigen commands
        for command in use bundle bundles init theme list apply cleanup help list reset restore revert snapshot selfupdate update version; do
            eval "antigen-$command () {}"
        done

        antigen () {
            if [[ "$1" == "apply" ]]; then
                -antigen-lazyloader
            fi
        }

        antigen-apply () {
            -antigen-lazyloader
        }
        return
    fi
fi

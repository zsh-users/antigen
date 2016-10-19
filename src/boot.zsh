_ANTIGEN_SOURCE="$(cd "$(dirname "$0")" && pwd)/antigen.zsh"
_ZCACHE_PAYLOAD="${ADOTDIR:-$HOME/.antigen}/.cache/.zcache-payload"
_ANTIGEN_COMPDUMPFILE=${ANTIGEN_COMPDUMPFILE:-$HOME/.zcompdump}

if [[ $_ANTIGEN_CACHE_ENABLED == true && $_ANTIGEN_FAST_BOOT_ENABLED == true ]]; then
    if [[ $_ZCACHE_CACHE_LOADED == false && -f "$_ZCACHE_PAYLOAD" ]]; then
        source "$_ZCACHE_PAYLOAD"
    
        -antigen-selfsource () {
            source "$_ANTIGEN_SOURCE"
            
            unfunction -- '-antigen-selfsource'
        }
        antigen-use () { }
        antigen-theme () { }
        antigen-bundle () { }
        antigen-init () { }
        antigen () {
            if [[ "$1" == "apply" ]]; then
                -antigen-selfsource
            fi
        }

        antigen-apply () {
            -antigen-selfsource
        }

        return
    fi
fi

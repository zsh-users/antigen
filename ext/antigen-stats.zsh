# stats extension
#
# sends a +1 for all bundle installed (effectively counting the number of installs).

# this is a per-bundle count. it doesn't count antigen or per each run.
# it count each time a bundle is cloned locally.
#
# stats are saved per-repository so zsh-git will be different than random-guy/zsh-git

# stats disabled by default
export _ANTIGEN_STATS=false
export _ANTIGEN_STATS_SERVER=127.0.0.1
export _ANTIGEN_STATS_PORT=8125

# not necesary has to identical to -antigen-get-clone-dir
# in fact we are avoiding local paths that's why we're copying it
function -stats-get-repo-name () {
    echo "$1" | sed \
        -e 's./.-SLASH-.g' \
        -e 's.:.-COLON-.g' \
        -e 's.|.-PIPE-.g'
}

# send 'install' stats to statd server located at "$_ANTIGEN_STATS_SERVER:$_ANTIGEN_STATS_PORT".
# here we're performing the same check the original 'antigen-ensure-repo' function does,
# which is checking for the local repository clone; if it's not present we assume it's gonna be installed
function -stats-grab-stats () {
    local url=
    local update=false
    local verbose=false

    eval "$(-antigen-parse-args 'url ; update?, verbose?' "$@")"
    shift $#

    local repo_name="$(-antigen-get-clone-dir $url)"
    if [[ ! -d $repo_name ]]; then
        -ext-log "installing bundle: $repo_name"
        local repo_name="$(-stats-get-repo-name $url)"
        echo "$repo_name:+1|g" | nc -u -w1 $_ANTIGEN_STATS_SERVER $_ANTIGEN_STATS_PORT
    fi
}

# hook into ensure-repo function which is reponsible for cloning repos if necesary
-ext-hook "-antigen-ensure-repo" "-stats-grab-stats"

# function to show the current extension status
function antigen-stats () {
    local stats_enabled="disabled"
    if [[ $_ANTIGEN_STATS ]]; then
        stats_enabled="enabled"
    fi
    echo "Antigen stats are $stats_enabled. Use \$_ANTIGEN_STATS to enable or disable."
}

# adds above completion
-ext-compadd "stats"

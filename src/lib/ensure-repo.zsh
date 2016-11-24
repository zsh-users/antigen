# Ensure that a clone exists for the given repo url and branch. If the first
# argument is `update` and if a clone already exists for the given repo
# and branch, it is pull-ed, i.e., updated.
#
# This function expects three arguments in order:
# - 'url=<url>'
# - 'update=true|false'
# - 'verbose=true|false'
#
# Returns true|false Whether cloning/pulling was succesful
-antigen-ensure-repo () {
    # Argument defaults.
    # The url. No sane default for this, so just empty.
    local url=${1:?"url must be set"}
    # Check if we have to update.
    local update=${2:-false}
    # Verbose output.
    local verbose=${3:-false}

    shift $#

    # Get the clone's directory as per the given repo url and branch.
    local clone_dir="$(-antigen-get-clone-dir $url)"

    # A temporary function wrapping the `git` command with repeated arguments.
    --plugin-git () {
        (cd "$clone_dir" &>> $_ANTIGEN_LOG_PATH && git --no-pager "$@" &>> $_ANTIGEN_LOG_PATH)
    }

    # Clone if it doesn't already exist.
    local start=$(date +'%s')
    local install_or_update=false
    local success=false
    if [[ ! -d $clone_dir ]]; then
        install_or_update=true
        echo -n "Installing $(-antigen-bundle-short-name $url)... "
        git clone --recursive "${url%|*}" "$clone_dir" &>> $_ANTIGEN_LOG_PATH
        success=$?
    elif $update; then
        local branch=$(--plugin-git rev-parse --abbrev-ref HEAD)
        if [[ $url == *\|* ]]; then
            # Get the clone's branch
            branch="${url#*|}"
        fi
        install_or_update=true
        echo -n "Updating $(-antigen-bundle-short-name $url)... "
        # Save current revision.
        local old_rev="$(--plugin-git rev-parse HEAD)"
        # Pull changes if update requested.
        --plugin-git checkout $branch
        --plugin-git pull origin $branch
        success=$?
        # Update submodules.
        --plugin-git submodule update --recursive
        # Get the new revision.
        local new_rev="$(--plugin-git rev-parse HEAD)"
    fi

    if $install_or_update; then
        local took=$(( $(date +'%s') - $start ))
        if [[ $success -eq 0 ]]; then
            printf "Done. Took %ds.\n" $took
        else
            echo -n "Error! See $_ANTIGEN_LOG_PATH.";
        fi
    fi

    # If its a specific branch that we want, checkout that branch.
    if [[ $url == *\|* ]]; then
        local current_branch=${$(--plugin-git symbolic-ref HEAD)##refs/heads/}
        local requested_branch="${url#*|}"
        # Only do the checkout when we are not already on the branch.
        [[ $requested_branch != $current_branch ]] &&
            --plugin-git checkout $requested_branch
    fi

    if [[ -n $old_rev && $old_rev != $new_rev ]]; then
        echo Updated from $old_rev[0,7] to $new_rev[0,7].
        if $verbose; then
            --plugin-git log --oneline --reverse --no-merges --stat '@{1}..'
        fi
    fi

    # Remove the temporary git wrapper function.
    unfunction -- --plugin-git

    return $success
}

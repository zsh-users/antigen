#!/bin/zsh

# Each line in this string has the following entries separated by a space
# character.
# <repo-url>, <plugin-location>, <bundle-type>
# FIXME: Is not kept local by zsh!
local _ANTIGEN_BUNDLE_RECORD=""

# Syntaxes
#   antigen-bundle <url> [<loc>=/]
antigen-bundle () {

    # Bundle spec arguments' default values.
    local url="$ANTIGEN_DEFAULT_REPO_URL"
    local loc=/
    local btype=plugin

    # Set spec values based on the positional arguments.
    local position_args='url loc'
    local i=1
    while ! [[ -z $1 || $1 == --*=* ]]; do
        local arg_name="$(echo "$position_args" | cut -d\  -f$i)"
        local arg_value="$1"
        eval "local $arg_name='$arg_value'"
        shift
        i=$(($i + 1))
    done

    # Check if url is just the plugin name. Super short syntax.
    if [[ "$url" != */* ]]; then
        loc="plugins/$url"
        url="$ANTIGEN_DEFAULT_REPO_URL"
    fi

    # Set spec values from keyword arguments, if any. The remaining arguments
    # are all assumed to be keyword arguments.
    while [[ $1 == --*=* ]]; do
        local arg_name="$(echo "$1" | cut -d= -f1 | sed 's/^--//')"
        local arg_value="$(echo "$1" | cut -d= -f2)"
        eval "local $arg_name='$arg_value'"
        shift
    done

    # Resolve the url.
    if [[ $url != git://* && $url != https://* && $url != /* ]]; then
        url="${url%.git}"
        url="https://github.com/$url.git"
    fi

    # Add it to the record.
    _ANTIGEN_BUNDLE_RECORD="$_ANTIGEN_BUNDLE_RECORD\n$url $loc $btype"

    -antigen-ensure-repo "$url"

    -antigen-load "$url" "$loc" "$btype"

}

antigen-bundles () {
    # Bulk add many bundles at one go. Empty lines and lines starting with a `#`
    # are ignored. Everything else is given to `antigen-bundle` as is, no
    # quoting rules applied.

    local line

    grep -v '^$\|^#' | while read line; do
        # Using `eval` so that we can use the shell-style quoting in each line
        # piped to `antigen-bundles`.
        eval "antigen-bundle $line"
    done
}

antigen-update () {
    # Update your bundles, i.e., `git pull` in all the plugin repos.
    -antigen-echo-record | awk '{print $1}' | sort -u | while read url; do
        -antigen-ensure-repo --update "$url"
    done
}

-antigen-get-clone-dir () {
    # Takes a repo url and gives out the path that this url needs to be cloned
    # to. Doesn't actually clone anything.
    # TODO: Memoize?
    echo -n $ADOTDIR/repos/
    echo "$1" | sed \
        -e 's/\.git$//' \
        -e 's./.-SLASH-.g' \
        -e 's.:.-COLON-.g'
}

-antigen-get-clone-url () {
    # Takes a repo's clone dir and gives out the repo's original url that was
    # used to create the given directory path.
    # TODO: Memoize?
    echo "$1" | sed \
        -e "s:^$ADOTDIR/repos/::" \
        -e 's/$/.git/' \
        -e 's.-SLASH-./.g' \
        -e 's.-COLON-.:.g'
}

-antigen-ensure-repo () {

    local update=false
    if [[ $1 == --update ]]; then
        update=true
        shift
    fi

    local url="$1"
    local clone_dir="$(-antigen-get-clone-dir $url)"

    if [[ ! -d $clone_dir ]]; then
        git clone "$url" "$clone_dir"
    elif $update; then
        git --git-dir "$clone_dir/.git" --work-tree "$clone_dir" pull
    fi

}

-antigen-load () {

    local url="$1"
    local location="$(-antigen-get-clone-dir "$url")/$2"
    local btype="$3"

    if [[ $btype == theme ]]; then

        # Of course, if its a theme, the location would point to the script
        # file.
        source "$location"

    else

        # Source the plugin script
        # FIXME: I don't know. Looks very very ugly. Needs a better
        # implementation once tests are ready.
        local script_loc="$(ls "$location" | grep -m1 '.plugin.zsh$')"
        if [[ -f $script_loc ]]; then
            # If we have a `*.plugin.zsh`, source it.
            source "$script_loc"
        elif [[ ! -z "$(ls "$location" | grep -m1 '.zsh$')" ]]; then
            # If there is no `*.plugin.zsh` file, source *all* the `*.zsh`
            # files.
            for script ($location/*.zsh) source "$script"
        elif [[ ! -z "$(ls "$location" | grep -m1 '.sh$')" ]]; then
            # If there are no `*.zsh` files either, we look for and source any
            # `*.sh` files instead.
            for script ($location/*.sh) source "$script"
        fi

        # Add to $fpath, for completion(s)
        fpath=($location $fpath)

    fi

}

antigen-cleanup () {

    if [[ ! -d "$ADOTDIR/repos" || -z "$(ls "$ADOTDIR/repos/")" ]]; then
        echo "You don't have any bundles."
        return 0
    fi

    # Find directores in ADOTDIR/repos, that are not in the bundles record.
    local unused_clones="$(comm -13 \
        <(-antigen-echo-record | awk '{print $1}' | sort -u) \
        <(ls "$ADOTDIR/repos" | while read line; do
                -antigen-get-clone-url "$line"
            done))"

    if [[ -z $unused_clones ]]; then
        echo "You don't have any unidentified bundles."
        return 0
    fi

    echo 'You have clones for the following repos, but are not used.'
    echo "$unused_clones" | sed 's/^/  /'

    echo -n '\nDelete them all? [y/N] '
    if read -q; then
        echo
        echo
        echo "$unused_clones" | while read url; do
            echo -n "Deleting clone for $url..."
            rm -rf "$(-antigen-get-clone-dir $url)"
            echo ' done.'
        done
    else
        echo
        echo Nothing deleted.
    fi
}

antigen-lib () {
    antigen-bundle --loc=lib
}

antigen-theme () {
    local name="${1:-robbyrussell}"
    antigen-bundle --loc=themes/$name.zsh-theme --btype=theme
}

antigen-apply () {
    # Initialize completion.
    # TODO: Only load completions if there are any changes to the bundle
    # repositories.
    compinit -i
}

antigen-list () {
    # List all currently installed bundles
    if [[ -z "$_ANTIGEN_BUNDLE_RECORD" ]]; then
        echo "You don't have any bundles." >&2
        return 1
    else
        -antigen-echo-record
    fi
}

# Echo the bundle specs as in the record. The first line is not echoed since it
# is a blank line.
-antigen-echo-record () {
    echo "$_ANTIGEN_BUNDLE_RECORD" | sed -n '1!p'
}

-antigen-env-setup () {
    # Pre-startup initializations
    -set-default ANTIGEN_DEFAULT_REPO_URL \
        https://github.com/robbyrussell/oh-my-zsh.git
    -set-default ADOTDIR $HOME/.antigen

    # Load the compinit module
    autoload -U compinit

    # Without the following, `compdef` function is not defined.
    compinit -i
}

# Same as `export $1=$2`, but will only happen if the name specified by `$1` is
# not already set.
-set-default () {
    local arg_name="$1"
    local arg_value="$2"
    eval "test -z \"\$$arg_name\" && export $arg_name='$arg_value'"
}

-antigen-env-setup

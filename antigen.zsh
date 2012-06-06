#!/bin/zsh

# Each line in this string has the following entries separated by a space
# character.
# <bundle-name>, <repo-url>, <plugin-location>, <repo-local-clone-dir>
# FIXME: Is not kept local by zsh!
local bundles=""

# Syntaxes
#   bundle <url> [<loc>=/] [<name>]
bundle () {

    # Bundle spec arguments' default values.
    local url="$ANTIGEN_DEFAULT_REPO_URL"
    local loc=/
    local name=
    local load=true

    # Set spec values based on the positional arguments.
    local position_args='url loc name'
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
    if [[ $url != git://* && $url != https://* ]]; then
        url="${url%.git}"
        name="$(basename "$url")"
        url="https://github.com/$url.git"
    fi

    # Plugin's repo will be cloned here.
    local clone_dir="$ANTIGEN_REPO_CACHE/$(echo "$url" \
        | sed -e 's/\.git$//' -e 's./.-SLASH-.g' -e 's.:.-COLON-.g')"

    # Make an intelligent guess about the name of the plugin, if not already
    # done or is explicitly specified.
    if [[ -z $name ]]; then
        name="$(basename $url/$loc)"
    fi

    # Add it to the record.
    bundles="$bundles\n$name $url $loc $clone_dir"

    # Load it, unless specified otherwise.
    if $load; then
        bundle-load "$name"
    fi
}

bundle-install () {

    local update=false
    if [[ $1 == --update ]]; then
        update=true
        shift
    fi

    mkdir -p "$ANTIGEN_BUNDLE_DIR"

    local handled_repos=""
    local install_bundles=""

    if [[ $# != 0 ]]; then
        # Record and install just the given plugin here and now.
        bundle "$@"
        install_bundles="$(echo "$bundles" | tail -1)"
    else
        # Install all the plugins, previously recorded.
        install_bundles="$(-bundle-echo-record)"
    fi

    # If the above `if` is directly piped to the below `while`, the contents
    # inside the `if` construct are run in a new subshell, so changes to the
    # `$bundles` variable are lost after the `if` construct finishes. So, we
    # need the temporary `$install_bundles` variable.
    echo "$install_bundles" | while read spec; do

        local name="$(echo "$spec" | awk '{print $1}')"
        local url="$(echo "$spec" | awk '{print $2}')"
        local loc="$(echo "$spec" | awk '{print $3}')"
        local clone_dir="$(echo "$spec" | awk '{print $4}')"

        if [[ -z "$(echo "$handled_repos" | grep -Fm1 "$url")" ]]; then
            if [[ ! -d $clone_dir ]]; then
                git clone "$url" "$clone_dir"
            elif $update; then
                git --git-dir "$clone_dir/.git" pull
            fi

            handled_repos="$handled_repos\n$url"
        fi

        if [[ $name != *.theme ]]; then
            echo Installing $name
            local bundle_dest="$ANTIGEN_BUNDLE_DIR/$name"
            test -e "$bundle_dest" && rm -rf "$bundle_dest"
            ln -s "$clone_dir/$loc" "$bundle_dest"
        else
            mkdir -p "$ANTIGEN_BUNDLE_DIR/$name"
            cp "$clone_dir/$loc" "$ANTIGEN_BUNDLE_DIR/$name"
        fi

        bundle-load "$name"

    done

    # Initialize completions after installing
    bundle-apply

}

bundle-install! () {
    bundle-install --update
}

bundle-cleanup () {

    if [[ ! -d "$ANTIGEN_BUNDLE_DIR" || \
        "$(ls "$ANTIGEN_BUNDLE_DIR/" | wc -l)" == 0 ]]; then
        echo "You don't have any bundles."
        return 0
    fi

    # Find directores in ANTIGEN_BUNDLE_DIR, that are not in the bundles record.
    local unidentified_bundles="$(comm -13 \
        <(-bundle-echo-record | awk '{print $1}' | sort) \
        <(ls -1 "$ANTIGEN_BUNDLE_DIR"))"

    if [[ -z $unidentified_bundles ]]; then
        echo "You don't have any unidentified bundles."
        return 0
    fi

    echo The following bundles are not recorded:
    echo "$unidentified_bundles" | sed 's/^/  /'

    echo -n '\nDelete them all? [y/N] '
    if read -q; then
        echo
        echo
        echo "$unidentified_bundles" | while read name; do
            echo -n Deleting $name...
            rm -rf "$ANTIGEN_BUNDLE_DIR/$name"
            echo ' done.'
        done
    else
        echo
        echo Nothing deleted.
    fi
}

bundle-load () {

    local name="$1"
    local bundle_dir="$ANTIGEN_BUNDLE_DIR/$name"

    # Source the plugin script
    local script_loc="$bundle_dir/$name.plugin.zsh"
    if [[ -f $script_loc ]]; then
        source "$script_loc"
    fi

    # If the name of the plugin ends with `.lib`, all the *.zsh files in it are
    # sourced. This is kind of a hack to source the libraries of oh-my-zsh.
    if [[ $name == *.lib ]]; then
        # FIXME: This throws an error if no files match the given glob pattern.
        for lib ($bundle_dir/*.zsh) source $lib
    fi

    # If the name ends with `.theme`, it is handled as if it were a zsh-theme
    # plugin.
    if [[ $name == *.theme ]]; then
        local theme_file="$bundle_dir/${name%.theme}.zsh-theme"
        test -f "$theme_file" && source "$theme_file"
    fi

    # Add to $fpath, for completion(s)
    fpath=($bundle_dir $fpath)

}

bundle-lib () {
    bundle --name=oh-my-zsh.lib --loc=lib
}

bundle-theme () {
    local url="$ANTIGEN_DEFAULT_REPO_URL"
    local name="${1:-robbyrussell}"
    bundle-install "$url" --name=$name.theme --loc=themes/$name.zsh-theme
}

bundle-apply () {
    # Initialize completion.
    compinit -i
}

bundle-list () {
    # List all currently installed bundles
    if [[ -z "$bundles" ]]; then
        echo "You don't have any bundles." >&2
        return 1
    else
        -bundle-echo-record | awk '{print $1 " " $2 " " $3}'
    fi
}

# Does what it says.
-bundle-echo-record () {
    echo "$bundles" | sed -n '1!p'
}

-bundle-env-setup () {
    # Pre-startup initializations
    -set-default ANTIGEN_DEFAULT_REPO_URL \
        https://github.com/robbyrussell/oh-my-zsh.git
    -set-default ANTIGEN_REPO_CACHE $HOME/.antigen/cache
    -set-default ANTIGEN_BUNDLE_DIR $HOME/.antigen/bundles

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

-bundle-env-setup

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
        arg_name="$(echo "$position_args" | cut -d\  -f$i)"
        arg_value="$1"
        eval "local $arg_name='$arg_value'"
        shift
        i=$(($i + 1))
    done

    # Set spec values from keyword arguments, if any. The remaining arguments
    # are all assumed to be keyword arguments.
    while [[ $1 == --*=* ]]; do
        arg_name="$(echo "$1" | cut -d= -f1 | sed 's/^--//')"
        arg_value="$(echo "$1" | cut -d= -f2)"
        eval "local $arg_name='$arg_value'"
        shift
    done

    # Resolve the url.
    if [[ $url != git://* && $url != https://* ]]; then
        url="https://github.com/$url.git"
        name="$(basename "$url")"
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

    if [[ $1 == --update ]]; then
        local update=true
    else
        local update=false
    fi

    mkdir -p "$ANTIGEN_BUNDLE_DIR"

    local handled_repos=""

    echo-non-empty "$bundles" | while read spec; do

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
            cp -r "$clone_dir/$loc" "$ANTIGEN_BUNDLE_DIR/$name"
        else
            mkdir -p "$ANTIGEN_BUNDLE_DIR/$name"
            cp "$clone_dir/$loc" "$ANTIGEN_BUNDLE_DIR/$name"
        fi

        bundle-load "$name"

    done

}

bundle-install! () {
    bundle-install --update
}

bundle-load () {
    if [[ $1 == --init ]]; then
        do_init=true
        shift
    else
        do_init=false
    fi

    name="$1"
    bundle_dir="$ANTIGEN_BUNDLE_DIR/$name"

    # Source the plugin script
    script_loc="$bundle_dir/$name.plugin.zsh"
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
        source "$bundle_dir/${name%.theme}.zsh-theme"
    fi

    # Add to $fpath, if it provides completion
    if [[ -f "$bundle_dir/_$name" ]]; then
        fpath=($bundle_dir $fpath)
    fi

    if $do_init; then
        bundle-init
    fi
}

bundle-lib () {
    bundle --name=oh-my-zsh.lib --loc=lib
}

bundle-theme () {
    local url="$ANTIGEN_DEFAULT_REPO_URL"
    local name="${1:-robbyrussell}"
    bundle "$url" --name=$name.theme --loc=themes/$name.zsh-theme
}

bundle-init () {
    # Initialize completion.
    # FIXME: Ensure this runs only once.
    autoload -U compinit
    compinit -i
}

# A python command wrapper. Almost the same as `python -c`, but dedents the
# source string.
py () {
    code="$1"

    # Find indentation from first line.
    indent="$(echo "$code" | grep -m1 -v '^$' | grep -o '^\s*' | wc -c)"

    # Strip that many spaces in the start from each line.
    if [[ $indent != 0 ]]; then
        indent=$(($indent - 1))
        code="$(echo "$code" | sed "s/^\s\{$indent\}//")"
    fi

    # Run the piece of code.
    python -c "$code"
}

# Does what it says.
echo-non-empty () {
    echo "$@" | while read line; do
        [[ $line != "" ]] && echo $line
    done
}

-bundle-env-setup () {
    -set-default ANTIGEN_DEFAULT_REPO_URL \
        https://github.com/robbyrussell/oh-my-zsh.git
    -set-default ANTIGEN_REPO_CACHE $HOME/.antigen/cache
    -set-default ANTIGEN_BUNDLE_DIR $HOME/.antigen/bundles
}

# Same as `export $1=$2`, but will only happen if the name specified by `$1` is
# not already set.
-set-default () {
    arg_name="$1"
    arg_value="$2"
    eval "test -z \"\$$arg_name\" && export $arg_name='$arg_value'"
}

-bundle-env-setup
bundle-init

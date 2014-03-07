# Antigen: A simple plugin manager for zsh
# Authors: Shrikant Sharat Kandula
#          and Contributors <https://github.com/zsh-users/antigen/contributors>
# Homepage: http://antigen.sharats.me
# License: MIT License <mitl.sharats.me>

# Each line in this string has the following entries separated by a space
# character.
# <repo-url>, <plugin-location>, <bundle-type>, <has-local-clone>
# FIXME: Is not kept local by zsh!
local _ANTIGEN_BUNDLE_RECORD=""
local _ANTIGEN_INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"

# Used to defer compinit/compdef
typeset -a __deferred_compdefs
compdef () { __deferred_compdefs=($__deferred_compdefs "$*") }

# Syntaxes
#   antigen-bundle <url> [<loc>=/]
# Keyword only arguments:
#   branch - The branch of the repo to use for this bundle.
antigen-bundle () {

    # Bundle spec arguments' default values.
    local url="$ANTIGEN_DEFAULT_REPO_URL"
    local loc=/
    local branch=
    local no_local_clone=false
    local btype=plugin

    # Parse the given arguments. (Will overwrite the above values).
    eval "$(-antigen-parse-args \
            'url?, loc? ; branch:?, no-local-clone?, btype:?' \
            "$@")"

    # Check if url is just the plugin name. Super short syntax.
    if [[ "$url" != */* ]]; then
        loc="plugins/$url"
        url="$ANTIGEN_DEFAULT_REPO_URL"
    fi

    # Resolve the url.
    url="$(-antigen-resolve-bundle-url "$url")"

    # Add the branch information to the url.
    if [[ ! -z $branch ]]; then
        url="$url|$branch"
    fi

    # The `make_local_clone` variable better represents whether there should be
    # a local clone made. For cloning to be avoided, firstly, the `$url` should
    # be an absolute local path and `$branch` should be empty. In addition to
    # these two conditions, either the `--no-local-clone` option should be
    # given, or `$url` should not a git repo.
    local make_local_clone=true
    if [[ $url == /* && -z $branch &&
            ( $no_local_clone == true || ! -d $url/.git ) ]]; then
        make_local_clone=false
    fi

    # Add the theme extension to `loc`, if this is a theme.
    if [[ $btype == theme && $loc != *.zsh-theme ]]; then
        loc="$loc.zsh-theme"
    fi

    # Add it to the record.
    _ANTIGEN_BUNDLE_RECORD="$_ANTIGEN_BUNDLE_RECORD\n$url $loc $btype"
    _ANTIGEN_BUNDLE_RECORD="$_ANTIGEN_BUNDLE_RECORD $make_local_clone"

    # Ensure a clone exists for this repo, if needed.
    if $make_local_clone; then
        -antigen-ensure-repo "$url"
    fi

    # Load the plugin.
    -antigen-load "$url" "$loc" "$btype" "$make_local_clone"

}

-antigen-resolve-bundle-url () {
    # Given an acceptable short/full form of a bundle's repo url, this function
    # echoes the full form of the repo's clone url.

    local url="$1"

    # Expand short github url syntax: `username/reponame`.
    if [[ $url != git://* &&
            $url != https://* &&
            $url != http://* &&
            $url != ssh://* &&
            $url != /* &&
            $url != git@github.com:*/*
            ]]; then
        url="https://github.com/${url%.git}.git"
    fi

    echo "$url"
}

antigen-bundles () {
    # Bulk add many bundles at one go. Empty lines and lines starting with a `#`
    # are ignored. Everything else is given to `antigen-bundle` as is, no
    # quoting rules applied.

    local line

    grep '^[[:space:]]*[^[:space:]#]' | while read line; do
        # Using `eval` so that we can use the shell-style quoting in each line
        # piped to `antigen-bundles`.
        eval "antigen-bundle $line"
    done
}

antigen-update () {
    # Update your bundles, i.e., `git pull` in all the plugin repos.

    date > $ADOTDIR/revert-info

    -antigen-echo-record |
        awk '$4 == "true" {print $1}' |
        sort -u |
        while read url; do
            echo "**** Pulling $url"

            local clone_dir="$(-antigen-get-clone-dir "$url")"
            if [[ -d "$clone_dir" ]]; then
                (echo -n "$clone_dir:"
                    cd "$clone_dir"
                    git rev-parse HEAD) >> $ADOTDIR/revert-info
            fi

            -antigen-ensure-repo "$url" --update --verbose

            echo
        done
}

antigen-revert () {
    if [[ -f $ADOTDIR/revert-info ]]; then
        cat $ADOTDIR/revert-info | sed '1!p' | while read line; do
            dir="$(echo "$line" | cut -d: -f1)"
            git --git-dir="$dir/.git" --work-tree="$dir" \
                checkout "$(echo "$line" | cut -d: -f2)" 2> /dev/null

        done

        echo "Reverted to state before running -update on $(
                cat $ADOTDIR/revert-info | sed -n 1p)."

    else 
        echo 'No revert information available. Cannot revert.' >&2
    fi


}

-antigen-get-clone-dir () {
    # Takes a repo url and gives out the path that this url needs to be cloned
    # to. Doesn't actually clone anything.
    echo -n $ADOTDIR/repos/

    if [[ "$1" == "https://github.com/sorin-ionescu/prezto.git" ]]; then
        # Prezto's directory *has* to be `.zprezto`.
        echo .zprezto

    else
        echo "$1" | sed \
            -e 's./.-SLASH-.g' \
            -e 's.:.-COLON-.g' \
            -e 's.|.-PIPE-.g'

    fi
}

-antigen-get-clone-url () {
    # Takes a repo's clone dir and gives out the repo's original url that was
    # used to create the given directory path.

    if [[ "$1" == ".zprezto" ]]; then
        # Prezto's (in `.zprezto`), is assumed to be from `sorin-ionescu`'s
        # remote.
        echo https://github.com/sorin-ionescu/prezto.git

    else
        echo "$1" | sed \
            -e "s:^$ADOTDIR/repos/::" \
            -e 's.-SLASH-./.g' \
            -e 's.-COLON-.:.g' \
            -e 's.-PIPE-.|.g'

    fi
}

-antigen-ensure-repo () {

    # Ensure that a clone exists for the given repo url and branch. If the first
    # argument is `--update` and if a clone already exists for the given repo
    # and branch, it is pull-ed, i.e., updated.

    # Argument defaults.
    # The url. No sane default for this, so just empty.
    local url=
    # Check if we have to update.
    local update=false
    # Verbose output.
    local verbose=false

    eval "$(-antigen-parse-args 'url ; update?, verbose?' "$@")"
    shift $#

    # Get the clone's directory as per the given repo url and branch.
    local clone_dir="$(-antigen-get-clone-dir $url)"

    # A temporary function wrapping the `git` command with repeated arguments.
    --plugin-git () {
        (cd "$clone_dir" && git --no-pager "$@")
    }

    # Clone if it doesn't already exist.
    if [[ ! -d $clone_dir ]]; then
        git clone --recursive "${url%|*}" "$clone_dir"
    elif $update; then
        # Save current revision.
        local old_rev="$(--plugin-git rev-parse HEAD)"
        # Pull changes if update requested.
        --plugin-git pull
        # Update submodules.
        --plugin-git submodule update --recursive
        # Get the new revision.
        local new_rev="$(--plugin-git rev-parse HEAD)"
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
        echo Updated from ${old_rev:0:7} to ${new_rev:0:7}.
        if $verbose; then
            --plugin-git log --oneline --reverse --no-merges --stat '@{1}..'
        fi
    fi

    # Remove the temporary git wrapper function.
    unfunction -- --plugin-git

}

-antigen-load () {

    local url="$1"
    local loc="$2"
    local btype="$3"
    local make_local_clone="$4"

    # The full location where the plugin is located.
    local location
    if $make_local_clone; then
        location="$(-antigen-get-clone-dir "$url")/$loc"
    else
        location="$url"
    fi

    if [[ $btype == theme ]]; then

        # Of course, if its a theme, the location would point to the script
        # file.
        source "$location"

    else

        # Source the plugin script.
        # FIXME: I don't know. Looks very very ugly. Needs a better
        # implementation once tests are ready.
        local script_loc="$(ls "$location" | grep '\.plugin\.zsh$' | head -n1)"

        if [[ -f $location/$script_loc ]]; then
            # If we have a `*.plugin.zsh`, source it.
            source "$location/$script_loc"

        elif [[ -f $location/init.zsh ]]; then
            # If we have a `init.zsh`
            if (( $+functions[pmodload] )); then
                # If pmodload is defined pmodload the module. Remove `modules/`
                # from loc to find module name.
                pmodload "${loc#modules/}"
            else
                # Otherwise source it.
                source "$location/init.zsh"
            fi

        elif ls "$location" | grep -l '\.zsh$' &> /dev/null; then
            # If there is no `*.plugin.zsh` file, source *all* the `*.zsh`
            # files.
            for script ($location/*.zsh(N)) source "$script"

        elif ls "$location" | grep -l '\.sh$' &> /dev/null; then
            # If there are no `*.zsh` files either, we look for and source any
            # `*.sh` files instead.
            for script ($location/*.sh(N)) source "$script"

        fi

        # Add to $fpath, for completion(s).
        fpath=($location $fpath)

    fi

}

# Update (with `git pull`) antigen itself.
# TODO: Once update is finished, show a summary of the new commits, as a kind of
# "what's new" message.
antigen-selfupdate () {
    ( cd $_ANTIGEN_INSTALL_DIR
        if [[ ! ( -d .git || -f .git ) ]]; then
            echo "Your copy of antigen doesn't appear to be a git clone. " \
                "The 'selfupdate' command cannot work in this case."
            return 1
        fi
        local head="$(git rev-parse --abbrev-ref HEAD)"
        if [[ $head == "HEAD" ]]; then
            # If current head is detached HEAD, checkout to master branch.
            git checkout master
        fi
        git pull
    )
}

antigen-cleanup () {

    # Cleanup unused repositories.

    local force=false
    if [[ $1 == --force ]]; then
        force=true
    fi

    if [[ ! -d "$ADOTDIR/repos" || -z "$(ls "$ADOTDIR/repos/")" ]]; then
        echo "You don't have any bundles."
        return 0
    fi

    # Find directores in ADOTDIR/repos, that are not in the bundles record.
    local unused_clones="$(comm -13 \
        <(-antigen-echo-record |
            awk '$4 == "true" {print $1}' |
            while read line; do
                -antigen-get-clone-dir "$line"
            done |
            sort -u) \
        <(ls -d "$ADOTDIR/repos/"* | sort -u))"

    if [[ -z $unused_clones ]]; then
        echo "You don't have any unidentified bundles."
        return 0
    fi

    echo 'You have clones for the following repos, but are not used.'
    echo "$unused_clones" |
        while read line; do
            -antigen-get-clone-url "$line"
        done |
        sed -e 's/^/  /' -e 's/|/, branch /'

    if $force || (echo -n '\nDelete them all? [y/N] '; read -q); then
        echo
        echo
        echo "$unused_clones" | while read line; do
            echo -n "Deleting clone for $(-antigen-get-clone-url "$line")..."
            rm -rf "$line"
            echo ' done.'
        done
    else
        echo
        echo Nothing deleted.
    fi
}

antigen-use () {
    if [[ $1 == oh-my-zsh ]]; then
        -antigen-use-oh-my-zsh
    elif [[ $1 == prezto ]]; then
        -antigen-use-prezto
    else
        echo 'Usage: antigen-use <library-name>' >&2
        echo 'Where <library-name> is any one of the following:' >&2
        echo ' * oh-my-zsh' >&2
        echo ' * prezto' >&2
        return 1
    fi
}

-antigen-use-oh-my-zsh () {
    if [[ -z "$ZSH" ]]; then
        export ZSH="$(-antigen-get-clone-dir "$ANTIGEN_DEFAULT_REPO_URL")"
    fi
    antigen-bundle --loc=lib
}

-antigen-use-prezto () {
    antigen-bundle sorin-ionescu/prezto
    export ZDOTDIR=$ADOTDIR/repos/
}

# For backwards compatibility.
antigen-lib () {
    -antigen-use-oh-my-zsh
    echo '`antigen-lib` is deprecated and will soon be removed.'
    echo 'Use `antigen-use oh-my-zsh` instead.'
}

# For backwards compatibility.
antigen-prezto-lib () {
    -antigen-use-prezto
    echo '`antigen-prezto-lib` is deprecated and will soon be removed.'
    echo 'Use `antigen-use prezto` instead.'
}

antigen-theme () {

    if [[ "$1" != */* && "$1" != --* ]]; then
        # The first argument is just a name of the plugin, to be picked up from
        # the default repo.
        local name="${1:-robbyrussell}"
        antigen-bundle --loc=themes/$name --btype=theme

    else
        antigen-bundle "$@" --btype=theme

    fi

}

antigen-apply () {

    # Initialize completion.
    local cdef

    # Load the compinit module. This will readefine the `compdef` function to
    # the one that actually initializes completions.
    autoload -U compinit
    compinit -i

    # Apply all `compinit`s that have been deferred.
    eval "$(for cdef in $__deferred_compdefs; do
                echo compdef $cdef
            done)"

    unset __deferred_compdefs

}

antigen-list () {
    # List all currently installed bundles.
    if [[ -z "$_ANTIGEN_BUNDLE_RECORD" ]]; then
        echo "You don't have any bundles." >&2
        return 1
    else
        -antigen-echo-record | sort -u
    fi
}

antigen-snapshot () {

    local snapshot_file="${1:-antigen-shapshot}"

    # The snapshot content lines are pairs of repo-url and git version hash, in
    # the form:
    #   <version-hash> <repo-url>
    local snapshot_content="$(-antigen-echo-record |
        grep 'true$' |
        sed 's/ .*$//' |
        sort -u |
        while read url; do
            local dir="$(-antigen-get-clone-dir "$url")"
            local version_hash="$(cd "$dir" && git rev-parse HEAD)"
            echo "$version_hash $url"
        done)"

    {
        # The first line in the snapshot file is for metadata, in the form:
        #   key='value'; key='value'; key='value';
        # Where `key`s are valid shell variable names.

        # Snapshot version. Has no relation to antigen version. If the snapshot
        # file format changes, this number can be incremented.
        echo -n "version='1';"

        # Snapshot creation date+time.
        echo -n " created_on='$(date)';"

        # Add a checksum with the md5 checksum of all the snapshot lines.
        chksum() { (md5sum; test $? = 127 && md5) 2>/dev/null | cut -d' ' -f1 }
        local checksum="$(echo "$snapshot_content" | chksum)"
        unset -f chksum;
        echo -n " checksum='${checksum%% *}';"

        # A newline after the metadata and then the snapshot lines.
        echo "\n$snapshot_content"

    } > "$snapshot_file"

}

antigen-restore () {

    if [[ $# == 0 ]]; then
        echo 'Please provide a snapshot file to restore from.' >&2
        return 1
    fi

    local snapshot_file="$1"

    # TODO: Before doing anything with the snapshot file, verify its checksum.
    # If it fails, notify this to the user and confirm if restore should
    # proceed.

    echo -n "Restoring from $snapshot_file..."

    sed -n '1!p' "$snapshot_file" |
        while read line; do

            local version_hash="${line%% *}"
            local url="${line##* }"
            local clone_dir="$(-antigen-get-clone-dir "$url")"

            if [[ ! -d $clone_dir ]]; then
                git clone "$url" "$clone_dir" &> /dev/null
            fi

            (cd "$clone_dir" && git checkout $version_hash) &> /dev/null

        done

    echo ' done.'
    echo 'Please open a new shell to get the restored changes.'
}

antigen-help () {
    cat <<EOF
Antigen is a plugin management system for zsh. It makes it easy to grab awesome
shell scripts and utilities, put up on github. For further details and complete
documentation, visit the project's page at 'http://antigen.sharats.me'.
EOF
}

# A syntax sugar to avoid the `-` when calling antigen commands. With this
# function, you can write `antigen-bundle` as `antigen bundle` and so on.
antigen () {
    local cmd="$1"
    if [[ -z "$cmd" ]]; then
        echo 'Antigen: Please give a command to run.' >&2
        return 1
    fi
    shift

    if functions "antigen-$cmd" > /dev/null; then
        "antigen-$cmd" "$@"
    else
        echo "Antigen: Unknown command: $cmd" >&2
    fi
}

-antigen-parse-args () {
    # An argument parsing functionality to parse arguments the *antigen* way :).
    # Takes one first argument (called spec), which dictates how to parse and
    # the rest of the arguments are parsed. Outputs a piece of valid shell code
    # that can be passed to `eval` inside a function which creates the arguments
    # and their values as local variables. Suggested use is to set the defaults
    # to all arguments first and then eval the output of this function.

    # Spec: Only long argument supported. No support for parsing short options.
    # The spec must have two sections, separated by a `;`.
    #       '<positional-arguments>;<keyword-only-arguments>'
    # Positional arguments are passed as just values, like `command a b`.
    # Keyword arguments are passed as a `--name=value` pair, like `command
    # --arg1=a --arg2=b`.

    # Each argument in the spec is separated by a `,`. Each keyword argument can
    # end in a `:` to specifiy that this argument wants a value, otherwise it
    # doesn't take a value. (The value in the output when the keyword argument
    # doesn't have a `:` is `true`).

    # Arguments in either section can end with a `?` (should come after `:`, if
    # both are present), means optional. FIXME: Not yet implemented.

    # See the test file, tests/arg-parser.t for (working) examples.

    local spec="$1"
    shift

    # Sanitize the spec
    spec="$(echo "$spec" | tr '\n' ' ' | sed 's/[[:space:]]//g')"

    local code=''

    --add-var () {
        test -z "$code" || code="$code\n"
        code="${code}local $1='$2'"
    }

    local positional_args="$(echo "$spec" | cut -d\; -f1)"
    local positional_args_count="$(echo $positional_args |
            awk -F, '{print NF}')"

    # Set spec values based on the positional arguments.
    local i=1
    while [[ -n $1 && $1 != --* ]]; do

        if (( $i > $positional_args_count )); then
            echo "Only $positional_args_count positional arguments allowed." >&2
            echo "Found at least one more: '$1'" >&2
            return
        fi

        local name_spec="$(echo "$positional_args" | cut -d, -f$i)"
        local name="${${name_spec%\?}%:}"
        local value="$1"

        if echo "$code" | grep -l "^local $name=" &> /dev/null; then
            echo "Argument '$name' repeated with the value '$value'". >&2
            return
        fi

        --add-var $name "$value"

        shift
        i=$(($i + 1))
    done

    local keyword_args="$(
            # Positional arguments can double up as keyword arguments too.
            echo "$positional_args" | tr , '\n' |
                while read line; do
                    if [[ $line == *\? ]]; then
                        echo "${line%?}:?"
                    else
                        echo "$line:"
                    fi
                done

            # Specified keyword arguments.
            echo "$spec" | cut -d\; -f2 | tr , '\n'
            )"
    local keyword_args_count="$(echo $keyword_args | awk -F, '{print NF}')"

    # Set spec values from keyword arguments, if any. The remaining arguments
    # are all assumed to be keyword arguments.
    while [[ $1 == --* ]]; do
        # Remove the `--` at the start.
        local arg="${1#--}"

        # Get the argument name and value.
        if [[ $arg != *=* ]]; then
            local name="$arg"
            local value=''
        else
            local name="${arg%\=*}"
            local value="${arg#*=}"
        fi

        if echo "$code" | grep -l "^local $name=" &> /dev/null; then
            echo "Argument '$name' repeated with the value '$value'". >&2
            return
        fi

        # The specification for this argument, used for validations.
        local arg_line="$(echo "$keyword_args" |
                            egrep "^$name:?\??" | head -n1)"

        # Validate argument and value.
        if [[ -z $arg_line ]]; then
            # This argument is not known to us.
            echo "Unknown argument '$name'." >&2
            return

        elif (echo "$arg_line" | grep -l ':' &> /dev/null) &&
                [[ -z $value ]]; then
            # This argument needs a value, but is not provided.
            echo "Required argument for '$name' not provided." >&2
            return

        elif (echo "$arg_line" | grep -vl ':' &> /dev/null) &&
                [[ -n $value ]]; then
            # This argument doesn't need a value, but is provided.
            echo "No argument required for '$name', but provided '$value'." >&2
            return

        fi

        if [[ -z $value ]]; then
            value=true
        fi

        --add-var "${name//-/_}" "$value"
        shift
    done

    echo "$code"

    unfunction -- --add-var

}

# Echo the bundle specs as in the record. The first line is not echoed since it
# is a blank line.
-antigen-echo-record () {
    echo "$_ANTIGEN_BUNDLE_RECORD" | sed -n '1!p'
}

-antigen-env-setup () {

    # Helper function: Same as `export $1=$2`, but will only happen if the name
    # specified by `$1` is not already set.
    -set-default () {
        local arg_name="$1"
        local arg_value="$2"
        eval "test -z \"\$$arg_name\" && export $arg_name='$arg_value'"
    }

    # Pre-startup initializations.
    -set-default ANTIGEN_DEFAULT_REPO_URL \
        https://github.com/robbyrussell/oh-my-zsh.git
    -set-default ADOTDIR $HOME/.antigen

    # Setup antigen's own completion.
    compdef _antigen antigen

    # Remove private functions.
    unfunction -- -set-default
}

# Setup antigen's autocompletion
_antigen () {
    compadd        \
        bundle     \
        bundles    \
        update     \
        revert     \
        list       \
        cleanup    \
        use        \
        selfupdate \
        theme      \
        apply      \
        snapshot   \
        restore    \
        help
}

-antigen-env-setup

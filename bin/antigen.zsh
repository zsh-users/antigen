# Antigen: A simple plugin manager for zsh
# Authors: Shrikant Sharat Kandula
#          and Contributors <https://github.com/zsh-users/antigen/contributors>
# Homepage: http://antigen.sharats.me
# License: MIT License <mitl.sharats.me>

# Each line in this string has the following entries separated by a space
# character.
# <repo-url>, <plugin-location>, <bundle-type>, <has-local-clone>
local _ANTIGEN_BUNDLE_RECORD=""
local _ANTIGEN_INSTALL_DIR="$(cd "$(dirname "$0")" && pwd)"
local _ANTIGEN_CACHE_ENABLED=${_ANTIGEN_CACHE_ENABLED:-true}
local _ANTIGEN_COMP_ENABLED=${_ANTIGEN_COMP_ENABLED:-true}
local _ANTIGEN_INTERACTIVE=${_ANTIGEN_INTERACTIVE_MODE:-false}
local _ANTIGEN_RESET_THEME_HOOKS=${_ANTIGEN_RESET_THEME_HOOKS:-true}
local _ANTIGEN_AUTODETECT_CONFIG_CHANGES=${_ANTIGEN_AUTODETECT_CONFIG_CHANGES:-true}
local _ANTIGEN_FORCE_RESET_COMPDUMP=${_ANTIGEN_FORCE_RESET_COMPDUMP:-true}

# Do not load anything if git is not available.
if ! which git &> /dev/null; then
    echo 'Antigen: Please install git to use Antigen.' >&2
    return 1
fi

# Used to defer compinit/compdef
typeset -a __deferred_compdefs
compdef () { __deferred_compdefs=($__deferred_compdefs "$*") }

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
-antigen-bundle-short-name () {
    echo "$@" | sed -E "s|.*/(.*/.*)$|\1|"|sed -E "s|\.git$||g"
}
-antigen-get-clone-dir () {
    # Takes a repo url and gives out the path that this url needs to be cloned
    # to. Doesn't actually clone anything.
    echo -n $ADOTDIR/repos/

    if [[ "$1" == "https://github.com/sorin-ionescu/prezto.git" ]]; then
        # Prezto's directory *has* to be `.zprezto`.
        echo .zprezto
    else
        local url="${1}"
        url=${url//\//-SLASH-}
        url=${url//\:/-COLON-}
        path=${url//\|/-PIPE-}
        echo "$path"
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
        local _path="${1}"
        _path=${_path//^\$ADOTDIR\/repos\/}
        _path=${_path//-SLASH-/\/}
        _path=${_path//-COLON-/\:}
        url=${_path//-PIPE-/\|}
        echo "$url"
    fi
}
# Updates _ANTIGEN_INTERACTIVE environment variable to reflect
# if antigen is running in an interactive shell or from sourcing.
#
# This function check ZSH_EVAL_CONTEXT if available or functrace otherwise.
# If _ANTIGEN_INTERACTIVE is set to true it won't re-check again.
#
# Usage
#   -antigen-interactive-mode
#
# Returns
#   Either true or false depending if we are running in interactive mode
-antigen-interactive-mode () {
    # Check if we are in any way running in interactive mode
    if [[ $_ANTIGEN_INTERACTIVE == false ]]; then
        if [[ "$ZSH_EVAL_CONTEXT" =~ "toplevel:*" ]]; then
            _ANTIGEN_INTERACTIVE=true
        elif [[ -z "$ZSH_EVAL_CONTEXT" ]]; then
            zmodload zsh/parameter
            if [[ "${functrace[$#functrace]%:*}" == "zsh" ]]; then
                _ANTIGEN_INTERACTIVE=true
            fi
        fi
    fi

    return _ANTIGEN_INTERACTIVE
}
-antigen-load-list () {
    local url="$1"
    local loc="$2"
    local make_local_clone="$3"

    # The full location where the plugin is located.
    local location="$url/"
    if $make_local_clone; then
        location="$(-antigen-get-clone-dir "$url")/"
    fi

    if [[ $loc != "/" ]]; then
        location="$location$loc"
    fi

    if [[ ! -f "$location" && ! -d "$location" ]]; then
        return 1
    fi

    if [[ -f "$location" ]]; then
        echo "$location"
        return
    fi

    # If we have a `*.plugin.zsh`, source it.
    local script_plugin
    script_plugin=($location/*.plugin.zsh(N[1]))
    if [[ -f "$script_plugin" ]]; then
        echo "$script_plugin"
        return
    fi

    # Otherwise source init.
    if [[ -f $location/init.zsh ]]; then
        echo "$location/init.zsh"
        return
    fi

    # If there is no `*.plugin.zsh` file, source *all* the `*.zsh` files.
    local bundle_files
    bundle_files=($location/*.zsh(N) $location/*.sh(N))
    if [[ $#bundle_files -gt 0 ]]; then
        echo "${(j:\n:)bundle_files}"
        return
    fi
}
-antigen-parse-bundle () {
  # Bundle spec arguments' default values.
  local url="$ANTIGEN_DEFAULT_REPO_URL"
  local loc=/
  local branch=
  local no_local_clone=false
  local btype=plugin

  # Parse the given arguments. (Will overwrite the above values).
  eval "$(-antigen-parse-args "$@")"

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

  # Bundle spec arguments' default values.
  echo "local url=\""$url\""
        local loc=\""$loc\""
        local branch=\""$branch\""
        local make_local_clone="$make_local_clone"
        local btype=\""$btype\""
        "
}
# Forces to reset zcompdump file
# Removes $ANTIGEN_COMPDUMPFILE as ${ZDOTDIR:-$HOME}/.zcompdump
# Set $_ANTIGEN_FORCE_RESET_COMPDUMP to true to do so
-antigen-reset-compdump () {
    if [[ $_ANTIGEN_FORCE_RESET_COMPDUMP == true && -f $ANTIGEN_COMPDUMPFILE ]]; then
        rm $ANTIGEN_COMPDUMPFILE
    fi
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
    if [[ ! -d $ADOTDIR ]]; then
        mkdir -p $ADOTDIR
    fi
    -set-default _ANTIGEN_LOG_PATH "$ADOTDIR/antigen.log"
    -set-default ANTIGEN_COMPDUMPFILE "${ZDOTDIR:-$HOME}/.zcompdump"

    # Setup antigen's own completion.
    autoload -Uz compinit
    if $_ANTIGEN_COMP_ENABLED; then
        compinit -C
        compdef _antigen antigen
    fi

    # Remove private functions.
    unfunction -- -set-default

}
-antigen-load () {
  local url="$1"
  local loc="$2"
  local make_local_clone="$3"
  local btype="$4"
  local src

  for src in $(-antigen-load-list "$url" "$loc" "$make_local_clone"); do
      if [[ -d "$src" ]]; then
          if (( ! ${fpath[(I)$location]} )); then
              fpath=($location $fpath)
          fi
      else
          # Hack away local variables. See https://github.com/zsh-users/antigen/issues/122
          # This is needed to seek-and-destroy local variable definitions *outside*
          # function-contexts. This is done in this particular way *only* for
          # interactive bundle/theme loading, for static loading -99.9% of the time-
          # eval and subshells are not needed.
          if [[ "$btype" == "theme" ]]; then
              eval "$(cat $src | sed -Ee '/\{$/,/^\}/!{
                      s/^local //
                  }')"
          else
              source "$src"
          fi
      fi
  done

  local location
  if $make_local_clone; then
      location="$(-antigen-get-clone-dir "$url")/$loc"
  else
      location="$url/"
  fi
  # Add to $fpath, for completion(s), if not in there already
  if (( ! ${fpath[(I)$location]} )); then
     fpath=($location $fpath)
  fi
}
-antigen-parse-args () {
    local key
    local value
    local index=0

    while [[ $# -gt 0 ]]; do
        argkey="${1%\=*}"
        key="${argkey//--/}"
        value="${1#*=}"

        case "$argkey" in
            --url|--loc|--branch|--btype)
                if [[ "$value" == "$argkey" ]]; then
                    echo "Required argument for '$key' not provided."
                else
                    echo "local $key='$value'"
                fi
            ;;
            --no-local-clone)
                echo "local no_local_clone='true'"
            ;;
            --*)
                echo "Unknown argument '$key'."
            ;;
            *)
                value=$key
                case $index in
                    0) key=url ;;
                    1) key=loc ;;
                esac
                let index+=1
                echo "local $key='$value'"
            ;;
        esac

        shift
    done
}
-antigen-use-oh-my-zsh () {
    if [[ -z "$ZSH" ]]; then
        export ZSH="$(-antigen-get-clone-dir "$ANTIGEN_DEFAULT_REPO_URL")"
    fi
    if [[ -z "$ZSH_CACHE_DIR" ]]; then
        export ZSH_CACHE_DIR="$ZSH/cache/"
    fi
    antigen-bundle --loc=lib
}
-antigen-use-prezto () {
    _zdotdir_set=${+parameters[ZDOTDIR]}
    if (( _zdotdir_set )); then
        _old_zdotdir=$ZDOTDIR
    fi
    export ZDOTDIR=$ADOTDIR/repos/

    antigen-bundle sorin-ionescu/prezto
}
# Initialize completion
antigen-apply () {
    # We need to check for interactivity because if cache is configured
    # antigen-apply is called by zcache-done, which calls -antigen-reset-compdump
    # as well, so here we avoid to run -antigen-reset-compdump twice.
    #
    # We do not want to always call -antigen-reset-compdump, but only when
    # - cache is reset
    # - user issues antigen-apply command
    # Here we are taking care of antigen-apply command. See zcache-done function
    # for the former case.
    -antigen-interactive-mode
    if [[ $_ANTIGEN_INTERACTIVE == true ]]; then
        # Force zcompdump reset
        -antigen-reset-compdump
    fi

    # Load the compinit module. This will readefine the `compdef` function to
    # the one that actually initializes completions.
    autoload -U compinit
    compinit -i -d $ANTIGEN_COMPDUMPFILE

    # Apply all `compinit`s that have been deferred.
    local cdef
    for cdef in "${__deferred_compdefs[@]}"; do
        compdef "$cdef"
    done

    unset __deferred_compdefs

    if (( _zdotdir_set )); then
        ZDOTDIR=$_old_zdotdir
    else
        unset ZDOTDIR
        unset _old_zdotdir
    fi
    unset _zdotdir_set
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
    
    if [[ -z "$1" ]]; then
        echo "Must provide a bundle url or name."
        return 1
    fi

    eval "$(-antigen-parse-bundle "$@")"

   # Ensure a clone exists for this repo, if needed.
    if $make_local_clone; then
        if ! -antigen-ensure-repo "$url"; then
            # Return immediately if there is an error cloning
            return 1
        fi
    fi

    # Load the plugin.
    -antigen-load "$url" "$loc" "$make_local_clone" "$btype"

    # Add it to the record.
    local bundle_record="$url $loc $btype $make_local_clone"
    if [[ ! $_ANTIGEN_BUNDLE_RECORD =~ "$bundle_record" ]]; then
        # TODO Use array instead of string
        _ANTIGEN_BUNDLE_RECORD="$_ANTIGEN_BUNDLE_RECORD\n$bundle_record"
    fi
}
antigen-cleanup () {

    # Cleanup unused repositories.

    local force=false
    if [[ $1 == --force ]]; then
        force=true
    fi

    if [[ ! -d "$ADOTDIR/repos" || -z "$(\ls "$ADOTDIR/repos/")" ]]; then
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
        <(\ls -d "$ADOTDIR/repos/"* | sort -u))"

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
# Echo the bundle specs as in the record. The first line is not echoed since it
# is a blank line.
-antigen-echo-record () {
    echo "$_ANTIGEN_BUNDLE_RECORD" | sed -n '1!p'
}
antigen-help () {
    cat <<EOF
Antigen is a plugin management system for zsh. It makes it easy to grab awesome
shell scripts and utilities, put up on github. For further details and complete
documentation, visit the project's page at 'http://antigen.sharats.me'.

EOF
    antigen-version
}
# For backwards compatibility.
antigen-lib () {
    -antigen-use-oh-my-zsh
    echo '`antigen-lib` is deprecated and will soon be removed.'
    echo 'Use `antigen-use oh-my-zsh` instead.'
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
# For backwards compatibility.
antigen-prezto-lib () {
    -antigen-use-prezto
    echo '`antigen-prezto-lib` is deprecated and will soon be removed.'
    echo 'Use `antigen-use prezto` instead.'
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
antigen-revert () {
    if [[ -f $ADOTDIR/revert-info ]]; then
        cat $ADOTDIR/revert-info | sed -n '1!p' | while read line; do
            local dir="$(echo "$line" | cut -d: -f1)"
            git --git-dir="$dir/.git" --work-tree="$dir" \
                checkout "$(echo "$line" | cut -d: -f2)" 2> /dev/null
        done

        echo "Reverted to state before running -update on $(
                cat $ADOTDIR/revert-info | sed -n '1p')."

    else
        echo 'No revert information available. Cannot revert.' >&2
        return 1
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
        $_ANTIGEN_CACHE_ENABLED && antigen-cache-reset &>> /dev/null
    )
}
antigen-snapshot () {

    local snapshot_file="${1:-antigen-shapshot}"

    # The snapshot content lines are pairs of repo-url and git version hash, in
    # the form:
    #   <version-hash> <repo-url>
    local snapshot_content="$(
        -antigen-echo-record |
        awk '$4 == "true" {print $1}' |
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
antigen-theme () {
    if [[ $_ANTIGEN_RESET_THEME_HOOKS == true ]]; then
        -antigen-theme-reset-hooks
    fi

    if [[ "$1" != */* && "$1" != --* ]]; then
        # The first argument is just a name of the plugin, to be picked up from
        # the default repo.
        local name="${1:-robbyrussell}"
        antigen-bundle --loc=themes/$name --btype=theme

    else
        antigen-bundle "$@" --btype=theme

    fi
}

-antigen-theme-reset-hooks () {
    # This is only needed on interactive mode
    autoload -U add-zsh-hook is-at-least
    local hook
    for hook in chpwd precmd preexec periodic; do
        # add-zsh-hook's -D option was introduced first in 4.3.6-dev and
        # 4.3.7 first stable, 4.3.5 and below may experiment minor issues
        # while switching themes interactively.
        if is-at-least 4.3.7; then
            add-zsh-hook -D "${hook}" "prompt_*"
            add-zsh-hook -D "${hook}" "*_${hook}" # common in omz themes 
        fi
        add-zsh-hook -d "${hook}" "vcs_info"  # common in omz themes
    done
}
antigen-update () {
    # Update your bundles, i.e., `git pull` in all the plugin repos.
    date >! $ADOTDIR/revert-info

    # Clear log
    :> $_ANTIGEN_LOG_PATH

    -antigen-echo-record |
        awk '$4 == "true" {print $1}' |
        sort -u |
        while read url; do
            local clone_dir="$(-antigen-get-clone-dir "$url")"
            if [[ -d "$clone_dir" ]]; then
                (echo -n "$clone_dir:"
                    cd "$clone_dir"
                    git rev-parse HEAD) >> $ADOTDIR/revert-info
            fi

            # update=true verbose=true
            -antigen-ensure-repo "$url" true true
        done
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
antigen-version () {
    echo "Antigen v1.2.3"
}
#compdef _antigen
# Setup antigen's autocompletion
_antigen () {
  local -a _1st_arguments
  _1st_arguments=(
    'bundle:Install and load the given plugin'
    'bundles:Bulk define bundles'
    'update:Update all bundles'
    'revert:Revert the state of all bundles to how they were before the last antigen update'
    'list:List out the currently loaded bundles'
    'cleanup:Clean up the clones of repos which are not used by any bundles currently loaded'
    'use:Load any (supported) zsh pre-packaged framework'
    'theme:Switch the prompt theme'
    'apply:Load all bundle completions'
    'snapshot:Create a snapshot of all the active clones'
    'restore:Restore the bundles state as specified in the snapshot'
    'selfupdate:Update antigen itself'
  );

  if $_ANTIGEN_CACHE_ENABLED; then
      _1st_arguments+=(
      'reset:Clears antigen cache'
      'init:Load Antigen configuration from file'
      )
  fi

  _1st_arguments+=(
  'help:Show this message'
  'version:Display Antigen version'
  )

  __bundle() {
    _arguments \
      '--loc[Path to the location <path-to/location>]' \
      '--url[Path to the repository <github-account/repository>]' \
      '--branch[Git branch name]' \
      '--no-local-clone[Do not create a clone]' \
      '--btype[Indicates whether the bundle is a theme or a simple plugin]'
  }

  __cleanup() {
    _arguments \
      '--force[Do not ask for confirmation]'
  }

  _arguments '*:: :->command'

  if (( CURRENT == 1 )); then
    _describe -t commands "antigen command" _1st_arguments
    return
  fi

  local -a _command_args
  case "$words[1]" in
    bundle)
      __bundle
      ;;
    use)
      compadd "$@" "oh-my-zsh" "prezto"
      ;;
    cleanup)
      __cleanup
      ;;
  esac
}

-antigen-env-setup
# Clears $0 and ${0} references from cached sources.
#
# This is needed otherwise plugins trying to source from a different path
# will break as those are now located at $_ZCACHE_PAYLOAD_PATH
#
# This does avoid function-context $0 references.
#
# This does handles the following patterns:
#   $0
#   ${0}
#   ${funcsourcetrace[1]%:*}
#   ${(%):-%N}
#   ${(%):-%x}
#
# Usage
#   -zcache-process-source "/path/to/source" ["theme"|"plugin"]
#
# Returns
#   Returns the cached sources without $0 and ${0} references
-zcache-process-source () {
    local src="$1"
    local btype="$2"

    # Removes $0 references globally (exclusively)
    local globals_only='/\{$/,/^\}/!{
                /\$.?0/i\'$'\n''__ZCACHE_FILE_PATH="'$src'"
                s/\$(.?)0(.?)/\$\1__ZCACHE_FILE_PATH\2/
    }'

    # Removes funcsourcetrace, and ${%} references globally
    local globals='/.*/{
        /\$.?(funcsourcetrace\[1\]\%\:\*|\(\%\)\:\-\%(N|x))/i\'$'\n''__ZCACHE_FILE_PATH="'$src'"
        s/\$(.?)(funcsourcetrace\[1\]\%\:\*|\(\%\)\:\-\%(N|x))(.?)/\$\1__ZCACHE_FILE_PATH\4/
    }'

    # Removes `local` from temes globally
    local sed_regexp_themes=''
    if [[ "$btype" == "theme" ]]; then
        themes='/\{$/,/^\}/!{
            s/^local //
        }'
        sed_regexp_themes="-e "$themes
    fi

	cat "$src" | sed -E -e $globals -e $globals_only $sed_regexp_themes
}

# Generates cache from listed bundles.
#
# Iterates over _ZCACHE_BUNDLES and install them (if needed) then join all needed
# sources into one, this is done through -antigen-load-list.
# Result is stored in _ZCACHE_PAYLOAD_PATH. Loaded bundles and metadata is stored
# in _ZCACHE_META_PATH.
#
# _ANTIGEN_BUNDLE_RECORD and fpath is stored in cache.
#
# Usage
#   -zcache-generate-cache
#   Uses _ZCACHE_BUNDLES (array)
#
# Returns
#   Nothing. Generates _ZCACHE_META_PATH and _ZCACHE_PAYLOAD_PATH
-zcache-generate-cache () {
    local -aU _extensions_paths
    local -a _bundles_meta
    local _payload=''
    local location

    _payload+="#-- START ZCACHE GENERATED FILE\NL"
    _payload+="#-- GENERATED: $(date)\NL"
    _payload+='#-- ANTIGEN v1.2.3\NL'
    for bundle in $_ZCACHE_BUNDLES; do
        # -antigen-load-list "$url" "$loc" "$make_local_clone"
        eval "$(-antigen-parse-bundle ${=bundle})"
        _bundles_meta+=("$url $loc $btype $make_local_clone $branch")

        if $make_local_clone; then
            -antigen-ensure-repo "$url"
        fi

        -antigen-load-list "$url" "$loc" "$make_local_clone" | while read line; do
            if [[ -f "$line" ]]; then
                _payload+="#-- SOURCE: $line\NL"
                _payload+=$(-zcache-process-source "$line" "$btype")
                _payload+="\NL;#-- END SOURCE\NL"
            fi
        done

        if $make_local_clone; then
            location="$(-antigen-get-clone-dir "$url")/$loc"
        else
            location="$url/"
        fi

        if [[ -d "$location" ]]; then
            _extensions_paths+=($location)
        fi
    done

    _payload+="fpath+=(${_extensions_paths[@]})\NL"
    _payload+="unset __ZCACHE_FILE_PATH\NL"
    # \NL (\n) prefix is for backward compatibility
    _payload+="export _ANTIGEN_BUNDLE_RECORD=\"\NL${(j:\NL:)_bundles_meta}\"\NL"
    _payload+="export _ZCACHE_CACHE_LOADED=true\NL"
    _payload+="export _ZCACHE_CACHE_VERSION=v1.2.3\NL"
    _payload+="#-- END ZCACHE GENERATED FILE\NL"

    echo -E $_payload | sed 's/\\NL/\'$'\n/g' >! "$_ZCACHE_PAYLOAD_PATH"
    echo "$_ZCACHE_BUNDLES" >! "$_ZCACHE_BUNDLES_PATH"
}

# Generic hook function for various antigen-* commands.
#
# The function is used to defer the bundling performed by commands such as
# bundle, theme and init. This way we can record all the bundled plugins and
# install/source/cache in one single step.
#
# Usage
#   -zcache-antigen-hook <arguments>
#
# Returns
#   Nothing. Updates _ZACHE_BUNDLES array.
-zcache-antigen-hook () {
    local cmd="$1"
    local subcommand="$2"

    if [[ "$cmd" == "antigen" ]]; then
        if [[ ! -z "$subcommand" ]]; then
            shift 2
        fi
        -zcache-antigen $subcommand $@
    elif [[ "$cmd" == "antigen-bundles" ]]; then
        grep '^[[:space:]]*[^[:space:]#]' | while read line; do
            _ZCACHE_BUNDLES+=("${(j: :)line//\#*/}")
        done
    elif [[ "$cmd" == "antigen-bundle" ]]; then
        shift 1
        _ZCACHE_BUNDLES+=("${(j: :)@}")
    elif [[ "$cmd" == "antigen-apply" ]]; then
        zcache-done
        antigen-apply
    else
        shift 1
        -zcache-$cmd $@
    fi
}

# Unhook antigen functions to be able to call antigen commands normally.
#
# After generating and loading of cache there is no need for defered command
# calls, so we are leaving antigen as it was before zcache was loaded.
#
# Afected functions are antigen, antigen-bundle and antigen-apply.
#
# See -zcache-hook-antigen
#
# Usage
#   -zcache-unhook-antigen
#
# Returns
#   Nothing
-zcache-unhook-antigen () {
    for function in ${(Mok)functions:#antigen*}; do
        eval "function $(functions -- -zcache-$function | sed 's/-zcache-//')"
    done
}

# Hooks various antigen functions to be able to defer command execution.
#
# To be able to record and cache multiple bundles when antigen runs we are
# hooking into multiple antigen commands, either deferring it's execution
# or dropping it.
#
# Afected functions are antigen* (key ones are antigen, antigen-bundle,
# antigen-apply).
#
# See -zcache-unhook-antigen
#
# Usage
#   -zcache-hook-antigen
#
# Returns
#   Nothing
-zcache-hook-antigen () {
    for function in ${(Mok)functions:#antigen*}; do
        eval "function -zcache-$(functions -- $function)"
        $function () { -zcache-antigen-hook $0 "$@" }
    done
}

# Determines if cache is up-to-date with antigen configuration
#
# Usage
#   -zcache-cache-invalidated
#
# Returns
#   Either true or false depending if cache is up to date
-zcache-cache-invalidated () {
    [[ $_ANTIGEN_AUTODETECT_CONFIG_CHANGES == true && ! -f $_ZCACHE_BUNDLES_PATH || $(cat $_ZCACHE_BUNDLES_PATH) != "$_ZCACHE_BUNDLES" ]];
}
export _ZCACHE_PATH="${_ANTIGEN_CACHE_PATH:-$ADOTDIR/.cache}"
export _ZCACHE_PAYLOAD_PATH="$_ZCACHE_PATH/.zcache-payload"
export _ZCACHE_BUNDLES_PATH="$_ZCACHE_PATH/.zcache-bundles"
export _ZCACHE_EXTENSION_CLEAN_FUNCTIONS="${_ZCACHE_EXTENSION_CLEAN_FUNCTIONS:-true}"
export _ZCACHE_EXTENSION_ACTIVE=false
local -a _ZCACHE_BUNDLES

# Starts zcache execution.
#
# Hooks into various antigen commands to be able to record and cache multiple
# bundles, themes and plugins.
#
# Usage
#   zcache-start
#
# Returns
#   Nothing
zcache-start () {
    if [[ $_ZCACHE_EXTENSION_ACTIVE == true ]]; then
        return
    fi

    [[ ! -d "$_ZCACHE_PATH" ]] && mkdir -p "$_ZCACHE_PATH"
    -zcache-hook-antigen

    # Avoid running in interactive mode. This handles an specific case
    # where antigen is sourced from file (eval context) but antigen commands
    # are issued from toplevel (interactively).
    zle -N zle-line-init zcache-done
    _ZCACHE_EXTENSION_ACTIVE=true
}

# Generates (if needed) and loads cache.
#
# Unhooks antigen commands and removes various zcache functions.
#
# Usage
#   zcache-done
#
# Returns
#   Nothing
zcache-done () {
    if [[ -z $_ZCACHE_EXTENSION_ACTIVE ]]; then
        return 1
    fi
    unset _ZCACHE_EXTENSION_ACTIVE
    
    -zcache-unhook-antigen
    
    # Avoids seg fault on zsh 4.3.5
    if [[ ${#_ZCACHE_BUNDLES} -gt 0 ]]; then
        if ! zcache-cache-exists || -zcache-cache-invalidated; then
            -zcache-generate-cache
            -antigen-reset-compdump
        fi
        
        zcache-load-cache
    fi

    if [[ $_ZCACHE_EXTENSION_CLEAN_FUNCTIONS == true ]]; then
        unfunction -- ${(Mok)functions:#-zcache*}
    fi

    eval "function -zcache-$(functions -- antigen-update)"
    antigen-update () {
        -zcache-antigen-update "$@"
        antigen-reset
    }
    
    unset _ZCACHE_BUNDLES
}

# Returns true if cache is available.
#
# Usage
#   zcache-cache-exists
#
# Returns
#   Either 1 if cache exists or 0 if it does not exists
zcache-cache-exists () {
    [[ -f "$_ZCACHE_PAYLOAD_PATH" ]]
}

# Load bundles from cache (sourcing it)
#
# This function does not check if cache is available, do use zcache-cache-exists.
#
# Usage
#   zcache-load-cache
#
# Returns
#   Nothing
zcache-load-cache () {
    source "$_ZCACHE_PAYLOAD_PATH"
}

# Removes cache payload and metadata if available
#
# Usage
#   zcache-cache-reset
#
# Returns
#   Nothing
antigen-reset () {
    -zcache-remove-path () { [[ -f "$1" ]] && rm "$1" }
    -zcache-remove-path "$_ZCACHE_PAYLOAD_PATH"
    -zcache-remove-path "$_ZCACHE_BUNDLES_PATH"
    unfunction -- -zcache-remove-path
    echo 'Done. Please open a new shell to see the changes.'
}

# Deprecated for antigen-reset command
#
# Usage
#   zcache-cache-reset
#
# Returns
#   Nothing
antigen-cache-reset () {
    echo 'Deprecated in favor of antigen reset.'
    antigen-reset
}

# Antigen command to load antigen configuration
#
# This method is slighlty more performing than using various antigen-* methods.
#
# Usage
#   Referencing an antigen configuration file:
#
#       antigen-init "/path/to/antigenrc"
#
#   or using HEREDOCS:
#
#       antigen-init <<EOBUNDLES
#           antigen use oh-my-zsh
#
#           antigen bundle zsh/bundle
#           antigen bundle zsh/example
#
#           antigen theme zsh/theme
#
#           antigen apply
#       EOBUNDLES
#
# Returns
#   Nothing
antigen-init () {
    if zcache-cache-exists; then
        # Force cache to load - this does skip -zcache-cache-invalidate
        _ZCACHE_BUNDLES=$(cat $_ZCACHE_BUNDLES_PATH)
        zcache-done
        return
    fi

    local src="$1"
    if [[ -f "$src" ]]; then
        source "$src"
        return
    fi

    grep '^[[:space:]]*[^[:space:]#]' | while read line; do
        eval $line
    done
}

-antigen-interactive-mode # Updates _ANTIGEN_INTERACTIVE
# Refusing to run in interactive mode
if [[ $_ANTIGEN_CACHE_ENABLED == true ]]; then
    if [[ $_ANTIGEN_INTERACTIVE == false ]]; then
        zcache-start
    fi
else    
    # Disable antigen-init and antigen-reset commands if cache is disabled
    # and running in interactive modes
    unfunction -- antigen-init antigen-reset antigen-cache-reset
fi

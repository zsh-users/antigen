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

# Do not load anything if git is no available.
if ! which git &> /dev/null; then
    echo 'Antigen: Please install git to use Antigen.' >&2
    return 1
fi

# Used to defer compinit/compdef
typeset -a __deferred_compdefs
compdef () { __deferred_compdefs=($__deferred_compdefs "$*") }

-antigen-parse-bundle () {
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

  # Bundle spec arguments' default values.
  echo "local url=\""$url\""
        local loc=\""$loc\""
        local branch=\""$branch\""
        local make_local_clone="$make_local_clone"
        local btype=\""$btype\""
        "
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
    
    # Add it to the record.
    _ANTIGEN_BUNDLE_RECORD="$_ANTIGEN_BUNDLE_RECORD\n$url $loc $btype"
    _ANTIGEN_BUNDLE_RECORD="$_ANTIGEN_BUNDLE_RECORD $make_local_clone"

    # Ensure a clone exists for this repo, if needed.
    if $make_local_clone; then
        -antigen-ensure-repo "$url"
    fi

    # Load the plugin.
    -antigen-load "$url" "$loc" "$make_local_clone"

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

-antigen-bundle-short-name () {
    echo "$@" | sed -E "s|.*/(.*/.*).git.*$|\1|"
}

-antigen-ensure-repo () {

    # Ensure that a clone exists for the given repo url and branch. If the first
    # This function expects three arguments in order:
    # * 'url=<url>'
    # * 'update=true|false'
    # * 'verbose=true|false'
    # argument is `update` and if a clone already exists for the given repo
    # and branch, it is pull-ed, i.e., updated.

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
        local branch=master
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

}

-antigen-load-list () {
  local url="$1"
  local loc="$2"
  local make_local_clone="$3"
  local sources=''

  # The full location where the plugin is located.
  local location
  if $make_local_clone; then
      location="$(-antigen-get-clone-dir "$url")/"
  else
      location="$url/"
  fi

  [[ $loc != "/" ]] && location="$location$loc"

  if [[ ! -f "$location" && ! -d "$location" ]]; then
      return 1
  fi

  if [[ -f "$location" ]]; then
      sources="$location"
  else

      # Source the plugin script.
      # FIXME: I don't know. Looks very very ugly. Needs a better
      # implementation once tests are ready.
      local script_loc="$(ls "$location" | grep '\.plugin\.zsh$' | head -n1)"

      if [[ -f $location/$script_loc ]]; then
          # If we have a `*.plugin.zsh`, source it.
          sources="$location/$script_loc"

      elif [[ -f $location/init.zsh ]]; then
          # Otherwise source it.
          sources="$location/init.zsh"

      elif ls "$location" | grep -l '\.zsh$' &> /dev/null; then
          # If there is no `*.plugin.zsh` file, source *all* the `*.zsh`
          # files.

          for script ($location/*.zsh(N)) {
            sources="$sources\n$script"
          }

      elif ls "$location" | grep -l '\.sh$' &> /dev/null; then
          # If there are no `*.zsh` files either, we look for and source any
          # `*.sh` files instead.
          for script ($location/*.sh(N)) {
            sources="$sources\n$script"
          }
      fi
  fi

  echo "$sources"
}

-antigen-load () {
  local url="$1"
  local loc="$2"
  local make_local_clone="$3"
  local src

  for src in $(-antigen-load-list "$url" "$loc" "$make_local_clone"); do
      if [[ -d "$src" ]]; then
          if (( ! ${fpath[(I)$location]} )); then
              fpath=($location $fpath)
          fi
      else
          source "$src"
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
    if [[ -z $ANTIGEN_COMPDUMPFILE ]]; then
        compinit -i
    else
        compinit -i -d $ANTIGEN_COMPDUMPFILE
    fi

    # Apply all `compinit`s that have been deferred.
    eval "$(for cdef in $__deferred_compdefs; do
                echo compdef $cdef
            done)"

    unset __deferred_compdefs

    if (( _zdotdir_set )); then
        ZDOTDIR=$_old_zdotdir
    else
        unset ZDOTDIR
        unset _old_zdotdir
    fi;
    unset _zdotdir_set
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
    antigen-version
}

antigen-version () {
    echo "Antigen v1.1.4"
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
    -set-default _ANTIGEN_LOG_PATH "$ADOTDIR/antigen.log"

    # Setup antigen's own completion.
    autoload -Uz compinit
    if $_ANTIGEN_COMP_ENABLED; then
        compinit -C
        compdef _antigen antigen
    fi

    # Remove private functions.
    unfunction -- -set-default

}

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
      'cache-reset:Clears bundle cache'
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
export _ZCACHE_PATH="${_ANTIGEN_CACHE_PATH:-$ADOTDIR/.cache}"
export _ZCACHE_PAYLOAD_PATH="$_ZCACHE_PATH/.zcache-payload"
export _ZCACHE_META_PATH="$_ZCACHE_PATH/.zcache-meta"
export _ZCACHE_EXTENSION_ACTIVE=false
local -a _ZCACHE_BUNDLES

# Clears $0 and ${0} references from cached sources.
#
# This is needed otherwise plugins trying to source from a different path
# will break as those are now located at $_ZCACHE_PAYLOAD_PATH
#
# This does avoid function-context $0 references.
#
# Usage
#   -zcache-process-source "/path/to/source"
#
# Returns
#   Returns the cached sources without $0 and ${0} references
-zcache-process-source () {
    cat "$1" | sed -Ee '/\{$/,/^\}/!{
            /\$.?0/i\'$'\n''__ZCACHE_FILE_PATH="'$1'"
            s/\$(.?)0/\$\1__ZCACHE_FILE_PATH/
        }'
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
    _payload+='#-- ANTIGEN v1.1.4\NL'
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
                _payload+=$(-zcache-process-source "$line")
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
    _payload+="export _ZCACHE_CACHE_VERSION=v1.1.4\NL"
    _payload+="#-- END ZCACHE GENERATED FILE\NL"

    echo -E $_payload | sed 's/\\NL/\'$'\n/g' >>! $_ZCACHE_PAYLOAD_PATH
    echo "${(j:\n:)_bundles_meta}" >>! $_ZCACHE_META_PATH
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
    elif [[ "$cmd" == "antigen-bundle" ]]; then
        shift 1
        _ZCACHE_BUNDLES+=("${(j: :)@}")
    elif [[ "$cmd" == "antigen-apply" ]]; then
        zcache-done
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
# Afected functions are antigen, antigen-bundle and antigen-apply.
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

# Updates _ANTIGEN_INTERACTIVE environment variable to reflect
# if antigen is running in an interactive shell or from sourcing.
#
# This function check ZSH_EVAL_CONTEXT if available or functrace otherwise.
# If _ANTIGEN_INTERACTIVE is set to true it won't re-check again.
#
# Usage
#   -zcache-interactive-mode
#
# Returns
#   Either true or false depending if we are running in interactive mode
-zcache-interactive-mode () {
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
    if [[ ${#_ZCACHE_BUNDLES} -gt 0 ]]; then
        ! zcache-cache-exists && -zcache-generate-cache
        zcache-load-cache
    fi
    
    unfunction -- ${(Mok)functions:#-zcache*}

    eval "function -zcache-$(functions -- antigen-update)"
    antigen-update () {
        -zcache-antigen-update "$@"
        antigen-cache-reset
    }
    
    zle -D zle-line-init
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
antigen-cache-reset () {
    [[ -f "$_ZCACHE_META_PATH" ]] && rm "$_ZCACHE_META_PATH"
    [[ -f "$_ZCACHE_PAYLOAD_PATH" ]] && rm "$_ZCACHE_PAYLOAD_PATH"
    echo 'Done. Please open a new shell to see the changes.'
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

-zcache-interactive-mode # Updates _ANTIGEN_INTERACTIVE
# Refusing to run in interactive mode
if [[ $_ANTIGEN_CACHE_ENABLED == true && $_ANTIGEN_INTERACTIVE == false ]]; then
    zcache-start
fi

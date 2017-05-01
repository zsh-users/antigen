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
  # Argument defaults. Previously using ${1:?"missing url argument"} format
  # but it seems to mess up with cram
  if (( $# < 1 )); then
    echo "Antigen: Missing url argument."
    return 1
  fi

  # The url. No sane default for this, so just empty.
  local url=$1
  # Check if we have to update.
  local update=${2:-false}
  # Verbose output.
  local verbose=${3:-false}

  shift $#

  # Get the clone's directory as per the given repo url and branch.
  local clone_dir=$(-antigen-get-clone-dir $url)
  if [[ -d "$clone_dir" && $update == false ]]; then
    return true
  fi

  # A temporary function wrapping the `git` command with repeated arguments.
  --plugin-git () {
    (cd -q "$clone_dir" && eval ${ANTIGEN_CLONE_ENV} git --git-dir="$clone_dir/.git" --no-pager "$@" &>>! $ANTIGEN_LOG)
  }

  local success=false

  # If its a specific branch that we want, checkout that branch.
  local branch="master" # TODO FIX THIS
  if [[ $url == *\|* ]]; then
    branch="$(-antigen-parse-branch ${url%|*} ${url#*|})"
  fi

  if [[ ! -d $clone_dir ]]; then
    eval ${ANTIGEN_CLONE_ENV} git clone ${=ANTIGEN_CLONE_OPTS} --branch "$branch" -- "${url%|*}" "$clone_dir" &>> $ANTIGEN_LOG
    success=$?
  elif $update; then
    # Save current revision.
    local old_rev="$(--plugin-git rev-parse HEAD)"
    # Pull changes if update requested.
    --plugin-git checkout "$branch"
    --plugin-git pull origin "$branch"
    success=$?

    # Update submodules.
    --plugin-git submodule update ${=ANTIGEN_SUBMODULE_OPTS}
    # Get the new revision.
    local new_rev="$(--plugin-git rev-parse HEAD)"
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

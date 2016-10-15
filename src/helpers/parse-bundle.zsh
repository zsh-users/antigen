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

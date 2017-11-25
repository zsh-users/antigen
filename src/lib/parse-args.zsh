# Usage:
#   -antigen-parse-args output_assoc_arr <args...>
-antigen-parse-args () {
  local argkey key value index=0 args
  local match mbegin mend MATCH MBEGIN MEND

  local var=$1
  shift

  # Bundle spec arguments' default values.
  #setopt XTRACE VERBOSE
  builtin typeset -A args
  args[url]="$ANTIGEN_DEFAULT_REPO_URL"
  #unsetopt XTRACE VERBOSE
  args[loc]=/
  args[make_local_clone]=true
  args[btype]=plugin
  #args[branch]= # commented out as it may cause assoc array kv mismatch

  while [[ $# -gt 0 ]]; do
    argkey="${1%\=*}"
    key="${argkey//--/}"
    value="${1#*=}"

    case "$argkey" in
      --url|--loc|--branch|--btype)
        if [[ "$value" == "$argkey" ]]; then
          printf "Required argument for '%s' not provided.\n" $key >&2
        else
          args[$key]="$value"
        fi
      ;;
      --no-local-clone)
        args[make_local_clone]=false
      ;;
      --*)
        printf "Unknown argument '%s'.\n" $key >&2
      ;;
      *)
        value=$key
        case $index in
          0)
            key=url
            local domain=""
            local url_path=$value
            # Full url with protocol or ssh github url (github.com:org/repo)
            if [[ "$value" =~ "://" || "$value" =~ ":" ]]; then
              if [[ "$value" =~ [@.][^/:]+[:]?[0-9]*[:/]?(.*)@?$ ]]; then
                url_path=$match[1]
                domain=${value/$url_path/}
              fi
            fi

            if [[ "$url_path" =~ '@' ]]; then
              args[branch]="${url_path#*@}"
              value="$domain${url_path%@*}"
            else
              value="$domain$url_path"
            fi
          ;;
          1) key=loc ;;
        esac
        let index+=1
        args[$key]="$value"
      ;;
    esac

    shift
  done
  
  # Check if url is just the plugin name. Super short syntax.
  if [[ "${args[url]}" != */* ]]; then
    case "$ANTIGEN_DEFAULT_REPO_URL" in
      "$ANTIGEN_OMZ_REPO_URL")
        args[loc]="plugins/${args[url]}"
      ;;
      "$ANTIGEN_PREZTO_REPO_URL")
        args[loc]="modules/${args[url]}"
      ;;
      *)
        args[loc]="${args[url]}"
      ;;
    esac
    args[url]="$ANTIGEN_DEFAULT_REPO_URL"
  fi

  # Resolve the url.
  # Expand short github url syntax: `username/reponame`.
  local url="${args[url]}"
  if [[ $url != git://* &&
          $url != https://* &&
          $url != http://* &&
          $url != ssh://* &&
          $url != /* &&
          $url != *github.com:*/*
          ]]; then
    url="https://github.com/${url%.git}.git"
  fi
  args[url]="$url"

  # Ignore local clone if url given is not a git directory
  if [[ ${args[url]} == /* && ! -d ${args[url]}/.git ]]; then
    args[make_local_clone]=false
  fi

  # Add the branch information to the url if we need to create a local clone.
  # Format url in bundle-metadata format: url[|branch]
  if [[ ! -z "${args[branch]}" && ${args[make_local_clone]} == true ]]; then
    args[url]="${args[url]}|${args[branch]}"
  fi

  # Add the theme extension to `loc`, if this is a theme, but only
  # if it's especified, ie, --loc=theme-name, in case when it's not
  # specified antige-load-list will look for *.zsh-theme files
  if [[ ${args[btype]} == "theme" &&
      ${args[loc]} != "/" && ${args[loc]} != *.zsh-theme ]]; then
      args[loc]="${args[loc]}.zsh-theme"
  fi

  local name="${args[url]%|*}"
  local branch="${args[branch]}"

  # Extract bundle name.
  if [[ "$name" =~ '.*/(.*/.*).*$' ]]; then
    name="${match[1]}"
  fi
  name="${name%.git*}"

  # Format bundle name with optional branch.
  if [[ -n "${branch}" ]]; then
    args[name]="${name}@${branch}"
  else
    args[name]="${name}"
  fi

  # Format bundle path.
  if [[ ${args[make_local_clone]} == true ]]; then
    local bpath="$name"
    # Suffix with branch/tag name
    if [[ -n "$branch" ]]; then
      # bpath is in the form of repo/name@version => repo/name-version
      # Replace / with - in bundle branch.
      local bbranch=${branch//\//-}
      # If branch/tag is semver-like do replace * by x.
      bbranch=${bbranch//\*/x}
      bpath="${name}-${bbranch}"
    fi

    bpath="$ANTIGEN_BUNDLES/$bpath"
    args[dir]="${(qq)bpath}"
  else
    # if it's local then path is just the "url" argument, loc remains the same
    args[dir]=${args[url]}
  fi
  
  # Escape url and branch (may contain semver-like and pipe characters)
  args[url]="${(qq)args[url]}"
  if [[ -n "${args[branch]}" ]]; then
    args[branch]="${(qq)args[branch]}"
  fi
  
  # Escape bundle name (may contain semver-like characters)
  args[name]="${(qq)args[name]}"

  eval "${var}=(${(kv)args})"

  return 0
}

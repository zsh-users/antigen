# Usage:
#   -antigen-parse-args output_assoc_arr <args...>
-antigen-parse-args () {
  local argkey key value index=0
  local match mbegin mend MATCH MBEGIN MEND

  local var=$1
  shift

  # Bundle spec arguments' default values.
  typeset -A args
  args[url]="$ANTIGEN_DEFAULT_REPO_URL"
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
          printf "Required argument for '%s' not provided." $key >&2
        else
          args[$key]="$value"
        fi
      ;;
      --no-local-clone)
        args[make_local_clone]=false
      ;;
      --*)
        printf "Unknown argument '%s'." $key >&2
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
    args[loc]="plugins/${args[url]}"
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
          $url != git@github.com:*/*
          ]]; then
    url="https://github.com/${url%.git}.git"
  fi
  args[url]="$url"

  # Add the branch information to the url.
  # Format url in bundle-metadata format: url[|branch]
  if [[ ! -z "${args[branch]}" ]]; then
    args[url]="${args[url]}|${args[branch]}"
  fi

  # The `make_local_clone` variable better represents whether there should be
  # a local clone made. For cloning to be avoided, firstly, the `$url` should
  # be an absolute local path and `$branch` should be empty. In addition to
  # these two conditions, either the `--no-local-clone` option should be
  # given, or `$url` should not a git repo.
  if [[ ${args[url]} == /* && -z ${args[branch]} &&
          ( ${args[make_local_clone]} == true || ! -d ${args[url]}/.git ) ]]; then
    args[make_local_clone]=false
  fi

  # Add the theme extension to `loc`, if this is a theme, but only
  # if it's especified, ie, --loc=theme-name, in case when it's not
  # specified antige-load-list will look for *.zsh-theme files
  if [[ ${args[btype]} == "theme" &&
      ${args[loc]} != "/" && ${args[loc]} != *.zsh-theme ]]; then
      args[loc]="${args[loc]}.zsh-theme"
  fi


  # Bundle name
  local url="${args[url]}"
  local name="${url%|*}"

  if [[ "$name" =~ '.*/(.*/.*).*$' ]]; then
    name="${match[1]}"
  fi
  name="${name%.git*}"

  if [[ -n ${args[branch]} ]]; then
    name="$name@${args[branch]}"
  fi
  
  args[name]="$name"

  # Bundle path
  if [[ ${bundle[make_local_clone]} == true ]]; then
    local bundle_path="${args[name]}"
    if [[ -n "${args[branch]}" ]]; then
      # Suffix with branch/tag name
      bundle_path="$bundle_path-${args[branch]//\//-}"
    fi
    bundle_path=${bundle_path//\*/x}

    args[path]="$ANTIGEN_BUNDLES/$bundle_path"
  else
    # if it's local then path is just the "url" argument, loc remains the same
    args[path]=${args[url]}
  fi
  
  # Escape url and branch
  args[url]="${(qq)args[url]}"
  if [[ ! -z "${args[branch]}" ]]; then
    args[branch]="${(qq)args[branch]}"
  fi

  eval "${var}=(${(kv)args})"

  return 0
}

# Parses a bundle url in bundle-metadata format: url[|branch]
-antigen-parse-bundle-url() {
  local url=$1
  local branch=$2

  # Resolve the url.
  url="$(-antigen-resolve-bundle-url "$url")"

  # Add the branch information to the url.
  if [[ ! -z $branch ]]; then
    url="$url|$branch"
  fi

  echo $url
}

Test helper and mock functions.

  $ ANTIGEN_DEFAULT_REPO_URL=gh-user/repo
  $ ANTIGEN_WARN_DUPLICATES=false

  $ b () {
  >     antigen-bundle "$@" | tail -3
  > }

  $ -antigen-ensure-repo () {}

  $ -antigen-load () {
  >   typeset -A bundle; bundle=($@)
  >     echo "url:    ${bundle[url]}"
  >     echo "dir:    ${bundle[loc]}"
  >     echo "clone?: ${bundle[make_local_clone]}"
  > }

Short and sweet.

  $ b lol
  url:    https://github.com/gh-user/repo.git
  dir:    lol
  clone?: true

Short repo url.

  $ b github-username/repo-name
  url:    https://github.com/github-username/repo-name.git
  dir:    /
  clone?: true

Short repo url with `.git` suffix.

  $ b github-username/repo-name.git
  url:    https://github.com/github-username/repo-name.git
  dir:    /
  clone?: true

Long repo url.

  $ b https://github.com/user/repo.git
  url:    https://github.com/user/repo.git
  dir:    /
  clone?: true

Long repo url with missing `.git` suffix (should'nt add the suffix).

  $ b https://github.com/user/repo
  url:    https://github.com/user/repo
  dir:    /
  clone?: true

Short repo with location.

  $ b user/plugin path/to/plugin
  url:    https://github.com/user/plugin.git
  dir:    path/to/plugin
  clone?: true

Keyword arguments, in respective places.

  $ b --url=user/repo --loc=path/of/plugin
  url:    https://github.com/user/repo.git
  dir:    path/of/plugin
  clone?: true

Keyword arguments, in respective places, with full repo url.

  $ b --url=https://github.com/user/repo.git --loc=plugin/path
  url:    https://github.com/user/repo.git
  dir:    plugin/path
  clone?: true

Keyword arguments, in reversed order.

  $ b --loc=path/of/plugin --url=user/repo
  url:    https://github.com/user/repo.git
  dir:    path/of/plugin
  clone?: true

Mixed positional and keyword arguments, and skip `loc`.

  $ b user/repo --loc=plugin/loc
  url:    https://github.com/user/repo.git
  dir:    plugin/loc
  clone?: true

Just `loc`, using keyword arguments.

  $ b --loc=plugin/path
  url:    https://github.com/gh-user/repo.git
  dir:    plugin/path
  clone?: true

TODO: Error reporting with erroneous arguments or usage with incorrect syntax.

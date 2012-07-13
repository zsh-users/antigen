Skip test.

  $ exit 80

Test helper and mock functions.

  $ git () {
  >     echo git "$@"
  > }
  $ b () {
  >     bundle "$@"
  >     bundle-list | tail -1
  > }

Short and sweet.

  $ b lol
  plugin-name https://github.com/robbyrussell/oh-my-zsh.git plugins/plugin-name

Short repo url.

  $ b github-username/repo-name
  repo-name https://github.com/github-username/repo-name.git /

Short repo url with `.git` suffix.

  $ b github-username/repo-name.git
  repo-name https://github.com/github-username/repo-name.git /

Long repo url.

  $ b https://github.com/user/repo.git
  repo https://github.com/user/repo.git /

Long repo url with missing `.git` suffix (should'nt add the suffix).

  $ b https://github.com/user/repo
  repo https://github.com/user/repo /

Short repo with location.

  $ b user/plugin path/to/plugin
  plugin https://github.com/user/plugin.git path/to/plugin

Keyword arguments, in respective places.

  $ b --url=user/repo --loc=path/of/plugin
  plugin-name https://github.com/user/repo.git path/of/plugin

Keyword arguments, in respective places, with full repo url.

  $ b --url=https://github.com/user/repo.git --loc=plugin/path
  name https://github.com/user/repo.git plugin/path

Keyword arguments, in reversed order.

  $ b --loc=path/of/plugin --url=user/repo
  plugin-name https://github.com/user/repo.git path/of/plugin

Mixed positional and keyword arguments, and skip `loc`.

  $ b user/repo --loc=plugin/loc
  plugin https://github.com/user/repo.git plugin/loc

Just `loc`, using keyword arguments.

  $ b --loc=plugin/path
  path https://github.com/robbyrussell/oh-my-zsh.git plugin/path

TODO: Error reporting with erroneous arguments or usage with incorrect syntax.

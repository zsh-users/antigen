Test helper function.

  $ b () {
  >     bundle "$@"
  >     bundle-list | tail -1
  > }

Short and sweet.

  $ b plugin-name
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

Short repo with location and name.

  $ b user/repo plugin/path plugin-name
  plugin-name https://github.com/user/repo.git plugin/path

Long repo with location and name.

  $ b https://github.com/user/repo.git plugin/path plugin-name
  plugin-name https://github.com/user/repo.git plugin/path

Keyword arguments, in respective places.

  $ b --url=user/repo --loc=path/of/plugin --name=plugin-name
  plugin-name https://github.com/user/repo.git path/of/plugin

Keyword arguments, in respective places, with full repo url.

  $ b --url=https://github.com/user/repo.git --loc=plugin/path --name=name
  name https://github.com/user/repo.git plugin/path

Keyword arguments, in reversed order.

  $ b --name=plugin-name --loc=path/of/plugin --url=user/repo
  plugin-name https://github.com/user/repo.git path/of/plugin

Mixed positional and keyword arguments, and skip `loc`.

  $ b user/repo --name=plugin
  plugin https://github.com/user/repo.git /

Just `loc`, using keyword arguments.

  $ b --loc=plugin/path
  path https://github.com/robbyrussell/oh-my-zsh.git plugin/path

Just `name`, using keyword arguments.

  $ b --name=robby-oh-my-zsh
  robby-oh-my-zsh https://github.com/robbyrussell/oh-my-zsh.git /

TODO: Error reporting with erroneous arguments or usage with incorrect syntax.

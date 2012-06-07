Helper aliases.

  $ alias b=bundle
  $ alias lb='bundle-list | tail -1' # lb = last bundle

Short and sweet.

  $ b plugin-name
  $ lb
  plugin-name https://github.com/robbyrussell/oh-my-zsh.git plugins/plugin-name

Short repo url.

  $ b github-username/repo-name
  $ lb
  repo-name https://github.com/github-username/repo-name.git /

Short repo url with `.git` suffix.

  $ b github-username/repo-name.git
  $ lb
  repo-name https://github.com/github-username/repo-name.git /

Long repo url.

  $ b https://github.com/user/repo.git
  $ lb
  repo https://github.com/user/repo.git /

Long repo url with missing `.git` suffix (should'nt add the suffix).

  $ b https://github.com/user/repo
  $ lb
  repo https://github.com/user/repo /

Short repo with location.

  $ b user/plugin path/to/plugin
  $ lb
  plugin https://github.com/user/plugin.git path/to/plugin

Short repo with location and name.

  $ b user/repo plugin/path plugin-name
  $ lb
  plugin-name https://github.com/user/repo.git plugin/path

Long repo with location and name.

  $ b https://github.com/user/repo.git plugin/path plugin-name
  $ lb
  plugin-name https://github.com/user/repo.git plugin/path

Keyword arguments, in respective places.

  $ b --url=user/repo --loc=path/of/plugin --name=plugin-name
  $ lb
  plugin-name https://github.com/user/repo.git path/of/plugin

Keyword arguments, in respective places, with full repo url.

  $ b --url=https://github.com/user/repo.git --loc=plugin/path --name=name
  $ lb
  name https://github.com/user/repo.git plugin/path

Keyword arguments, in reversed order.

  $ b --name=plugin-name --loc=path/of/plugin --url=user/repo
  $ lb
  plugin-name https://github.com/user/repo.git path/of/plugin

Mixed positional and keyword arguments, and skip `loc`.

  $ b user/repo --name=plugin
  $ lb
  plugin https://github.com/user/repo.git /

Just `loc`, using keyword arguments.

  $ b --loc=plugin/path
  $ lb
  path https://github.com/robbyrussell/oh-my-zsh.git plugin/path

Just `name`, using keyword arguments.

  $ b --name=robby-oh-my-zsh
  $ lb
  robby-oh-my-zsh https://github.com/robbyrussell/oh-my-zsh.git /

TODO: Error reporting with erroneous arguments or usage with incorrect syntax.

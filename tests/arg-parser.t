Helper alias.

  $ typeset -A bundle
  $ parse () {
  >    bundle=()
  >   -antigen-parse-args bundle "$@"
  > }

No arguments (since all are specified as optional).

  $ parse

One positional argument.

  $ parse plugin/url
  $ echo ${bundle[url]}
  https://github.com/plugin/url.git

Two arguments.

  $ parse plugin/url location
  $ echo ${bundle[url]}
  https://github.com/plugin/url.git
  $ echo ${bundle[loc]}
  location

Three arguments.

  $ parse plugin/url location crap
  $ echo ${bundle[url]}
  https://github.com/plugin/url.git
  $ echo ${bundle[loc]}
  location

Keywordo magic.

  $ parse plugin/url location --btype=1 --no-local-clone
  $ echo ${bundle[url]}
  https://github.com/plugin/url.git
  $ echo ${bundle[loc]}
  location
  $ echo ${bundle[btype]}
  1
  $ echo ${bundle[make_local_clone]}
  false

Unknown keyword argument.

  $ parse --me=genius
  Unknown argument 'me'.

Missed value for keyword argument.

  $ parse --btype
  Required argument for 'btype' not provided.

Provide value for keyword argument, but it's ignored.

  $ parse --no-local-clone=yes
  $ echo ${bundle[make_local_clone]}
  false

Positional argument as a keyword argument.

  $ parse --url=plugin/url
  $ echo ${bundle[url]}
  https://github.com/plugin/url.git

Repeated keyword arguments.

  $ parse --url=plugin/url --url=plugin/url2
  $ echo ${bundle[url]}
  https://github.com/plugin/url2.git

Repeated, once as positional and once more as keyword.

  $ parse plugin/url --url=plugin/url2
  $ echo ${bundle[url]}
  https://github.com/plugin/url2.git

Supports bundle name with branch/version.

  $ parse plugin/url@version
  $ echo ${bundle[url]}
  https://github.com/plugin/url.git|version
  $ echo ${bundle[branch]}
  version

Supports branch/version flag

  $ parse plugin/url --branch=version
  $ echo ${bundle[url]}
  https://github.com/plugin/url.git|version
  $ echo ${bundle[branch]}
  version

Flag `--branch` overwrites `@`-name.

  $ parse plugin/url@b1 --branch=b2
  $ echo ${bundle[url]}
  https://github.com/plugin/url.git|b2
  $ echo ${bundle[branch]}
  b2

Private git urls.

  $ parse ssh://git@domain.local:1234/repository/name.git
  $ echo ${bundle[url]}
  ssh://git@domain.local:1234/repository/name.git

Private git urls with branch short format.

  $ parse ssh://git@domain.local:1234/repository/name.git@example-branch/name
  $ echo ${bundle[url]}
  ssh://git@domain.local:1234/repository/name.git|example-branch/name
  $ echo ${bundle[branch]}
  example-branch/name

Private git urls with branch argument format.

  $ parse ssh://git@domain.local:1234/repository/name.git --branch=example-branch/name
  $ echo ${bundle[url]}
  ssh://git@domain.local:1234/repository/name.git|example-branch/name
  $ echo ${bundle[branch]}
  example-branch/name

SSH github url.

  $ parse github.com:reem/watch.git
  $ echo ${bundle[url]}
  github.com:reem/watch.git

Long SSH github url.

  $ parse git@github.com:zsh-users/antigen.git
  $ echo ${bundle[url]}
  git@github.com:zsh-users/antigen.git

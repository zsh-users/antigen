Helper alias.

  $ alias parse='-antigen-parse-args '

No arguments (since all are specified as optional).

  $ parse

One positional argument.

  $ parse name
  local url='name'

Two arguments.

  $ parse url location
  local url='url'
  local loc='location'

Three arguments.

  $ parse url location crap
  local url='url'
  local loc='location'
  local crap='crap'

Keywordo magic.

  $ parse url location --btype=1 --no-local-clone
  local url='url'
  local loc='location'
  local btype='1'
  local no_local_clone='true'

Unknown keyword argument.

  $ parse --me=genius
  Unknown argument 'me'.

Missed value for keyword argument.

  $ parse --btype
  Required argument for 'btype' not provided.

Provide value for keyword argument, but it's ignored.

  $ parse --no-local-clone=yes
  local no_local_clone='true'

Positional argument as a keyword argument.

  $ parse --url=some-url
  local url='some-url'

Repeated keyword arguments.

  $ parse --url=url1 --url=url2
  local url='url1'
  local url='url2'

Repeated, once as positional and once more as keyword.

  $ parse url1 --url=url2
  local url='url1'
  local url='url2'

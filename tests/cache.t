Enable extension.
  $ export _ANTIGEN_CACHE_ENABLED=true
  $ antigen cache-reset
  Done. Please open a new shell to see the changes.

  $ antigen list
  You don't have any bundles.
  [1]

Add multiple bundles.

  $ echo "$PLUGIN_DIR\n$PLUGIN_DIR2" | antigen-bundles &> /dev/null
  $ antigen apply &> /dev/null

Check if they are both applied.

  $ hehe
  hehe
  $ hehe2
  hehe2

Cache extension is loaded.

  $ echo $_ZCACHE_EXTENSION_LOADED
  true

Cache is loaded.

  $ echo $_ZCACHE_CACHE_LOADED
  true

Should exist cache payload.

  $ ls $_ZCACHE_PAYLOAD_PATH | wc -l
  1

Should have listed bundles.

  $ antigen-list | wc -l
  2

  $ ls -A $_ZCACHE_PATH | wc -l
  2

Both bundles are cached.

  $ cat $_ZCACHE_PAYLOAD_PATH | grep hehe
  alias hehe="echo hehe"
  alias hehe2="echo hehe2"

List command should work as expected.

  $ antigen-list
  */test-plugin / plugin true* (glob)
  */test-plugin2 / plugin true* (glob)

Respect escape sequences.

  $ cat $_ZCACHE_PAYLOAD_PATH | grep prompt
  alias prompt="\e]$ >\a\n"

Can clear cache correctly.

  $ antigen cache-reset
  Done. Please open a new shell to see the changes.

  $ ls -A $_ZCACHE_PATH | wc -l
  0

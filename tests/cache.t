Enable extension.

  $ unset _ZCACHE_EXTENSION_ACTIVE
  $ zcache-start # forces non-interactive mode
  $ antigen reset
  Done. Please open a new shell to see the changes.

  $ antigen list
  You don't have any bundles.
  [1]

Add multiple bundles

  $ echo "$PLUGIN_DIR\n$PLUGIN_DIR2" | antigen-bundles
  $ antigen apply &> /dev/null

Check if they are both applied.

  $ hehe
  hehe
  $ hehe2
  hehe2

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

Cache is saved correctly.

  $ cat $_ZCACHE_PAYLOAD_PATH | wc -l
  24

  $ cat $_ZCACHE_PAYLOAD_PATH | grep -Pzc 'hehe2"\nalias prompt'
  1

  $ cat $_ZCACHE_PAYLOAD_PATH | grep -Pc 'root=\${__ZCACHE_FILE_PATH}'
  1

  $ cat $_ZCACHE_PAYLOAD_PATH | grep -Pc 'echo \$root/\$0'
  1

Cache is invalidated on antigen configuration changes.

  $ unset _ZCACHE_EXTENSION_ACTIVE  
  $ zcache-start # forces non-interactive mode
  $ antigen reset &> /dev/null

  $ echo "$PLUGIN_DIR\n$PLUGIN_DIR2" | antigen-bundles
  $ antigen apply

  $ unset _ZCACHE_EXTENSION_ACTIVE  
  $ zcache-start
  $ echo "$PLUGIN_DIR\n$PLUGIN_DIR2" | antigen-bundles
  $ antigen apply
  $ bundles=$(cat $_ZCACHE_BUNDLES_PATH)

  $ unset _ZCACHE_EXTENSION_ACTIVE  
  $ zcache-start
  $ echo "$PLUGIN_DIR2\n$PLUGIN_DIR" | antigen-bundles
  $ antigen apply
  $ [[ "$bundles" == $(cat $_ZCACHE_BUNDLES_PATH) ]]
  [1]

Cache version matches antigen version.

  $ ANTIGEN_VERSION=$(antigen version | sed 's/Antigen //')
  $ cat $_ZCACHE_PAYLOAD_PATH | grep -Pzc "$ANTIGEN_VERSION"
  1

  $ if [[ "$ANTIGEN_VERSION" == "$_ZCACHE_CACHE_VERSION" ]]; then echo 1; else echo 0; fi
  1

Do not generate or load cache if there are no bundles.

  $ antigen reset &> /dev/null
  $ ls -A $_ZCACHE_PATH | wc -l
  0

Antigen cache-reset command deprecated.

  $ antigen cache-reset
  Deprecated in favor of antigen reset.
  Done. Please open a new shell to see the changes.

Can clear cache correctly.

  $ antigen reset
  Done. Please open a new shell to see the changes.

  $ ls -A $_ZCACHE_PATH | wc -l
  0

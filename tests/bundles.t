Save env variables to test for leaks.

  $ prev=$(env)

Add multiple bundles.

  $ echo "$PLUGIN_DIR\n$PLUGIN_DIR2" | antigen-bundles &> /dev/null

Check if they are both applied.

  $ hehe
  hehe
  $ hehe2
  hehe2

Should not leak Antigen or OMZ environment variables.

  $ diff <(env) <(echo $prev) | sed -e 's/\=.*//' | grep -i antigen | wc -l
  0

  $ diff <(env) <(echo $prev) | sed -e 's/\=.*//' | grep -i zsh | wc -l
  0

Clean it all up.

  $ _ANTIGEN_BUNDLE_RECORD=()
  $ antigen-cleanup --force &> /dev/null

Specify with indentation.

  $ echo "  $PLUGIN_DIR\n  $PLUGIN_DIR2" | antigen-bundles &> /dev/null

Again, check if they are both applied.

  $ hehe
  hehe
  $ hehe2
  hehe2

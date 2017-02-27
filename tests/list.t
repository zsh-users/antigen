Empty initial listing.

  $ antigen-list
  You don't have any bundles.
  [1]

Add a bundle.

  $ antigen-bundle $PLUGIN_DIR &> /dev/null
  $ antigen-list
  .*/test-plugin @ master (re)

Add same bundle and check uniqueness.

  $ antigen-bundle $PLUGIN_DIR
  $ antigen-list
  .*/test-plugin @ .* (re)

Add another bundle.

  $ antigen-bundle $PLUGIN_DIR2 &> /dev/null
  $ antigen-list
  .*/test-plugin @ master (re)
  .*/test-plugin2 @ master (re)

List command supports short format flag.

  $ antigen-list
  .*/test-plugin @ master (re)
  .*/test-plugin2 @ master (re)

  $ antigen-list --short
  .*/test-plugin @ master (re)
  .*/test-plugin2 @ master (re)

  $ antigen-list --long
  .*/test-plugin / plugin true @ master (re)
  .*/test-plugin2 / plugin true @ master (re)

Can display feature branches.

  $ cd $PLUGIN_DIR2
  $ git checkout -b feature-branch &> /dev/null
  $ git rev-parse --abbrev-ref '@'
  feature-branch
  $ antigen-list --short
  .*/test-plugin @ master (re)
  .*/test-plugin2 @ .* (re)

Find bundle/record internal function.

  $ -antigen-find-record
  [1]

  $ -antigen-find-record nonexisting
  

  $ -antigen-find-record test
  *test-plugin* (glob)

  $ -antigen-find-record test-plugin
  *test-plugin* (glob)

  $ -antigen-find-record test-plugin2
  *test-plugin2* (glob)

  $ -antigen-find-record plugin2
  *test-plugin2* (glob)

  $ -antigen-find-record list.t/test-plugin
  *test-plugin* (glob)

  $ -antigen-find-record list.t/test-plugin2
  *test-plugin2* (glob)

  $ -antigen-find-record list.t
  *test-plugin* (glob)

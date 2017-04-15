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
  .*/test-plugin / plugin true (re)
  .*/test-plugin2 / plugin true (re)

Can display feature branches.

  $ cd $PLUGIN_DIR2
  $ git checkout -b feature-branch &> /dev/null
  $ git rev-parse --abbrev-ref '@'
  feature-branch
  $ antigen-list --short
  .*/test-plugin @ master (re)
  .*/test-plugin2 @ .* (re)

  $ antigen-list --long
  .*/test-plugin / plugin true (re)
  .*/test-plugin2 / plugin true (re)

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

  $ -antigen-find-record test-plugin
  *test-plugin* (glob)

  $ -antigen-find-record test-plugin2
  *test-plugin2* (glob)

  $ -antigen-find-record 'cram-testdir-*/test-plugin2'
  *cram-testdir-*/test-plugin2* (glob)

List bundle no git repo.

  $ antigen bundle $PLUGIN_DIR4
  $ antigen list
  *test-plugin @ master (glob)
  *test-plugin2 @ master (glob)
  *test-plugin4 @ master (glob)
  $ hello-world
  hello world


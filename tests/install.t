Skip test.

  $ exit 80

Confirm we have no plugins.

  $ bundle-list
  You don't have any bundles.
  [1]

Record a plugin and install it.

  $ bundle lol
  $ bundle-install
  Cloning into '[-_\.a-zA-Z0-9/\\]+'... (re)
  Installing lol

Check if the lol plugin is correctly loaded.

  $ alias wtf
  wtf=dmesg

On-spot installation.

  $ bundle-install git
  Installing git

Check if git plugin is loaded correctly.

  $ alias g
  g=git

Confirm the listing of plugins.

  $ bundle-list
  lol https://github.com/robbyrussell/oh-my-zsh.git plugins/lol
  git https://github.com/robbyrussell/oh-my-zsh.git plugins/git

Update plugins (test both alternate syntaxes for do this).

  $ bundle-install!
  Already up-to-date.
  Installing lol
  Installing git
  $ bundle-install --update
  Already up-to-date.
  Installing lol
  Installing git

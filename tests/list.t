Skip test.

  $ exit 80

Listing recorded bundles.

  $ bundle-list
  You don't have any bundles.
  [1]
  $ bundle lol
  $ bundle-list
  lol https://github.com/robbyrussell/oh-my-zsh.git plugins/lol
  $ bundle vi-mode
  $ bundle-list
  lol https://github.com/robbyrussell/oh-my-zsh.git plugins/lol
  vi-mode https://github.com/robbyrussell/oh-my-zsh.git plugins/vi-mode

TODO: Listing of plugins installed on-spot.

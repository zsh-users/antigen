Finds a given record with branch name.

  $ _ANTIGEN_BUNDLE_RECORD=('https://github.com/rupa/z.git|952f01375a2e28463a8abbaa54b4a038c74c8d82 / plugin true'
  > 'https://github.com/desyncr/watch.git|develop / plugin true'
  > 'https://github.com/zsh-users/zsh-autosuggestions.git / plugin true'
  > 'https://github.com/zsh-users/zsh-syntax-highlighting.git|0.5.* / plugin true 0.5.*')
  $ -antigen-find-record 'https://github.com/zsh-users/zsh-syntax-highlighting.git|0.5.*'
  https://github.com/zsh-users/zsh-syntax-highlighting.git|0.5.* / plugin true 0.5.*

  $ -antigen-find-record zsh-syntax-highlighting
  https://github.com/zsh-users/zsh-syntax-highlighting.git|0.5.* / plugin true 0.5.*

  $ -antigen-find-record 'syntax'
  https://github.com/zsh-users/zsh-syntax-highlighting.git|0.5.* / plugin true 0.5.*

  $ -antigen-find-record '0.5.*'
  https://github.com/zsh-users/zsh-syntax-highlighting.git|0.5.* / plugin true 0.5.*

  $ -antigen-find-record 'zsh-users'
  https://github.com/zsh-users/zsh-autosuggestions.git / plugin true

  $ -antigen-find-record 'true'
  https://github.com/rupa/z.git|952f01375a2e28463a8abbaa54b4a038c74c8d82 / plugin true

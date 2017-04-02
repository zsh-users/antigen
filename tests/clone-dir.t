Set up functions and env variables:

  $ ANTIGEN_LOG=/dev/stdout # We wanna see debug output
  $ function git() { echo "\ngit $@\n" } # Wrap git to avoid the network

Bundles branches are stored in their own paths.

  $ -antigen-load () {}
  $ antigen bundle zsh-users/zsh-syntax-highlighting@example/branch
  Installing zsh-users/zsh-syntax-highlighting@example/branch... 
  git clone .* --branch example/branch -- https://github.com/zsh-users/zsh-syntax-highlighting.git .*/bundles/zsh-users/zsh-syntax-highlighting-example-branch (re)
  
  Done. Took *s. (glob)

There may be a dot-git suffix in branches names.

  $ antigen bundle https://github.com/user-name/zsh-bundle.git@feature/make-it-work.git
  Installing user-name/zsh-bundle@feature/make-it-work.git... 
  git clone .* --branch feature/make-it-work.git -- https://github.com/user-name/zsh-bundle.git .*/bundles/user-name/zsh-bundle-feature-make-it-work.git (re)
  
  Done. Took *s. (glob)

You may use a plugin from a library on an specific tag/branch.

  $ antigen bundle git@v1.2.3-1
  Installing robbyrussell/oh-my-zsh@v1.2.3-1... 
  git clone .* --branch v1.2.3-1 -- https://github.com/robbyrussell/oh-my-zsh.git .*/bundles/robbyrussell/oh-my-zsh-v1.2.3-1 (re)
  
  Done. Took *s. (glob)

Naturally handle --branch flag.

  $ antigen bundle rupa/z --branch=0.0-1.x
  Installing rupa/z@0.0-1.x... 
  git clone .* --branch 0.0-1.x -- https://github.com/rupa/z.git .*/bundles/rupa/z-0.0-1.x (re)
  
  Done. Took *s. (glob)

There may be a dot-git suffix in bundle name.

  $ antigen bundle zsh/git-completions.git@git/v1.8.git
  Installing zsh/git-completions@git/v1.8.git... 
  git clone .* --branch git/v1.8.git -- https://github.com/zsh/git-completions.git .*/bundles/zsh/git-completions-git-v1.8.git (re)
  
  Done. Took *s. (glob)

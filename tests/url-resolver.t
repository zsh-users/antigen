Helper alias.

  $ resolve () {typeset -A response; -antigen-parse-args 'response' $1; echo "${response[url]}" }

Complete urls.

  $ resolve https://github.com/zsh-users/antigen.git
  https://github.com/zsh-users/antigen.git
  $ resolve git://github.com/zsh-users/antigen.git
  git://github.com/zsh-users/antigen.git
  $ resolve git@github.com:zsh-users/antigen.git
  git@github.com:zsh-users/antigen.git

Complete github urls, missing the `.git` suffix.

  $ resolve https://github.com/zsh-users/antigen
  https://github.com/zsh-users/antigen
  $ resolve git://github.com/zsh-users/antigen
  git://github.com/zsh-users/antigen
  $ resolve git@github.com:zsh-users/antigen
  git@github.com:zsh-users/antigen

Just username and repo name.

  $ resolve zsh-users/antigen
  https://github.com/zsh-users/antigen.git
  $ resolve zsh-users/antigen.git
  https://github.com/zsh-users/antigen.git

Local absolute file path.

  $ resolve /path/to/a/local/git/repo
  /path/to/a/local/git/repo

Set up functions and env variables:

  $ export _ANTIGEN_LOG_PATH=/dev/stdout # We wanna see debug output
  $ function git() { echo "\ngit $@\n" } # Wrap git to avoid the network
  $ REPO_NAME=user/repo
  $ REPO_URL=https://github.com/$REPO_NAME.git

Ensure repo default args missing url:

  $ -antigen-ensure-repo 2>&1
  Antigen: Missing url argument.
  [1]

Clones a repository if it's not cloned already:

  $ -antigen-ensure-repo $REPO_URL
  Installing user/repo.* (re)
  git clone --recursive https://github.com/user/repo.git .*user-SLASH-repo.git (re)
  .* (re)
  Done. Took 0s. (re)

Ignore update argument if there is no repo cloned:

  $ -antigen-ensure-repo $REPO_URL true
  Installing user/repo... 
  git clone --recursive https://github.com/user/repo.git .*user-SLASH-repo.git (re)
  .* (re)
  Done. Took 0s.

Effectively update a repository already cloned:

  $ mkdir -p $(-antigen-get-clone-dir $REPO_URL) # Fake repository clone
  $ -antigen-ensure-repo $REPO_URL true
  Updating user/repo... 
  git --git-dir=.* --no-pager checkout  (re)
  git --git-dir=.* --no-pager rev-parse --abbrev-ref HEAD (re)
  
  
  git --git-dir=.* --no-pager pull origin  (re)
  git --git-dir=.* --no-pager rev-parse --abbrev-ref HEAD (re)
  
  
  git --git-dir=.* --no-pager submodule update --recursive (re)
  
  Done. Took 0s.

Clone especific branch if required:

  $ -antigen-ensure-repo "$REPO_URL|v5.0"
  Installing user/repo... 
  git clone --recursive https://github.com/user/repo.git .*user-SLASH-repo.git-PIPE-v5.0 (re)
  
  Done. Took 0s.
  
  git --git-dir=.* --no-pager checkout v5\.0 (re)
  

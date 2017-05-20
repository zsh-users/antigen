Set up functions and env variables:

  $ ANTIGEN_LOG=/dev/stdout # We wanna see debug output
  $ function git() { echo "\ngit $@\n" } # Wrap git to avoid the network
  $ REPO_NAME=user/repo
  $ REPO_URL=https://github.com/$REPO_NAME.git

Ensure repo default args missing url:

  $ -antigen-ensure-repo 2>&1
  Antigen: Missing url argument.
  [1]

Clones a repository if it's not cloned already:

  $ -antigen-ensure-repo $REPO_URL
  Installing user/repo@master... 
  git clone .* --branch master -- https://github.com/user/repo.git .*user/repo (re)
  
  Done. Took *s. (glob)

Ignore update argument if there is no repo cloned:

  $ -antigen-ensure-repo $REPO_URL true
  Installing user/repo@master... 
  git clone .* --branch master -- https://github.com/user/repo.git .*user/repo (re)
  
  Done. Took *s. (glob)

Effectively update a repository already cloned:

  $ mkdir -p $(-antigen-get-clone-dir $REPO_URL) # Fake repository clone
  $ -antigen-ensure-repo $REPO_URL true
  Updating user/repo@master... 
  git --git-dir=.*/user/repo/.git .* checkout master (re)
  
  
  git --git-dir=.*/user/repo/.git .* pull origin master (re)
  
  
  git --git-dir=.*/user/repo/.git .* submodule update .* (re)
  
  Done. Took *s. (glob)

Clone especific branch if required:

  $ rm -r $ANTIGEN_BUNDLES
  $ -antigen-ensure-repo "$REPO_URL|v5.0"
  Installing user/repo@v5.0... 
  git clone .* --branch v5.0 -- https://github.com/user/repo.git .*user/repo-v5.0 (re)
  
  Done. Took *s. (glob)


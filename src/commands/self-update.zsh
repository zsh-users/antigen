# Update (with `git pull`) antigen itself.
# TODO: Once update is finished, show a summary of the new commits, as a kind of
# "what's new" message.
antigen-selfupdate () {
  ( cd -q $_ANTIGEN_INSTALL_DIR
   if [[ ! ( -d .git || -f .git ) ]]; then
     echo "Your copy of antigen doesn't appear to be a git clone. " \
       "The 'selfupdate' command cannot work in this case."
     return 1
   fi
   local head="$(git rev-parse --abbrev-ref HEAD)"
   if [[ $head == "HEAD" ]]; then
     # If current head is detached HEAD, checkout to master branch.
     git checkout master
   fi
   git pull

   # TODO Should be transparently hooked by zcache
   antigen-reset &>> /dev/null
  )
}

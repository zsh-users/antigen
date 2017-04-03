-antigen-update-repos () {
  local repo bundle url target
  local log=/tmp/antigen-v2-migrate.log

  echo "It seems you have bundles cloned with Antigen v1.x."
  echo "We'll try to convert directory structure to v2."
  echo

  echo -n "Moving bundles to '\$ADOTDIR/bundles'... "

  # Migrate old repos -> bundles
  local errors=0
  for repo in $ADOTDIR/repos/*; do
    bundle=${repo/$ADOTDIR\/repos\//}
    bundle=${bundle//-SLASH-/\/}
    bundle=${bundle//-COLON-/\:}
    bundle=${bundle//-STAR-/\*}
    url=${bundle//-PIPE-/\|}
    target=$(-antigen-get-clone-dir $url)
    mkdir -p "${target:A:h}"
    echo " ---> ${repo/$ADOTDIR\/} -> ${target/$ADOTDIR\/}" | tee > $log
    mv "$repo" "$target" &> $log
    if [[ $? != 0 ]]; then
      echo "Failed to migrate '$repo'!."
      errors+=1
    fi
  done

  if [[ $errors == 0 ]]; then
    echo "Done."
  else
    echo "An error ocurred!"
  fi
  echo

  if [[ "$(ls -A $ADOTDIR/repos | wc -l | xargs)" == 0 ]]; then
    echo "You can safely remove \$ADOTDIR/repos."
  else
    echo "Some bundles couldn't be migrated. See \$ADOTDIR/repos."
  fi

  echo
  if [[ $errors == 0 ]]; then
    echo "Bundles migrated successfuly."
    rm $log
  else
    echo "Some errors occured. Review migration log in '$log'."
  fi
  antigen-reset
}

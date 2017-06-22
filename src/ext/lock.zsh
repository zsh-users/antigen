# Initialize lock lib
-antigen-lock-init () {
  # Default lock path.
  -antigen-set-default ANTIGEN_LOCK $ADOTDIR/.lock
  typeset -g _ANTIGEN_LOCK_PROCESS=false
  
  # Use env variable to determine if we should load this extension
  -antigen-set-default ANTIGEN_MUTEX true
  # Set ANTIGEN_MUTEX to false to avoid loading this extension
  if [[ $ANTIGEN_MUTEX == true ]]; then
    return 0;
  fi
  
  # Do not use mutex
  return 1;
}

-antigen-lock-execute () {
  # Hook antigen command in order to check/create a lock file.
  # This hook is only run once then releases itself.
  antigen-lock () {
    LOG "antigen-lock called"
    # If there is a lock set up then we won't process anything.
    if [[ -f $ANTIGEN_LOCK ]]; then
      # Set up flag do the message is not repeated for each antigen-* command
      [[ $_ANTIGEN_LOCK_PROCESS == false ]] && printf "Antigen: Another process in running.\n"
      _ANTIGEN_LOCK_PROCESS=true
      # Do not further process hooks. For this hook to properly work it
      # should be registered first.
      return -1
    fi

    WARN "Creating antigen-lock file at $ANTIGEN_LOCK"
    touch $ANTIGEN_LOCK
  }
  antigen-add-hook antigen antigen-lock pre once

  # Hook antigen-apply in order to release .lock file.
  antigen-apply-lock () {
    WARN "Freeing antigen-lock file at $ANTIGEN_LOCK"
    unset _ANTIGEN_LOCK_PROCESS
    rm -f $ANTIGEN_LOCK &> /dev/null
  }
  antigen-add-hook antigen-apply antigen-apply-lock post once
}

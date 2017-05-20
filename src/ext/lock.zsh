# Initialize lock lib
-antigen-lock-init () {
  # Default lock path.
  -antigen-set-default ANTIGEN_LOCK $ADOTDIR/.lock
  typeset -g _ANTIGEN_LOCK_PROCESS=false
}

-antigen-lock-execute () {
  # Hook antigen command in order to check/create a lock file.
  # This hook is only run once then releases itself.
  antigen-lock () {
    antigen-remove-hook antigen-lock

    # If there is a lock set up then we won't process anything.
    if [[ -f $ANTIGEN_LOCK ]]; then
      # Set up flag do the message is not repeated for each antigen-* command
      [[ $_ANTIGEN_LOCK_PROCESS == false ]] && printf "Antigen: Another process in running.\n"
      _ANTIGEN_LOCK_PROCESS=true
      # Do not further process hooks. For this hook to properly work it
      # should be registered first.
      return -1
    fi

    touch $ANTIGEN_LOCK

    # Call hooked function
    antigen "$@"
  }
  antigen-add-hook antigen antigen-lock replace

  # Hook antigen-apply in order to release .lock file.
  antigen-apply-lock () {
    # One time hook
    antigen-remove-hook antigen-apply-lock
    unset _ANTIGEN_LOCK_PROCESS
    rm -f $ANTIGEN_LOCK &> /dev/null
    antigen-apply "$@"
  }
  antigen-add-hook antigen-apply antigen-apply-lock replace
}

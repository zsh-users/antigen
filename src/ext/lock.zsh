# Initialize lock lib
-antigen-lock-init () {
  typeset -g _ANTIGEN_LOCK_PROCESS=false

  # Hook antigen command in order to check/create a lock file.
  # This hook is only run once then releases itself.
  antigen-lock () {
    antigen-remove-hook antigen-lock

    # If there is a lock set up then we won't process anything.
    if [[ -f $ANTIGEN_LOCK ]]; then
      # Set up flag do the message is not repeated for each antigen-* command
      [[ $_ANTIGEN_LOCK_PROCESS == false ]] && printf "Antigen: Another process in running.\n"
      _ANTIGEN_LOCK_PROCESS=true
      return 1
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
    rm $ANTIGEN_LOCK &> /dev/null
    antigen-apply "$@"
  }
  antigen-add-hook antigen-apply antigen-apply-lock replace
}

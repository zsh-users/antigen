typeset -g _ANTIGEN_LOCK_PROCESS=false
-antigen-lock-init () {
  eval "function --lock-$(functions -- antigen)"
  antigen () {
    # If there is a lock set up then we won't process anything.
    if [[ -f $ADOTDIR/.lock ]]; then
      # Set up flag do the message is not repeated for each antigen-* command
      [[ $_ANTIGEN_LOCK_PROCESS == false ]] && printf "Antigen: Another process in running.\n"
      _ANTIGEN_LOCK_PROCESS=true
      return 1
    fi
    touch $ADOTDIR/.lock

    # De-lock at antigen-apply. We are difining it here as commands are compiled
    # _after_ extensions.
    eval "function --lock-$(functions -- antigen-apply)"
    antigen-apply () {
      # Call hooked function.
      --lock-antigen-apply
      eval "function $(functions -- --lock-antigen-apply | sed s/--lock-//)"
      unfunction -- --lock-antigen-apply

      rm $ADOTDIR/.lock > /dev/null
    }

    # Release this function
    eval "function $(functions -- --lock-antigen | sed s/--lock-//)"

    # Call hooked function
    --lock-antigen "$@"
    
    unfunction -- --lock-antigen
  }

}

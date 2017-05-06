# Initialize parallel lib
-antigen-parallel-init () {
  typeset -ga _PARALLEL_BUNDLE=()
}

-antigen-parallel-execute() {
  # Install bundles in parallel
  antigen-bundle-parallel-execute () {
    typeset -a pids; pids=()
    local args pid

    # Do ensure-repo in parallel
    for args in "${_PARALLEL_BUNDLE[@]}"; do
      typeset -A bundle; -antigen-parse-args 'bundle' ${=args}
      echo "Installing ${bundle[name]}"
      -antigen-ensure-repo ${bundle[url]} > /dev/null &!
      pids+=($!)
    done

    # Wait for all background processes to end
    while [[ $#pids > 0 ]]; do
      for pid in $pids; do
         if [[ $(ps -o pid= -p $pid) == "" ]]; then
           pids[$pids[(I)$pid]]=()
         fi
      done
      sleep .5
    done
    
    # Do call antigen-bundle to load bundle
    for args in "${_PARALLEL_BUNDLE[@]}"; do
      antigen-bundle $args
    done

    echo "Done!"
  }

  # Hooks antigen-bundle in order to parallel its execution.
  antigen-bundle-parallel () {
    _PARALLEL_BUNDLE+=("${(j: :)${@}}")
  }
  antigen-add-hook antigen-bundle antigen-bundle-parallel replace
  
  # Hooks antigen-apply in order to release hooked functions
  antigen-apply-parallel () {
    antigen-remove-hook antigen-bundle-parallel
    # Process all parallel bundles.
    antigen-bundle-parallel-execute ${_PARALLEL_BUNDLE}

    antigen-remove-hook antigen-apply-parallel
    unset _PARALLEL_BUNDLE
    antigen-apply "$@"
  }
  antigen-add-hook antigen-apply antigen-apply-parallel replace
}

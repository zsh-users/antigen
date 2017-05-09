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
      if [[ ! -d ${bundle[path]} ]]; then
        echo "Installing ${bundle[name]}..."
        -antigen-ensure-repo ${bundle[url]} > /dev/null &!
        pids+=($!)
      fi
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

    for args in "${_PARALLEL_BUNDLE[@]}"; do
      antigen-bundle $args
    done
  }
  
  # Hooks antigen-apply in order to release hooked functions
  antigen-pre-apply-parallel () {
    antigen-remove-hook antigen-pre-apply-parallel

    #antigen-remove-hook antigen-pre-apply-parallel
    # Hooks antigen-bundle in order to parallel its execution.
    antigen-bundle-parallel () {
      _PARALLEL_BUNDLE+=("${(j: :)${@}}")
    }
    antigen-add-hook antigen-bundle antigen-bundle-parallel replace
    
    antigen-apply-parallel () {
      antigen-remove-hook antigen-bundle-parallel
      antigen-remove-hook antigen-apply-parallel

      # Process all parallel bundles.
      antigen-bundle-parallel-execute ${_PARALLEL_BUNDLE}

      unset _PARALLEL_BUNDLE
      antigen-apply "$@"
    }
    antigen-add-hook antigen-apply antigen-apply-parallel replace
  }
  antigen-add-hook antigen-apply antigen-pre-apply-parallel pre
}

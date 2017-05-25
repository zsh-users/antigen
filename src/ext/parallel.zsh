# Initialize parallel lib
-antigen-parallel-init () {
  WARN "Init parallel extension" PARALLEL
  typeset -ga _PARALLEL_BUNDLE=()
  if -antigen-interactive-mode; then
    return 1
  fi
}

-antigen-parallel-execute() {
  WARN "Exec parallel extension" PARALLEL
  # Install bundles in parallel
  antigen-bundle-parallel-execute () {
    WARN "Parallel antigen-bundle-parallel-execute" PARALLEL
    typeset -a pids; pids=()
    local args pid

    WARN "Gonna install in parallel ${#_PARALLEL_BUNDLE} bundles." PARALLEL
    # Do ensure-repo in parallel
    WARN "${_PARALLEL_BUNDLE}" PARALLEL
    for args in ${_PARALLEL_BUNDLE}; do
      typeset -A bundle; -antigen-parse-args 'bundle' ${=args}
      if [[ ! -d ${bundle[path]} ]]; then
        WARN "Install in parallel ${bundle[name]}." PARALLEL
        echo "Installing ${bundle[name]}!..."
        -antigen-ensure-repo "${bundle[url]}" > /dev/null &!
        pids+=($!)
      else
        WARN "Bundle ${bundle[name]} already cloned locally." PARALLEL
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
    
    for bundle in ${_PARALLEL_BUNDLE[@]}; do
      antigen-bundle $bundle
    done

    WARN "Parallel install done" PARALLEL
  }

  # Hooks antigen-apply in order to release hooked functions
  antigen-apply-parallel () {
    WARN "Parallel pre-apply" PARALLEL PRE-APPLY
    #antigen-remove-hook antigen-pre-apply-parallel
    # Hooks antigen-bundle in order to parallel its execution.
    antigen-bundle-parallel () {
      TRACE "antigen-bundle-parallel: $@" PARALLEL
      _PARALLEL_BUNDLE+=("${(j: :)${@}}")
    }
    antigen-add-hook antigen-bundle antigen-bundle-parallel replace
  }
  antigen-add-hook antigen-apply antigen-apply-parallel pre once
  
  antigen-apply-parallel-execute () {
      WARN "Parallel replace-apply" PARALLEL REPLACE-APPLY
      antigen-remove-hook antigen-bundle-parallel
      # Process all parallel bundles.
      antigen-bundle-parallel-execute

      unset _PARALLEL_BUNDLE
      antigen-remove-hook antigen-apply-parallel-execute
      antigen-apply
  }
  antigen-add-hook antigen-apply antigen-apply-parallel-execute replace once
}

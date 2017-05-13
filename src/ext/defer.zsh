# Initialize defer lib
-antigen-defer-init () {
  typeset -ga _DEFERRED_BUNDLE=()
}

-antigen-defer-execute () {
  # Hooks antigen-bundle in order to defer its execution.
  antigen-bundle-defer () {
    _DEFERRED_BUNDLE+=("${(j: :)${@}}")
    
    return -1 # Stop right there
  }
  antigen-add-hook antigen-bundle antigen-bundle-defer replace
  
  # Hooks antigen-apply in order to release hooked functions
  antigen-pre-apply-defer () {
    antigen-remove-hook antigen-bundle-defer

    # Process all deferred bundles.
    for bundle in $_DEFERRED_BUNDLE; do
      LOG "Processing deferred bundle: ${bundle}"
      antigen-bundle ${=bundle}
    done

    unset _DEFERRED_BUNDLE
  }
  antigen-add-hook antigen-apply antigen-pre-apply-defer pre once
}

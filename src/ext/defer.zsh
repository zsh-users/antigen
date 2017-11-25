# Initialize defer lib
-antigen-defer-init () {
  typeset -ga _DEFERRED_BUNDLE; _DEFERRED_BUNDLE=()
  if -antigen-interactive-mode; then
    return 1
  fi
}

-antigen-defer-execute () {
  # Hooks antigen-bundle in order to defer its execution.
  antigen-bundle-defer () {
    _DEFERRED_BUNDLE+=("${(j: :)${@}}")
    return -1 # Stop right there
  }
  antigen-add-hook antigen-bundle antigen-bundle-defer replace
  
  # Hooks antigen-apply in order to release hooked functions
  antigen-apply-defer () {
    WARN "Defer pre-apply" DEFER PRE-APPLY
    antigen-remove-hook antigen-bundle-defer

    # Process all deferred bundles.
    local bundle
    for bundle in ${_DEFERRED_BUNDLE[@]}; do
      LOG "Processing deferred bundle: ${bundle}" DEFER
      antigen-bundle $bundle
    done

    unset _DEFERRED_BUNDLE
  }
  antigen-add-hook antigen-apply antigen-apply-defer pre once
}

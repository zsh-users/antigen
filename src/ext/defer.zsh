# Initialize defer lib
-antigen-defer-init () {
  typeset -ga _DEFERRED_BUNDLE=()

  # Hooks antigen-bundle in order to defer its execution.
  antigen-bundle-defer () {
    _DEFERRED_BUNDLE+=("${(j: :)${@}}")
  }
  antigen-add-hook antigen-bundle antigen-bundle-defer replace
  
  # Hooks antigen-apply in order to release hooked functions
  antigen-apply-defer () {
    antigen-remove-hook antigen-bundle-defer
    # Process all deferred bundles.
    for bundle in $_DEFERRED_BUNDLE; do
      antigen-bundle ${=bundle}
    done

    antigen-remove-hook antigen-apply-defer
    unset _DEFERRED_BUNDLE
    antigen-apply "$@"
  }
  antigen-add-hook antigen-apply antigen-apply-defer replace
}

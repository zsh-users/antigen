antigen-help () {
  antigen-version

  cat <<EOF

Antigen is a plugin management system for zsh. It makes it easy to grab awesome
shell scripts and utilities, put up on Github.

Usage: antigen <command> [args]

Commands:
  apply        Must be called in the zshrc after all calls to 'antigen bundle'.
  bundle       Install and load the given bundle.
  bundles      Bulk define bundles with HEREDOC syntax.
  cache-gen    Generate Antigen's cache with currently loaded bundles.
  cleanup      Purge clones of bundles currently not loaded.
  env          Display Antigen environment variables.
  init         Use caching to quickly load bundles.
  list         List currently loaded bundles.
  purge        Remove a bundle from the filesystem.
  reset        Clean generated cache and completions.
  restore      Restore bundle state from a snapshot file.
  revert       Revert bundles to their state prior to the last time 'antigen
               update' was run.
  selfupdate   Update Antigen itself.
  snapshot     Create a snapshot of all active bundle repos and save it to a
               snapshot file.
  update       Update bundles.
  use          Load a supported zsh pre-packaged framework.

For further details and complete documentation, visit the project's page at
'http://antigen.sharats.me'.
EOF
}

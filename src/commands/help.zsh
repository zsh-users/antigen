antigen-help () {
  antigen-version

  cat <<EOF

Antigen is a plugin management system for zsh. It makes it easy to grab awesome
shell scripts and utilities, put up on Github.

Usage: antigen <command> [args]

Commands:
  apply        Must be called in the zshrc after all calls to 'antigen bundle'.
  bundle       Install and load a plugin.
  cache-gen    Generate Antigen's cache with currently loaded bundles.
  cleanup      Remove clones of repos not used by any loaded plugins.
  init         Use caching to quickly load bundles.
  list         List currently loaded plugins.
  purge        Remove a bundle from the filesystem.
  reset        Clean the generated cache.
  restore      Restore plugin state from a snapshot file.
  revert       Revert plugins to their state prior to the last time 'antigen
               update' was run.
  selfupdate   Update antigen.
  snapshot     Create a snapshot of all active plugin repos and save it to a
               snapshot file.
  update       Update plugins.
  use          Load a supported zsh pre-packaged framework.

For further details and complete documentation, visit the project's page at
'http://antigen.sharats.me'.
EOF
}

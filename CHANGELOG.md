# CHANGELOG
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.2.0] - 2016-10-09

Antigen now auto-detects configuration changes. This is done by detecting
new/removed bundles/ordering changes in configuration (bundles, themes, use etc).
When a change is detected next time Antigen is loaded it'll rebuild cache.

`cache-reset` command is now deprecated and should be used `reset` instead.

`-antigen-parse-args` function was removed in favor of a more flexible, lax
and performant implementation.

The following errors are not present anymore:
  - Positional argument count mismatch
  - Argument repeated
  - No argument required

Positional argument count mismatch: There is no `spec` argument from now on so there is
no definition on arguments.

Argument repeated: All arguments are parsed and returned. Last value is used.

No argument required: The case is `--no-local-clone` and the value passed is ignored.


New environment variables:
  - `_ANTIGEN_AUTODETECT_CONFIG_CHANGES`: Whether to check for configuration
  changes (true by default).

### Changed
- [#257, #271] Remove parse-args function
- [#255, #265, #275, #253] Refactor/clean up code
- [#274, #267] Hook antigen-bundles command
- [#266, #258] Deprecate cache-reset command in favor of reset
- [#256, #264] Auto detect changes in bundling
- [#277] Fix for antigen 1.1.4

### Fixed
- [#273] Missing antigen-apply on zcache-done
- [#272] Fix bundle-short-name function to handle gist urls

Thanks everyone who reported issues and provided feedback.

## [1.1.4] - 2016-09-25

Default cache and bundles path is now `$ADOTDIR/.cache` and `$ADOTDIR/repos`
(it was `$_ANTIGEN_INSTALL_DIR/.cache` and `$_ANTIGEN_INSTALL_DIR/repos`).

New environment variables:

  - `_ANTIGEN_INTERACTIVE_MODE`: Use to force Antigen into running the caching
  mechanism even in interactive mode (by default it deactivate caching in
  interactive shells).

### Changed
- [#248] Enhanced caching performance
- [#245, #244] Changed default caching and logging paths
 
### Fixed
- [#249, #240, #246] Makefile BSD compatibility
- [#247, #228] Fix apply and antigen-apply command
- [#251] Fix Makefile publish task

Thanks @fladi, @jdkbx, @extink and everyone who reported
issues and provided feedback.

## [1.1.3] - 2016-09-20

### Changed
- [#236] Add Makefile release and publish tasks
 
### Fixed
- [#239] Issue with BSD sed (MacOS, FreeBSD) 

Thanks @pawelad, @laurenbenichou, @zawadzkip and everyone who reported
issues and provided feedback.

## [1.1.2] - 2016-09-16

### Changed
- [#234] Cache process-source function now handles function-context
- [#233] Antigen selfupdate command now clears cache automatically
 
### Fixed
- [#219] Issue with zsh-navigation-tools plugin and powerlevel9k theme
- [#230] Issue with stalled cache

Thanks @xasx, @ilkka, @NelsonBrandao and everyone who reported
issues and provided feedback.

## [1.1.1] - 2016-09-13

### Changed
- [#223] Update tests cases
 
### Fixed
- [#220] Fpath was not updated correctly
- [#221, #217] Fix various typos in CHANGELOG.md
- [#224] Update README.md

Thanks @xasx, @azu and @mikeys

## [1.1.0] - 2016-09-10 

New environment variables:
    
  - `_ANTIGEN_LOG_PATH`: Antigen path for logging (mostly git commands).

  - `_ANTIGEN_COMP_ENABLED`: Flag to enable/disable Antigen own completions
  `compinit`, which adds `~0.02s` to load time.

  - `_ANTIGEN_CACHE_ENABLED`: Flag to enable/disable cache system.

New commands:

- `init`: Use this command to load antigen configuration. Example set up:
    
    .zshrc:
        
        source antigen.zsh
        antigen init .antigenrc
        
    .antigenrc:

        antigen use oh-my-zsh
        
        antigen bundle ...
        antigen theme ...
        
        antigen apply

    
This setup further improves cache performance (`~0.02s`). It's fully optional.
        
- `cache-reset`: Clears current cache. Doesn't removes your bundles. This is done automatically after `antigen update` command.
    
- `version`: Show antigen running version.

### Added
- [#129] Cache system for better performance
- [#191] Version command
- [#211] Option to disable antigen's own completions compinit on start up 

### Changed
- [#205] Bundle short syntax on install/update
- [#156, #213] Improved continuos integration set up 
- [#195] Restructured project directory 

### Fixed
- [#210] Prezto issue with environment variable
- [#162] Fix issue with antigen update after revert

## [1.0.4] - 2016-08-27
### Added
- [#188] Add CONTRIBUTING.md to documentation
- [#183] Update README.md to use rawgit in examples
- [#182] Add Gitter, Trello and Travis CI badges

### Changed
- [#171] Continuous integration against multiple Zsh versions

### Fixed
- [#170] Check git dependency on sourcing
- [#169] Load Antigen's own completions at load time

## [1.0.3] - 2016-08-20
### Changed
- [#172] Fix TravisCI configuration 

## [1.0.2] - 2016-08-11
### Changed
- [#168] Update README.md example code thanks to @chadmoore

## [1.0.1] - 2016-07-21
### Added
- [#141] Performance improvements thanks to @outcoldman
- Added CHANGELOG.md
- Following [Semantic Versioning](http://semver.org/)

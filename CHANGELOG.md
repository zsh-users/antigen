# CHANGELOG
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

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

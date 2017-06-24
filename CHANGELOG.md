# CHANGELOG

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) [v2.0.0](http://semver.org/spec/v2.0.0.html).

## [2.2.1] - 2017-06-24

We're adding a new environment variable:

  - `ANTIGEN_MUTEX` - Use to configure whether to check for mutex or ignore it.

This configuration effectively controls if the `lock` should work. Alternatively you
may configure which extension you want to load:

    _ANTIGEN_BUILTIN_EXTENSIONS='lock parallel defer cache'

Just remove `lock` from the `_ANTIGEN_BUILTIN_EXTENSIONS` environment variable. Take
into account that this may change in the future.

## Added
- [#561, #563] Add flag to disable mutex check

## Changed
- [#559, #562] Update wiki with all installation options (Debian package, OpenSUSE, Homebrew, etc)
- [#564] Improve README.md installation section and content

## Fixed
- [#569, #565] Avoid compiled theme artifact showing up on completion
- [#558] Fix Makefile's glob used to build logging library if required
- [#555, #557, #556] Fix issue with `ps` command's output being discarded (breaking parallel extension)
- [#571, #568] Fix issues with `typeset` on zsh 5.0.x and below

Thanks everyone who reported issues and provided feedback.

## [2.2.0] - 2017-06-18

We're deploying an extension system to further extend Antigen's functionality.
Core functionality such as parallel install and cache are built upon this system,
see `src/ext`.

Extensions must adhere to a basic interface:

    - `-antigen-{extension-name}-init`
    - `-antigen-{extension-name}-execute`

Both these functions must return 0 or 1 to abort initialization. Example:

    antigen ext custom
    # -antigen-custom-init
    # -antigne-custom-execute

Internally an extension must use Antigen's hook system to retrieve arguments and run custom
functionality:

    - `antigen-add-hook`: antigen-add-hook [antigen-function] [hook-function] ["replace"|"pre"|"post"] ["once"|"repeat"]
    - `antigen-remove-hook`: antigen-remove-hook [hook-function]

### Added
- [#529, #506] Parallel bundle install
- [#542] Reset default library url with antigen-use

### Changed
- [#547, #552] `antigen-theme` command won't switch between themes

### Fixed
- [#550, #548] Fix parallel extension running multiple clone instances
- [#549, #463] Fix compdump missing completions
- [#553] Catch spurious error message by `ps`

Thanks everyone who reported issues and provided feedback.

## [2.1.1] - 2017-05-20

### Changed
- [#537] Clean up README.mkd
- [#534] Add new article on zsh and antigen

### Fixed
- [#540] Don't require confirmation when removing lock
- [#535, #536] Avoid duplicate paths

Thanks everyone who reported issues and provided feedback.

## [2.1.0] - 2017-05-14

### Fixed
- [#525] Use `GIT_TERMINAL_PROMPT=0` to avoid password prompt on clone
- [#511] Clean up globally defined variables

### Added
- [#527] Internal extension system
- [#526] Use mutex to prevent concurrent installations
- [#501] Autodetect config files

### Changed
- [#513] Defer bundle loading to `antigen-apply` command
- [#512] Show warning message when bundle is already 
- [#520] Remove runtime hack to load themes

Thanks everyone who reported issues and provided feedback.

## [2.0.2] - 2017-04-22

### Changed
- [#521, #515] Update TravisCI Badges' labels
- [#509] Use "Roadmap" for Trello where possible

### Added
- [#514] FAQ for dynamic `antigen-theme` usage

### Fixed
- [#510] Remove possibly destructive command on broken tests
- [#508, #507] Fix status code non-zero when last command is `antigen` wrapper

Thanks everyone who reported issues and provided feedback.

## [2.0.1] - 2017-04-15

### Changed
- [#489] Update `CHANGELOG` link to semver documentation
- [#497, #498] Improve `antigen-list` command performance

### Fixed
- [#487] Fix documentation regarding `ANTIGEN_CHECK_FILES`
- [#486, #485] Missing env vars for Oh-My-Zsh 
- [#492, #490] Fix parsing git/ssh URLS
- [#495, #494] Fix `antigen-theme` command changing CWD
- [#493, #491] Fix `no-local-clone` flag being ignored

Thanks everyone who reported issues and provided feedback.

## [2.0.0] - 2017-04-08

There are functions and configurations being either removed or renamed, please
review this document before updating your Antigen installation.

Removed functions:

  - `-antigen-lib`        - Deprecated since v1
  - `-antigen-prezto-lib` - Deprecated since v1

Deprecated configuration:

  - `_ANTIGEN_FORCE_RESET_COMPDUMP`
  - `_ANTIGEN_RESET_THEME_HOOKS`
  - `_ANTIGEN_AUTODETECT_CONFIG_CHANGES`
  - `_ANTIGEN_CACHE_ENABLED`
  - `_ANTIGEN_COMP_ENABLED`

Renamed configuration:

  - `_ANTIGEN_LOG_PATH`     ~> `ANTIGEN_LOG`
  - `_ANTIGEN_CACHE_PATH`   ~> `ANTIGEN_CACHE`
  - `_ANTIGEN_COMPDUMPFILE` ~> `ANTIGEN_COMPDUMP`

Added configurations:

  - `ANTIGEN_CHECK_FILES`     - Use to configure which files to check for changes
  - `ANTIGEN_SUBMODULE_OPTS`  - Use to pass arguments to `git submodule` command
  - `ANTIGEN_CLONE_OPTS`      - Use to pass arguments to `git clone` command
  - `ANTIGEN_BUNDLES`         - Use to configure bundle path location
  - `ANTIGEN_PREZTO_REPO_URL` - Use to configure Prezto default url

### Removed
- [#197, #298] Removed `-antigen-lib`, `-antigen-prezto-lib`

### Added
- [#309] Use `git` shallow cloning to speed up bundle install
- [#299, #261] Handles `$PATH`
- [#415] Added link to multiple OS install methods
- [#423, #262] Support semver-like bundling
- [#461] Use Docker container for tests and stats generation
- [#462, #466] Add extended help text for `antigen-help` command
- [#467, #465] Show version hash on `antgen-version` command
- [#469] Function to migrate old bundle paths to new format
- [#464] Update wiki pages for new version

### Changed
- [#326, #259] Support updating a single bundle
- [#352] Support `antigen-update` tab completion
- [#351, #379] Update `Makefile` release tasks
- [#411, #371, #445] `antigen-list` show version information (tag, branch, git hash)
- [#420] Support reference cache (vs bundle cache)
- [#450] Refactor `_ANTIGEN_BUNDLE_RECORD`
- [#454] Simplify change detection
- [#457, #460] Change bundle path generation function

### Fixed
- [#353] `antigen-update` properly handles `--no-local-clone`
- [#419] Don't require confirmation when cleaning up
- [#439, #442, #438] Fix `antigen-selfupdate` failing with sym-links
- [#441, #440] `antigen-init` command checks input
- [#453, #452] Respect `_ANTIGEN_COMPDUMP` configuration

Thanks everyone who reported issues and provided feedback.

## [1.4.1] - 2017-02-26

### Changed
- [#402, #409] `antigen-use` command handle library url
- [#404, #408] Update README.md with new antigen-related articles

### Fixed
- [#403, #407] Disable OS X builds on TravisCI

Thanks everyone who reported issues and provided feedback.

## [1.4.0] - 2017-02-11

### Changed
- [#386, #387] Use reference cache rather than source bundle

### Fixed
- [#400, #391] Cache library handle environment variables for default libraries

Thanks @lukechilds, @shoeffner and everyone who reported issues and provided feedback.

## [1.3.5] - 2017-02-03

### Changed
- [#393, #392] Add hint in readme to alternative install methods 

### Fixed
- [#398, #396] Add argument completion for `antigen-list` command 
- [#394, #395] Fix syntax issue on zsh 4.3.11 

Thanks @TBird2001, @einSelbst and everyone who reported issues and provided feedback.

## [1.3.4] - 2017-01-16

### Changed
- [#389, #385] `antigen-theme` command load themes from path 

### Fixed
- [#384] Fix updating version references 

Thanks to everyone who reported issues and provided feedback.

## [1.3.3] - 2017-01-07

### Changed
- [#379, #382] Update makefile release tasks
- [#378] Add entry in wiki regarding COMPDUMP location configuration
- [#376] Update README.md with external articles
- [#375, #374] Add LICENSE file to repository

Thanks to everyone who reported issues and provided feedback.

## [1.3.2] - 2016-12-29

### Fixed
- [#367, #368] Fix interactively changing between themes

### Changed
- [#369] Enforce coding style
- [#370, #372] Update README.md with new external articles

Thanks to everyone who reported issues and provided feedback.

## [1.3.1] - 2016-12-17

### Fixed
- [#360, #361] Avoid error when CLOBBER is unset
- [#355, #356] Bundle short name breaks on OSX (BSD sed)

### Changed
- [#363] Added zsh 5.3 to the build pipeline
- [#365, #357] Configure Travis-Ci to build against OS X (10.11, xcode 7.3)
- [#350] Add makefile task to create signed releases
- [#364, #362] Add note about variable handling inside `antigen-bundles` heredoc

Thanks @rltbennett, @rherrick and everyone who reported issues and provided feedback.

## [1.3.0] - 2016-12-10

### Fixed
- [#340, #347] Fix bundle short name broken with branched bundles
- [#341] Improve TravisCI performance

### Changed
- [#343, #344] Add `--short` option for `antigen-list` command

### Added
- [#301, #348] Sign git commits & releases (tags)
- [#337, #345] Theme command tab completion
- [#335, #342] Purge command for removing bundles from file system

Thanks @rugk and everyone who reported issues and provided feedback.

## [1.2.4] - 2016-12-03

### Fixed
- [#321, #322] Fix `antigen-init` command unable to detect bundles
- [#328, #331] Display error message if `antigen-theme` fails to load theme

### Changed
- [#327, #330] Moved `-antigen-echo-record` to `helpers` directory

### Added
- [#323, #329] Add `antigen-init` command entry in `README.md`

Thanks @orf, @VincentBel, @wsargent and everyone who reported issues and
provided feedback.

## [1.2.3] - 2016-11-21

### Fixed
- [#318, #317] Fixed issue with sed regexp format between BSD and GNU

Thanks @john-kurkowski and everyone who reported issues and
provided feedback.

## [1.2.2] - 2016-11-18

### Changed
- [#315, #308] Bundle command returns error if repository is not found 
- [#313, #314] Enhanced cache process-source function 

### Fixed
- [#310, #307] Disabling cache-related commands if cache is disabled
- [#311, #304] Handle bundle's default branch different than master

Thanks @DestyNova, @yacoob, @qstrahl and everyone who reported issues and
provided feedback.

## [1.2.1] - 2016-10-15

Antigen now resets compdump file on `antigen-apply` or with cache resetting (be
it with `antigen-reset` or auto-detecting changes in bundling configuration).
This is necessary to handle completions correctly.
Activate this functionality with `_ANTIGEN_FORCE_RESET_COMPDUMP`, defaults to `true`.

Antigen previously didn't created `$ADOTDIR` explicitly, now it does so on start up.
This directory defaults to `$HOME/.antigen` and it's used to store logs, repositories
and cache files.
    
Theme switching, with `antigen-theme` command, now removes hooks applied by themes.
This is done in order to be able to interactively switch between themes without
issues, such as prompt broken by hooks left by previous themes.
This functionality is actived by default and can be disabled with `_ANTIGEN_RESET_THEME_HOOKS`.

New environment variables:
    - `_ANTIGEN_FORCE_RESET_COMPDUMP`: Whether to force compdump to be reset with
    `antigen-apply` or cache reset.

    - `_ANTIGEN_RESET_THEME_HOOKS`: Whether to remove theme hooks on `antigen-theme`
    command.

### Added
- [#289, #286] Check $ADOTDIR exists on start up

### Changed
- [#291, #281] Reset compdump on apply and cache reset
- [#282] Fixed a simple typo in a code comment regarding git availability

### Fixed
- [#290, #283] Remove theme hooks when changing themes
- [#288, #285] Fix keybindings hook disabled in zcache-done
- [#284] Fix `local`s in themes

Thanks @jordi9, @edqu3, @jmusal, @ming13, @kmikolaj and everyone who reported
issues and provided feedback.

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

[2.2.1]: https://github.com/zsh-users/antigen/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/zsh-users/antigen/compare/v2.1.1...v2.2.0
[2.1.1]: https://github.com/zsh-users/antigen/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/zsh-users/antigen/compare/v2.0.2...v2.1.0
[2.0.2]: https://github.com/zsh-users/antigen/compare/v2.0.1...v2.0.2
[2.0.1]: https://github.com/zsh-users/antigen/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/zsh-users/antigen/compare/v1.4.1...v2.0.0
[1.4.1]: https://github.com/zsh-users/antigen/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/zsh-users/antigen/compare/v1.3.5...v1.4.0
[1.3.5]: https://github.com/zsh-users/antigen/compare/v1.3.4...v1.3.5
[1.3.4]: https://github.com/zsh-users/antigen/compare/v1.3.3...v1.3.4
[1.3.3]: https://github.com/zsh-users/antigen/compare/v1.3.2...v1.3.3
[1.3.2]: https://github.com/zsh-users/antigen/compare/v1.3.1...v1.3.2
[1.3.1]: https://github.com/zsh-users/antigen/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/zsh-users/antigen/compare/v1.2.4...v1.3.0
[1.2.4]: https://github.com/zsh-users/antigen/compare/v1.2.3...v1.2.4
[1.2.3]: https://github.com/zsh-users/antigen/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/zsh-users/antigen/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/zsh-users/antigen/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/zsh-users/antigen/compare/v1.1.4...v1.2.0
[1.1.4]: https://github.com/zsh-users/antigen/compare/v1.1.3...v1.1.4
[1.1.3]: https://github.com/zsh-users/antigen/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/zsh-users/antigen/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/zsh-users/antigen/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/zsh-users/antigen/compare/v1.0.4...v1.1.0
[1.0.4]: https://github.com/zsh-users/antigen/compare/v1.0.3...v1.0.4
[1.0.3]: https://github.com/zsh-users/antigen/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/zsh-users/antigen/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/zsh-users/antigen/compare/v1...v1.0.1

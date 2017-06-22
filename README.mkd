<h1 align="center">
  <a href="https://github.com/zsh-users/antigen"><img src="antigen.png" alt="Antigen"></a>
  <br>
  Antigen <sup>v2</sup>
</h1>
<h4 align="center">The plugin manager for zsh.</h2>

<p align="center">
  <a href="https://github.com/zsh-users/antigen/releases/latest"><img src="https://img.shields.io/github/release/zsh-users/antigen.svg?label=latest" alt="Latest"></a> <a href="http://travis-ci.org/zsh-users/antigen"><img src="https://img.shields.io/travis/zsh-users/antigen/develop.svg?label=develop" alt="Build Status"></a> <a href="http://travis-ci.org/zsh-users/antigen"><img src="https://img.shields.io/travis/zsh-users/antigen/next.svg?label=next" alt="Build Status"></a>
</p>
<p align="center">
  <a href="#installation">Installation</a> | <a href="https://github.com/zsh-users/antigen/wiki">Documentation</a> | <a href="https://github.com/zsh-users/antigen/issues">Bug tracker</a> | <a href="https://trello.com/b/P0xrGgfT/antigen">Roadmap</a> | <a href="https://gitter.im/antigen-zsh/develop">Chat</a> | <a href="http://mit.sharats.me/">License</a>
</p>

Antigen is a small set of functions that help you easily manage your shell (zsh)
plugins, called bundles. The concept is pretty much the same as bundles in a
typical vim+pathogen setup. Antigen is to zsh, what [Vundle][] is to vim.


[![https://asciinema.org/a/cn20v8fy6wrhab4l5kifv6dce](https://asciinema.org/a/cn20v8fy6wrhab4l5kifv6dce.png)](https://asciinema.org/a/cn20v8fy6wrhab4l5kifv6dce)


Antigen has reached a certain level of stability and has been used in the wild
for around a couple of years. If you face any problems, please open an issue.

Antigen works with zsh versions `>= 4.3.11`.

## Installation

Install Antigen from our main repository with the latest stable version available:

    curl -L git.io/antigen > antigen.zsh
    # or use git.io/antigen-nightly for the latest version

There are several installation methods using your System Package manager, just look
at the [Installation][] wiki page.

Now you may head towards the [Commands][] and [Configuration][] wiki pages to further
understand Antigen's functionallity and customization.

## Usage

The usage should be very familiar to you if you use Vundle. A typical `.zshrc`
might look like this:

    source /path-to-antigen/antigen.zsh

    # Load the oh-my-zsh's library.
    antigen use oh-my-zsh

    # Bundles from the default repo (robbyrussell's oh-my-zsh).
    antigen bundle git
    antigen bundle heroku
    antigen bundle pip
    antigen bundle lein
    antigen bundle command-not-found

    # Syntax highlighting bundle.
    antigen bundle zsh-users/zsh-syntax-highlighting

    # Load the theme.
    antigen theme robbyrussell

    # Tell Antigen that you're done.
    antigen apply

Open your zsh with this `.zshrc` and you should see all the bundles you defined
here, getting installed. Once it's done, you are ready to roll. The complete
syntax for the `antigen bundle` command is discussed in the [Commands][] page.

Furthermore, [In the wild][wild] wiki section has more configuration examples. You may
as well take a look at the [Show off][] wiki page
for interactive mode usage.

## Meta

### Motivation

If you use zsh and [oh-my-zsh][], you know that having many different plugins
that are developed by many different authors in a single (sub)repo is not very
easy to maintain. There are some really fantastic plugins and utilities in
oh-my-zsh, but having them all in a single repo doesn't really scale well. And I
admire robbyrussell's efforts for reviewing and merging the gigantic number of
pull requests the project gets. We need a better way of plugin management.

This was discussed on [a][1] [few][2] [issues][3], but it doesn't look like
there was any progress made. So, I'm trying to start this off with Antigen,
hoping to better this situation. Please note that I'm by no means a zsh or any
shell script expert (far from it).

[1]: https://github.com/robbyrussell/oh-my-zsh/issues/465
[2]: https://github.com/robbyrussell/oh-my-zsh/issues/377
[3]: https://github.com/robbyrussell/oh-my-zsh/issues/1014

Inspired by vundle, Antigen can pull oh-my-zsh style plugins from various github
repositories. You are not limited to use plugins from the oh-my-zsh repository
only and you don't need to maintain your own fork and pull from upstream every
now and then. I actually encourage you to grab plugins and scripts from various
sources, straight from the authors, before they even submit it to oh-my-zsh as a
pull request.

Antigen also lets you switch the prompt theme with one command, just like that

    antigen theme candy

and your prompt is changed, just for this session of course (unless you put this
line in your `.zshrc`).

### Helping out

We are always looking for new contributors! We have a number of issues marked
as ["Help wanted"][Help wanted] that are good places to jump in and get started. Take a look at
our [Roadmap][] to see future projects and discuss ideas.

Please be sure to check out our [Contributing guidelines][] to understand our workflow,
and our [Coding conventions][].

### Feedback

Any comments/suggestions/feedback is truly welcome. Please say hello to us on [Gitter][]. Or
open an issue to discuss something (anything!) about the project ;).

### Articles

There are many articles written by Antigen users out there. Be sure to check them out
in the [Articles][Articles] page.

### Plugins and Alternatives

The [awesome-zsh-plugins][] list is a directory of plugins, themes and alternatives that
you may find useful.

[Vundle]: https://github.com/gmarik/vundle
[awesome-zsh-plugins]: https://github.com/unixorn/awesome-zsh-plugins
[wild]: https://github.com/zsh-users/antigen/wiki/In-the-wild
[oh-my-zsh]: https://github.com/robbyrussell/oh-my-zsh
[issue]: https://github.com/zsh-users/antigen/issues
[license]: http://mit.sharats.me
[contributing]: https://github.com/zsh-users/antigen/wiki/Contributing
[wiki]: https://github.com/zsh-users/antigen/wiki
[Commands]: https://github.com/zsh-users/antigen/wiki/Commands
[Installation]: https://github.com/zsh-users/antigen/wiki/Installation
[Configuration]: https://github.com/zsh-users/antigen/wiki/Configuration
[Show off]: https://github.com/zsh-users/antigen/wiki/Show-off
[Help wanted]: https://github.com/zsh-users/antigen/issues?q=is%3Aissue+is%3Aopen+label%3A%22Help+wanted%22
[Roadmap]: https://trello.com/b/P0xrGgfT/antigen
[Contributing guidelines]: https://github.com/zsh-users/antigen/wiki/Contributing
[Coding conventions]: https://github.com/zsh-users/antigen/wiki/Styleguide
[Gitter]: https://gitter.im/antigen-zsh/develop
[Articles]: https://github.com/zsh-users/antigen/wiki/Articles 

# Brewdler

Bundler for non-Ruby dependencies from Homebrew

[![Code Climate](https://codeclimate.com/github/Homebrew/homebrew-brewdler/badges/gpa.svg)](https://codeclimate.com/github/Homebrew/homebrew-brewdler)
[![Coverage Status](https://coveralls.io/repos/Homebrew/homebrew-brewdler/badge.svg)](https://coveralls.io/r/Homebrew/homebrew-brewdler)
[![Build Status](https://travis-ci.org/Homebrew/homebrew-brewdler.svg)](https://travis-ci.org/Homebrew/homebrew-brewdler)

## Requirements

[Homebrew](http://github.com/Homebrew/homebrew) is used for installing the dependencies, it only works on OS X and so does this tool.

[brew tap](https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/brew-tap.md) is new feature in Homebrew 0.9, adds more GitHub repos to the list of available formulae.

[Homebrew-cask](http://github.com/caskroom/homebrew-cask) is optional and used for installing Mac applications.

## Install

You can install as a Homebrew tap:

    $ brew tap Homebrew/brewdler

## Usage

Create a `Brewfile` in the root of your project:

    $ touch Brewfile

Then list your Homebrew based dependencies in your `Brewfile`:

    tap 'caskroom/cask'
    brew 'emacs', args: ['cocoa', 'srgb', 'with-gnutls']
    brew 'redis'
    brew 'mongodb'
    brew 'sphinx'
    brew 'imagemagick'
    brew 'mysql'
    cask 'google-chrome'

You can then easily install all of the dependencies with one of the following commands:

    $ brew brewdle

### Dump

You can create a `Brewfile` from all the existing Homebrew packages you have installed with:

    $ brew brewdle dump

The `--force` option will allow an existing `Brewfile` to be overwritten as well.

### Cleanup

You can also use `Brewfile` as a whitelist. It's useful for maintainers/testers who regularly install lots of formulae. To uninstall all Homebrew formulae not listed in `Brewfile`:

    $ brew brewdle cleanup

If `--dry-run` option is passed, brewdler will list formulae rather than actually uninstalling them.

## Note

Homebrew does not support installing specific versions of a library, only the most recent one so there is no good mechanism for storing installed versions in a .lock file.

If your software needs specific versions then perhaps you'll want to look at using [Vagrant](http://vagrantup.com/) to better match your development and production environments.

(Or there is always MacPorts...)

## Contributors

Over 10 different people have contributed to the project, you can see them all here: https://github.com/Homebrew/homebrew-brewdler/graphs/contributors

## Development

Source hosted at [GitHub](http://github.com/Homebrew/homebrew-brewdler).
Report Issues/Feature requests on [GitHub Issues](http://github.com/Homebrew/homebrew-brewdler/issues).

Tests can be ran with `rake spec`

### Note on Patches/Pull Requests

 * Fork the project.
 * Make your feature addition or bug fix.
 * Add tests for it. This is important so I don't break it in a future version unintentionally.
 * Add documentation if necessary.
 * Commit, do not change Rakefile or history.
 * Send a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2015 Andrew Nesbitt. See [LICENSE](https://github.com/Homebrew/homebrew-brewdler/blob/master/LICENSE) for details.

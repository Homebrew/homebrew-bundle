# Brewdler

Bundler for non-Ruby dependencies from Homebrew

[![Gem Version](https://badge.fury.io/rb/brewdler.svg)](http://badge.fury.io/rb/homebrew-brewdler)
[![Dependency Status](https://gemnasium.com/Homebrew/homebrew-brewdler.svg)](https://gemnasium.com/Homebrew/homebrew-brewdler)
[![Code Climate](https://codeclimate.com/github/Homebrew/homebrew-brewdler/badges/gpa.svg)](https://codeclimate.com/github/Homebrew/homebrew-brewdler)
[![Coverage Status](https://coveralls.io/repos/Homebrew/homebrew-brewdler/badge.svg)](https://coveralls.io/r/Homebrew/homebrew-brewdler)
[![Build Status](https://travis-ci.org/Homebrew/homebrew-brewdler.svg)](https://travis-ci.org/Homebrew/homebrew-brewdler)

## Requirements

[Homebrew](http://github.com/Homebrew/homebrew) is used for installing the dependencies, it only works on OS X and so does this gem.

[brew tap](https://github.com/Homebrew/homebrew/blob/master/share/doc/homebrew/brew-tap.md) is new feature in Homebrew 0.9, adds more GitHub repos to the list of available formulae.

[Homebrew-cask](http://github.com/caskroom/homebrew-cask) is optional and used for installing Mac applications.

## Install

You can install as a Homebrew tap:

    $ brew tap Homebrew/homebrew-brewdler

or you can install it via RubyGems:

    $ gem install brewdler

## Usage

Create a `Brewfile` in the root of your project:

    $ touch Brewfile

Then list your Homebrew based dependencies in your `Brewfile`:

    tap 'phinze/cask'
    brew 'emacs', args: ['cocoa', 'srgb', 'with-gnutls']
    brew 'redis'
    brew 'mongodb'
    brew 'sphinx'
    brew 'imagemagick'
    brew 'mysql'
    cask 'google-chrome'

You can then easily install all of the dependencies with one of the following commands:

    $ brewdle install # installed from RubyGems
    $ brew brewdle # installed from Homebrew tap

## Note

Homebrew does not support installing specific versions of a library, only the most recent one so there is no good mechanism for storing installed versions in a .lock file.

If your software needs specific versions then perhaps you'll want to look at using [Vagrant](http://vagrantup.com/) to better match your development and production environments.

(Or there is always MacPorts...)

## Development

Source hosted at [GitHub](http://github.com/Homebrew/homebrew-brewdler).
Report Issues/Feature requests on [GitHub Issues](http://github.com/Homebrew/homebrew-brewdler/issues).

### Note on Patches/Pull Requests

 * Fork the project.
 * Make your feature addition or bug fix.
 * Add tests for it. This is important so I don't break it in a
   future version unintentionally.
 * Commit, do not mess with Rakefile, version, or history.
   (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
 * Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2015 Andrew Nesbitt. See LICENSE for details.

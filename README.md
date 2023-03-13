# Homebrew Bundle

Bundler for non-Ruby dependencies from Homebrew, Homebrew Cask, Mac App Store and Whalebrew.

## Requirements

[Homebrew](https://github.com/Homebrew/brew) (on macOS or [Linux](https://docs.brew.sh/Homebrew-on-Linux)) for installing dependencies.

[Homebrew Cask](https://github.com/Homebrew/homebrew-cask) is optional and used for installing Mac applications.

[mas-cli](https://github.com/mas-cli/mas) is optional and used for installing Mac App Store applications.

[Whalebrew](https://github.com/whalebrew/whalebrew) is optional and used for installing Whalebrew images.

## Installation

`brew bundle` is automatically installed when first run.

## Usage

See [the `brew bundle` section of the `brew generate-man-completions` output](https://docs.brew.sh/Manpage#bundle-subcommand) or `brew bundle --help`.

An example `Brewfile`:

```ruby
# 'brew tap'
tap "homebrew/cask"
# 'brew tap' with custom Git URL
tap "user/tap-repo", "https://user@bitbucket.org/user/homebrew-tap-repo.git"
# 'brew tap' with arguments
tap "user/tap-repo", "https://user@bitbucket.org/user/homebrew-tap-repo.git", force_auto_update: true

# set arguments for all 'brew install --cask' commands
cask_args appdir: "~/Applications", require_sha: true

# 'brew install'
brew "imagemagick"
# 'brew install --with-rmtp', 'brew services restart' on version changes
brew "denji/nginx/nginx-full", args: ["with-rmtp"], restart_service: :changed
# 'brew install', always 'brew services restart', 'brew link', 'brew unlink mysql' (if it is installed)
brew "mysql@5.6", restart_service: true, link: true, conflicts_with: ["mysql"]
# install only on specified OS
brew "gnupg" if OS.mac?
brew "glibc" if OS.linux?

# 'brew install --cask'
cask "google-chrome"
# 'brew install --cask --appdir=~/my-apps/Applications'
cask "firefox", args: { appdir: "~/my-apps/Applications" }
# bypass Gatekeeper protections (NOT RECOMMENDED)
cask "firefox", args: { no_quarantine: true }
# always upgrade auto-updated or unversioned cask to latest version even if already installed
cask "opera", greedy: true
# 'brew install --cask' only if '/usr/libexec/java_home --failfast' fails
cask "java" unless system "/usr/libexec/java_home --failfast"

# 'mas install'
mas "1Password", id: 443987910

# 'whalebrew install'
whalebrew "whalebrew/wget"
```

## Versions and lockfiles

Homebrew does not support installing specific versions of a library, only the most recent one, so there is no mechanism for installing specific versions given only a `.lock` file.

If your software needs specific versions, consider [Vagrant](https://vagrantup.com/), Docker (perhaps with [whalebrew](https://github.com/whalebrew/whalebrew), which homebrew-bundle supports), or another tool to install versions explicitly.

After bundle installation, homebrew-bundle creates a `Brewfile.lock.json`. This file is for information purposes only as a record of the last successful `brew bundle`. Its presence does not change the result or behavior of `brew bundle`, but it can be useful as a record of a previous success when a subsequent `brew bundle` fails. It's probably not useful to commit to `git` or other version control, as it can contain local system info that varies between systems.

Disable generation of the `Brewfile.lock.json` file by setting the environment variable with `export HOMEBREW_BUNDLE_NO_LOCK=1` or by using command-line argument `brew bundle --no-lock`.

## Tests

Tests can be run with `bundle install && bundle exec rspec`.

## Copyright

Copyright (c) Homebrew maintainers and Andrew Nesbitt. See [LICENSE](https://github.com/Homebrew/homebrew-bundle/blob/HEAD/LICENSE) for details.

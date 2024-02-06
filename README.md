# Homebrew Bundle

Bundler for non-Ruby dependencies from Homebrew, Homebrew Cask, Mac App Store, Whalebrew and Visual Studio Code.

## Requirements

[Homebrew](https://github.com/Homebrew/brew) (on macOS or [Linux](https://docs.brew.sh/Homebrew-on-Linux)) for installing dependencies.

[Homebrew Cask](https://github.com/Homebrew/homebrew-cask) is optional and used for installing Mac applications.

[mas-cli](https://github.com/mas-cli/mas) is optional and used for installing Mac App Store applications.

[Whalebrew](https://github.com/whalebrew/whalebrew) is optional and used for installing Whalebrew images.

[Visual Studio Code](https://code.visualstudio.com/) is optional and used for installing Visual Studio Code extensions.

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
cask "java" unless system "/usr/libexec/java_home", "--failfast"

# 'mas install'
mas "1Password", id: 443_987_910

# 'whalebrew install'
whalebrew "whalebrew/wget"

# 'vscode --install-extension'
vscode "GitHub.codespaces"
```

## Versions and lockfiles

Homebrew is a [rolling release](https://en.wikipedia.org/wiki/Rolling_release) package manager so it does not support installing arbitrary older versions of software.
If your software needs specific pinned versions, consider [`whalebrew`](https://github.com/whalebrew/whalebrew) lines in your `Brewfile` to install [Docker](https://www.docker.com) containers.

After a successful `brew bundle` run, it creates a `Brewfile.lock.json` to record the environment. If a future `brew bundle` run fails, you can check the differences between `Brewfile.lock.json` to debug. As it can contain local environment information that varies between systems, it's not worth committing to version control on multi-user repositories.

Disable generation of the `Brewfile.lock.json` file by setting the environment variable with `export HOMEBREW_BUNDLE_NO_LOCK=1` or by using the command-line argument `brew bundle --no-lock`.

## Tests

Tests can be run with `bundle install && bundle exec rspec`.

## Copyright

Copyright (c) Homebrew maintainers and Andrew Nesbitt. See [LICENSE](https://github.com/Homebrew/homebrew-bundle/blob/HEAD/LICENSE) for details.

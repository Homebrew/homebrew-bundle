#:  * `bundle` <subcommand>
#:
#:  Bundler for non-Ruby dependencies from Homebrew, Homebrew Cask and the Mac App Store.
#:
#:       --file=                        read the `Brewfile` from this file. Use `--file=-` to output to stdin/stdout.
#:       --global                       read the `Brewfile` from `~/.Brewfile`.
#:
#:  `brew bundle` [`install`] [`-v`|`--verbose`] [`--no-upgrade`] [`--file=`<path>|`--global`]
#:
#:  Install or upgrade all dependencies in a Brewfile.
#:
#:       -v, --verbose                  print the output from commands as they are run.
#:       --no-upgrade                   don't run `brew upgrade` on outdated dependencies. Note they may still be upgraded by `brew install` if needed.
#:
#:  `brew bundle dump` [`--force`] [`--describe`] [`--file=`<path>|`--global`]
#:
#:  Write all installed casks/formulae/taps into a Brewfile.
#:
#:       --force                        overwrite an existing `Brewfile`.
#:       --describe                     output a description comment above each line. This comment will not be output if the dependency does not have a description.
#:
#:  `brew bundle cleanup` [`--force`] [`--zap`] [`--file=`<path>|`--global`]
#:
#:  Uninstall all dependencies not listed in a Brewfile.
#:
#:       --force                        actually perform the cleanup operations.
#:       --zap                          casks will be removed using the `zap` command instead of `uninstall`.
#:
#:  `brew bundle check` [`--no-upgrade`] [`--file=`<path>|`--global`] [`--verbose`]
#:
#:  Check if all dependencies are installed in a Brewfile.
#:
#:       --no-upgrade                   ignore outdated dependencies.
#:       -v, --verbose                  output and check for all missing dependencies.
#:
#:  `brew bundle exec` <command>
#:
#:  Run an external command in an isolated build environment.
#:
#:  `brew bundle list` [`--all`|`--brews`|`--casks`|`--taps`|`--mas`] [`--file=`<path>|`--global`]
#:
#:  List all dependencies present in a Brewfile. By default, only brew dependencies are output.
#:
#:       --all                          output all dependencies.
#:       --brews                        output Homebrew dependencies.
#:       --casks                        output Homebrew Cask dependencies.
#:       --taps                         output tap dependencies.
#:       --mas                          output Mac App Store dependencies.

if !defined?(HOMEBREW_VERSION) || !HOMEBREW_VERSION ||
   Version.new(HOMEBREW_VERSION) < Version.new("1.3.0")
  odie "Your Homebrew is outdated. Please run `brew update`."
end

BUNDLE_ROOT = File.expand_path "#{File.dirname(__FILE__)}/.."
BUNDLE_LIB = Pathname.new(BUNDLE_ROOT)/"lib"

$LOAD_PATH.unshift(BUNDLE_LIB)

# Add `brew` back to the PATH if it was filtered out.
brew_bin = File.dirname ENV["HOMEBREW_BREW_FILE"]
ENV["PATH"] = "#{ENV["PATH"]}:#{brew_bin}" unless ENV["PATH"].include?(brew_bin)

require "bundle"

# Pop the named command from ARGV, leaving everything else in place
command = ARGV.named.first
ARGV.delete_at(ARGV.index(command)) unless command.nil?
begin
  case command
  when nil, "install"
    Bundle::Commands::Install.run
  when "dump"
    Bundle::Commands::Dump.run
  when "cleanup"
    Bundle::Commands::Cleanup.run
  when "check"
    Bundle::Commands::Check.run
  when "exec"
    Bundle::Commands::Exec.run
  when "list"
    Bundle::Commands::List.run
  else
    onoe "Unknown command `#{command}`!"
    abort `brew bundle --help`
  end
rescue SystemExit => e
  Homebrew.failed = true unless e.success?
  puts "Kernel.exit" if ARGV.debug?
rescue Interrupt
  puts # seemingly a newline is typical
  Homebrew.failed = true
rescue RuntimeError, SystemCallError => e
  raise if e.message.empty?
  onoe e
  puts e.backtrace if ARGV.debug?
  Homebrew.failed = true
rescue => e
  onoe e
  puts "#{Tty.bold}Please report this bug:#{Tty.reset}"
  puts "    #{Formatter.url("https://github.com/Homebrew/homebrew-bundle/issues/")}"
  puts e.backtrace
  Homebrew.failed = true
end

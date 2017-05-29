#:  * `bundle` <command>:
#:    Bundler for non-Ruby dependencies from Homebrew.
#:
#:    `brew bundle` [-v|--verbose] [--no-upgrade] [--file=<path>|--global]:
#:    Install or upgrade all dependencies in a Brewfile.
#:
#:    `brew bundle dump` [--force] [--file=<path>|--global]
#:    Write all installed casks/formulae/taps into a Brewfile.
#:
#:    `brew bundle cleanup` [--force] [--file=<path>|--global]
#:    Uninstall all dependencies not listed in a Brewfile.
#:
#:    `brew bundle check` [--no-upgrade] [--file=<path>|--global]
#:    Check if all dependencies are installed in a Brewfile.
#:
#:    `brew bundle exec` [command]
#:    Run an external command in an isolated build environment.
#:
#:    If `-v` or `--verbose` are passed, print verbose output.
#:
#:    If `--no-upgrade` is passed, don't run `brew upgrade` outdated dependencies.
#:    Note they may still be upgraded by `brew install` if needed.
#:
#:    If `--force` is passed, uninstall dependencies or overwrite an existing
#:    Brewfile.
#:
#:    If `--file=<path>` is passed, the Brewfile path is set accordingly (use
#:    `--file=-` to output to console).
#:
#:    If `--global` is passed, set Brewfile path to `$HOME/.Brewfile`.
#:
#:    If `-h` or `--help` are passed, print this help message and exit.

# Homebrew version check
# commit cf71e30180d44219836ef129d5e5f00325210dfb
MIN_HOMEBREW_COMMIT_DATE = Time.parse "Wed Aug 17 11:07:17 2016 +0100"
HOMEBREW_REPOSITORY.cd do
  if MIN_HOMEBREW_COMMIT_DATE > Time.parse(`git show -s --format=%cD`)
    odie "Your Homebrew is outdated. Please run `brew update`."
  end
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
  else
    onoe "Unknown command `#{command}`!"
    abort `brew bundle --help`
  end
rescue SystemExit
  puts "Kernel.exit" if ARGV.verbose?
  raise
rescue Interrupt
  puts # seemingly a newline is typical
  exit 130
rescue RuntimeError, SystemCallError => e
  raise if e.message.empty?
  onoe e
  puts e.backtrace if ARGV.debug?
  exit 1
rescue StandardError => e
  onoe e
  puts "#{Tty.white}Please report this bug:#{Tty.reset}"
  puts "    #{Formatter.url("https://github.com/Homebrew/homebrew-bundle/issues/")}"
  puts e.backtrace
  exit 1
end

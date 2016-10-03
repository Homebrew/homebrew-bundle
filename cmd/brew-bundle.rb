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

require "bundle"

usage = <<-EOS.undent
  brew bundle [-v|--verbose] [--file=<path>|--global]
  brew bundle dump [--force] [--file=<path>|--global]
  brew bundle cleanup [--force] [--file=<path>|--global]
  brew bundle check [--file=<path>|--global]
  brew bundle exec [command]
  brew bundle [--version]
  brew bundle [-h|--help]

  Usage:
  Bundler for non-Ruby dependencies from Homebrew

  brew bundle            install or upgrade all dependencies in a Brewfile
  brew bundle dump       write all installed casks/formulae/taps into a Brewfile
  brew bundle cleanup    uninstall all dependencies not listed in a Brewfile
  brew bundle check      check if all dependencies are installed in a Brewfile
  brew bundle exec       run an external command in an isolated build environment

  Options:
  -v, --verbose          print verbose output
  --force                uninstall dependencies or overwrite existing Brewfile
  --file=<path>          set Brewfile path (use --file=- to output to console)
  --global               set Brewfile path to $HOME/.Brewfile
  -h, --help             show this help message and exit
  --version              show the version of homebrew-bundle
EOS

if ARGV.include?("--version")
  puts Bundle::VERSION
  exit 0
end

if ARGV.flag?("--help")
  puts usage
  exit 0
end

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
    abort usage
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
rescue Exception => e
  onoe e
  puts "#{Tty.white}Please report this bug:#{Tty.reset}"
  puts "    #{Formatter.url("https://github.com/Homebrew/homebrew-bundle/issues/")}"
  puts e.backtrace
  exit 1
end

#!/usr/bin/env ruby

BUNDLE_ROOT = File.expand_path "#{File.dirname(__FILE__)}/.."
BUNDLE_LIB = Pathname.new(BUNDLE_ROOT)/"lib"

$LOAD_PATH.unshift(BUNDLE_LIB)

require "bundle"

usage = <<-EOS.undent
  brew bundle [-v|--verbose] [--file=<path>|--global] [--install-only]
  brew bundle dump [--force] [--file=<path>|--global]
  brew bundle cleanup [--dry-run] [--file=<path>|--global]
  brew bundle [--version]
  brew bundle [-h|--help]

  Usage:
  Bundler for non-Ruby dependencies from Homebrew

  brew bundle            read Brewfile and install and upgrade all dependencies
  brew bundle dump       write all currently installed packages into a Brewfile
  brew bundle cleanup    uninstall all Homebrew formulae not listed in Brewfile

  Options:
  -v, --verbose          print verbose output
  --force                force overwrite existed Brewfile
  --dry-run              list formulae rather than actual uninstalling them
  --file=<path>          set Brewfile path
  --global               set Brewfile path to $HOME/.Brewfile
  --install-only         do not upgrade existing formulae, just install new
  -h, --help             show this help message and exit
  --version              show the version of bundle
EOS

if ARGV.include?("--version")
  puts Bundle::VERSION
  exit 0
end

if ARGV.flag?("--help")
  puts usage
  exit 0
end

case ARGV.named[0]
when nil, "install"
  Bundle::Commands::Install.run
when "dump"
  Bundle::Commands::Dump.run
when "cleanup"
  Bundle::Commands::Cleanup.run
else
  abort usage
end

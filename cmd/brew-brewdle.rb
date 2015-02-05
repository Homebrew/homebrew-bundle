#!/usr/bin/env ruby

BREWDLER_ROOT = File.expand_path "#{File.dirname(__FILE__)}/.."
BREWDLER_LIB = Pathname.new(BREWDLER_ROOT)/"lib"

$LOAD_PATH.unshift(BREWDLER_LIB)

require "brewdler"

usage = <<-EOS.undent
  brew brewdle
  brew brewdle [--version]
  brew brewdle [-h|--help]

  Usage:
  Bundler for non-Ruby dependencies from Homebrew

  Options:
  -h, --help        show this help message and exit
  --version         show the version of brewdler
EOS

if ARGV.include?("--version")
  puts Brewdler::VERSION
  exit 0
end

if ARGV.flag?("--help")
  puts usage
  exit 0
end

case ARGV.named[0]
when nil, "install"
  Brewdler::Commands::Install.run
else
  abort usage
end


# frozen_string_literal: true

require "cli/parser"
module Homebrew
  module_function

  def bundle_args
    Homebrew::CLI::Parser.new do
      usage_banner <<~EOS
        `bundle` <subcommand>

        Bundler for non-Ruby dependencies from Homebrew, Homebrew Cask and the Mac App Store.

          `brew bundle` [`install`]

          Install or upgrade all dependencies in a `Brewfile`.

          `brew bundle dump`

          Write all installed casks/formulae/taps into a `Brewfile`.

          `brew bundle cleanup`

          Uninstall all dependencies not listed in a `Brewfile`.

          `brew bundle check`

          Check if all dependencies are installed in a `Brewfile`.

          `brew bundle exec` <command>

          Run an external command in an isolated build environment.

          `brew bundle list`

          List all dependencies present in a Brewfile. By default, only Homebrew dependencies are listed.
      EOS
      flag "--file=",
           description: "Read the `Brewfile` from this file. Use `--file=-` to pipe to stdin/stdout."
      switch "--global",
             description: "Read the `Brewfile` from `~/.Brewfile`."
      switch :verbose,
             description: "`install` output is printed from commands as they are run. `check` prints all missing dependencies."
      switch "--no-upgrade",
             description: "`install` won't run `brew upgrade` on outdated dependencies. Note they may still be upgraded by `brew install` if needed."
      switch :force,
             description: "`dump` overwrites an existing `Brewfile`. `cleanup` actually perform the cleanup operations."
      switch "--no-lock",
             description: "`install` won't output a `Brewfile.lock.json`."
      switch "--all",
             description: "`list` all dependencies."
      switch "--brews",
             description: "`list` Homebrew dependencies."
      switch "--casks",
             description: "`list` Homebrew Cask dependencies."
      switch "--taps",
             description: "`list` tap dependencies."
      switch "--mas",
             description: "`list` Mac App Store dependencies."
      switch "--describe",
             description: "`dump` a description comment above each line, unless the dependency does not have a description."
      switch "--no-restart",
             description: "`dump` does not add `restart_service` to formula lines."
      switch "--zap",
             description: "`cleanup` casks using the `zap` command instead of `uninstall`."
    end
  end

  def bundle
    bundle_args.parse

    # Keep this after the .parse to keep --help fast.
    require_relative "../lib/bundle"

    begin
      case subcommand = Homebrew.args.named.first.presence
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
        raise UsageError, "Unknown subcommand `#{subcommand}`!"
      end
    rescue SystemExit => e
      Homebrew.failed = true unless e.success?
      puts "Kernel.exit" if Homebrew.args.debug?
    rescue Interrupt
      puts # seemingly a newline is typical
      Homebrew.failed = true
    rescue RuntimeError, SystemCallError => e
      raise if e.message.empty?

      onoe e
      puts e.backtrace if Homebrew.args.debug?
      Homebrew.failed = true
    rescue => e
      onoe e
      puts "#{Tty.bold}Please report this bug:#{Tty.reset}"
      puts "  #{Formatter.url("https://github.com/Homebrew/homebrew-bundle/issues")}"
      puts e.backtrace
      Homebrew.failed = true
    end
  end
end

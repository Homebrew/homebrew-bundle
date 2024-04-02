# frozen_string_literal: true

require "abstract_command"

module Homebrew
  module Cmd
    class BundleCmd < AbstractCommand
      cmd_args do
        usage_banner <<~EOS
          `bundle` [<subcommand>]

          Bundler for non-Ruby dependencies from Homebrew, Homebrew Cask, Mac App Store, Whalebrew and Visual Studio Code.

          `brew bundle` [`install`]:
          Install and upgrade (by default) all dependencies from the `Brewfile`.

          You can specify the `Brewfile` location using `--file` or by setting the `HOMEBREW_BUNDLE_FILE` environment variable.

          You can skip the installation of dependencies by adding space-separated values to one or more of the following environment variables: `HOMEBREW_BUNDLE_BREW_SKIP`, `HOMEBREW_BUNDLE_CASK_SKIP`, `HOMEBREW_BUNDLE_MAS_SKIP`, `HOMEBREW_BUNDLE_WHALEBREW_SKIP`, `HOMEBREW_BUNDLE_TAP_SKIP`.

          `brew bundle` will output a `Brewfile.lock.json` in the same directory as the `Brewfile` if all dependencies are installed successfully. This contains dependency and system status information which can be useful for debugging `brew bundle` failures and replicating a "last known good build" state. You can opt-out of this behaviour by setting the `HOMEBREW_BUNDLE_NO_LOCK` environment variable or passing the `--no-lock` option. You may wish to check this file into the same version control system as your `Brewfile` (or ensure your version control system ignores it if you'd prefer to rely on debugging information from a local machine).

          `brew bundle dump`:
          Write all installed casks/formulae/images/taps into a `Brewfile` in the current directory.

          `brew bundle cleanup`:
          Uninstall all dependencies not present in the `Brewfile`.

          This workflow is useful for maintainers or testers who regularly install lots of formulae.

          `brew bundle check`:
          Check if all dependencies present in the `Brewfile` are installed.

          This provides a successful exit code if everything is up-to-date, making it useful for scripting.

          `brew bundle list`:
          List all dependencies present in the `Brewfile`.

          By default, only Homebrew formula dependencies are listed.

          `brew bundle exec` <command>:
          Run an external command in an isolated build environment based on the `Brewfile` dependencies.

          This sanitized build environment ignores unrequested dependencies, which makes sure that things you didn't specify in your `Brewfile` won't get picked up by commands like `bundle install`, `npm install`, etc. It will also add compiler flags which will help with finding keg-only dependencies like `openssl`, `icu4c`, etc.
        EOS
        flag "--file=",
             description: "Read the `Brewfile` from this location. Use `--file=-` to pipe to stdin/stdout."
        switch "--global",
               description: "Read the `Brewfile` from `~/.Brewfile` or " \
                            "the `HOMEBREW_BUNDLE_FILE_GLOBAL` environment variable, if set."
        switch "-v", "--verbose",
               description: "`install` prints output from commands as they are run. " \
                            "`check` lists all missing dependencies."
        switch "--no-upgrade",
               description: "`install` does not run `brew upgrade` on outdated dependencies. " \
                            "Note they may still be upgraded by `brew install` if needed."
        switch "-f", "--force",
               description: "`install` runs with `--force`/`--overwrite`. " \
                            "`dump` overwrites an existing `Brewfile`. " \
                            "`cleanup` actually performs its cleanup operations."
        switch "--cleanup",
               env:         :bundle_install_cleanup,
               description: "`install` performs cleanup operation, same as running `cleanup --force`. " \
                            "This is enabled by default if `HOMEBREW_BUNDLE_INSTALL_CLEANUP` is set and " \
                            "`--global` is passed."
        switch "--no-lock",
               description: "`install` does not output a `Brewfile.lock.json`."
        switch "--all",
               description: "`list` all dependencies."
        switch "--formula", "--brews",
               description: "`list` Homebrew formula dependencies."
        switch "--cask", "--casks",
               description: "`list` Homebrew cask dependencies."
        switch "--tap", "--taps",
               description: "`list` Homebrew tap dependencies."
        switch "--mas",
               description: "`list` Mac App Store dependencies."
        switch "--whalebrew",
               description: "`list` Whalebrew dependencies."
        switch "--vscode",
               description: "`list` VSCode extensions."
        switch "--describe",
               env:         :bundle_dump_describe,
               description: "`dump` adds a description comment above each line, unless the " \
                            "dependency does not have a description. " \
                            "This is enabled by default if `HOMEBREW_BUNDLE_DUMP_DESCRIBE` is set."
        switch "--no-restart",
               description: "`dump` does not add `restart_service` to formula lines."
        switch "--zap",
               description: "`cleanup` casks using the `zap` command instead of `uninstall`."
      end

      def run
        # Keep this inside `run` to keep --help fast.
        require_relative "../lib/bundle"

        begin
          case subcommand = args.named.first.presence
          when nil, "install"
            Bundle::Commands::Install.run(
              global:     args.global?,
              file:       args.file,
              no_lock:    args.no_lock?,
              no_upgrade: args.no_upgrade?,
              verbose:    args.verbose?,
              force:      args.force?,
            )

            cleanup = if ENV.fetch("HOMEBREW_BUNDLE_INSTALL_CLEANUP", nil)
              args.global?
            else
              args.cleanup?
            end

            if cleanup
              Bundle::Commands::Cleanup.run(
                global: args.global?,
                file:   args.file,
                force:  true,
                zap:    args.zap?,
              )
            end
          when "dump"
            Bundle::Commands::Dump.run(
              global:     args.global?,
              file:       args.file,
              describe:   args.describe?,
              force:      args.force?,
              no_restart: args.no_restart?,
              all:        args.all?,
              taps:       args.taps?,
              brews:      args.brews?,
              casks:      args.casks?,
              mas:        args.mas?,
              whalebrew:  args.whalebrew?,
              vscode:     args.vscode?,
            )
          when "cleanup"
            Bundle::Commands::Cleanup.run(
              global: args.global?,
              file:   args.file,
              force:  args.force?,
              zap:    args.zap?,
            )
          when "check"
            Bundle::Commands::Check.run(
              global:     args.global?,
              file:       args.file,
              no_upgrade: args.no_upgrade?,
              verbose:    args.verbose?,
            )
          when "exec"
            _subcommand, *named_args = args.named
            Bundle::Commands::Exec.run(
              *named_args,
              global: args.global?,
              file:   args.file,
            )
          when "list"
            Bundle::Commands::List.run(
              global:    args.global?,
              file:      args.file,
              all:       args.all?,
              casks:     args.casks?,
              taps:      args.taps?,
              mas:       args.mas?,
              whalebrew: args.whalebrew?,
              vscode:    args.vscode?,
              brews:     args.brews?,
            )
          else
            raise UsageError, "unknown subcommand: #{subcommand}"
          end
        rescue SystemExit => e
          Homebrew.failed = true unless e.success?
          puts "Kernel.exit" if args.debug?
        rescue Interrupt
          puts # seemingly a newline is typical
          Homebrew.failed = true
        rescue RuntimeError, SystemCallError => e
          raise if e.message.empty?

          onoe e
          puts e.backtrace if args.debug?
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
  end
end

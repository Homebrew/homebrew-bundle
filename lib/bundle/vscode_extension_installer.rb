# frozen_string_literal: true

module Bundle
  module VscodeExtensionInstaller
    module_function

    def reset!
      @installed_extensions = nil
    end

    def preinstall(name, no_upgrade: false, verbose: false)
      if !Bundle.vscode_installed? && Bundle.cask_installed?
        puts "Installing visual-studio-code. It is not currently installed." if verbose
        Bundle.system HOMEBREW_BREW_FILE, "install", "--cask", "visual-studio-code", verbose:
      end

      if extension_installed?(name)
        puts "Skipping install of #{name} VSCode extension. It is already installed." if verbose
        return false
      end

      raise "Unable to install #{name} VSCode extension. VSCode is not installed." unless Bundle.vscode_installed?

      true
    end

    def exchange_uid(&block)
      euid = Process.euid
      uid = Process.uid
      return yield if euid == uid

      old_euid = euid
      process_reexchangeable = Process::UID.re_exchangeable?
      if process_reexchangeable
        Process::UID.re_exchange
      else
        Process::Sys.seteuid(uid)
      end

      return_value = with_env("HOME" => Etc.getpwuid(Process.uid).dir, &block)

      if process_reexchangeable
        Process::UID.re_exchange
      else
        Process::Sys.seteuid(old_euid)
      end

      return_value
    end

    def install(name, preinstall: true, no_upgrade: false, verbose: false, force: false)
      return true unless preinstall
      return true if extension_installed?(name)

      puts "Installing #{name} VSCode extension. It is not currently installed." if verbose

      return false unless exchange_uid do
        Bundle.system("code", "--install-extension", name, verbose:)
      end

      installed_extensions << name

      true
    end

    def extension_installed?(name)
      installed_extensions.include? name.downcase
    end

    def installed_extensions
      @installed_extensions ||= Bundle::VscodeExtensionDumper.extensions
    end
  end
end

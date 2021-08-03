# frozen_string_literal: true

module Bundle
  module CaskInstaller
    module_function

    def reset!
      @installed_casks = nil
      @outdated_casks = nil
      @greedy_outdated_casks = nil
    end

    def upgrading?(no_upgrade, name, options)
      return false if no_upgrade
      return true if outdated_casks.include?(name)
      return false unless options[:greedy]

      greedy_outdated_casks.include?(name)
    end

    def preinstall(name, no_upgrade: false, verbose: false, **options)
      if installed_casks.include?(name) && !upgrading?(no_upgrade, name, options)
        puts "Skipping install of #{name} cask. It is already installed." if verbose
        return false
      end

      true
    end

    def install(name, preinstall: true, no_upgrade: false, verbose: false, **options)
      return true unless preinstall

      full_name = options.fetch(:full_name, name)

      if installed_casks.include?(name) && upgrading?(no_upgrade, name, options)
        status = "#{options[:greedy] ? "may not be" : "not"} up-to-date"
        puts "Upgrading #{name} cask. It is installed but #{status}." if verbose
        return Bundle.system HOMEBREW_BREW_FILE, "upgrade", "--cask", full_name, verbose: verbose
      end

      args = options.fetch(:args, []).map do |k, v|
        case v
        when TrueClass
          "--#{k}"
        when FalseClass
          nil
        else
          "--#{k}=#{v}"
        end
      end.compact

      puts "Installing #{name} cask. It is not currently installed." if verbose

      return false unless Bundle.system HOMEBREW_BREW_FILE, "install", "--cask", full_name, *args, verbose: verbose

      installed_casks << name
      true
    end

    def self.cask_installed_and_up_to_date?(cask, no_upgrade: false)
      return false unless cask_installed?(cask)
      return true if no_upgrade

      !cask_upgradable?(cask)
    end

    def cask_installed?(cask)
      installed_casks.include? cask
    end

    def cask_upgradable?(cask)
      outdated_casks.include? cask
    end

    def installed_casks
      @installed_casks ||= Bundle::CaskDumper.cask_names
    end

    def outdated_casks
      @outdated_casks ||= Bundle::CaskDumper.outdated_cask_names
    end

    def greedy_outdated_casks
      @greedy_outdated_casks ||= Bundle::CaskDumper.outdated_cask_names(greedy: true)
    end
  end
end

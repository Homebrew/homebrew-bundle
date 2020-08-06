# frozen_string_literal: true

module Bundle
  module CaskInstaller
    module_function

    def reset!
      @installed_casks = nil
      @outdated_casks = nil
    end

    def install(name, no_upgrade: false, verbose: false, **options)
      full_name = options.fetch(:full_name, name)

      if installed_casks.include? name
        if !no_upgrade && outdated_casks.include?(name)
          puts "Upgrading #{name} cask. It is installed but not up-to-date." if verbose
          return :failed unless Bundle.system "brew", "cask", "upgrade", full_name, verbose: verbose

          return :success
        end
        return :skipped
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

      return :failed unless Bundle.system "brew", "cask", "install", full_name, *args, verbose: verbose

      installed_casks << name
      :success
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
      @installed_casks ||= Bundle::CaskDumper.casks
    end

    def outdated_casks
      @outdated_casks ||= if Bundle.cask_installed?
        `brew cask outdated 2>/dev/null`.split("\n")
      else
        []
      end
    end
  end
end

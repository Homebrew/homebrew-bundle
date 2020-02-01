# frozen_string_literal: true

module Bundle
  module CaskInstaller
    module_function

    def reset!
      @installed_casks = nil
      @outdated_casks = nil
    end

    def install(name, options = {})
      full_name = options.fetch(:full_name, name)

      if installed_casks.include? name
        if !ARGV.include?("--no-upgrade") && outdated_casks.include?(name)
          puts "Upgrading #{name} cask. It is installed but not up-to-date." if ARGV.verbose?
          return :failed unless Bundle.system "brew", "cask", "upgrade", full_name

          return :success
        end
        return :skipped
      end

      args = options.fetch(:args, []).map do |k, v|
        if v.is_a?(TrueClass)
          "--#{k}"
        elsif v.is_a?(FalseClass)
          nil
        else
          "--#{k}=#{v}"
        end
      end.compact

      puts "Installing #{name} cask. It is not currently installed." if ARGV.verbose?

      return :failed unless Bundle.system "brew", "cask", "install", full_name, *args

      installed_casks << name
      :success
    end

    def self.cask_installed_and_up_to_date?(cask)
      return false unless cask_installed?(cask)
      return true if ARGV.include?("--no-upgrade")

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

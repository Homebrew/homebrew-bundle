module Bundle
  module CaskInstaller
    module_function

    def install(name, options = {})
      if installed_casks.include? name
        puts "Skipping install of #{name} cask. It is already installed." if ARGV.verbose?
        return true
      end

      args = options.fetch(:args, []).map { |k, v| "--#{k}=#{v}" }

      puts "Installing #{name} cask. It is not currently installed." if ARGV.verbose?
      if (success = Bundle.system "brew", "cask", "install", name, *args)
        installed_casks << name
      end

      success
    end

    def installed_casks
      @installed_casks ||= Bundle::CaskDumper.casks
    end
  end
end

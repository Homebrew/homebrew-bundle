module Bundle
  module CaskInstaller
    module_function

    def install(name, options = {})
      if installed_casks.include? name
        puts "Skipping install of #{name} cask. It is already installed." if ARGV.verbose?
        return :skipped
      end

      args = options.fetch(:args, []).map { |k, v| "--#{k}=#{v}" }

      puts "Installing #{name} cask. It is not currently installed." if ARGV.verbose?

      unless Bundle.system "brew", "cask", "install", name, *args
        return :failed
      end

      installed_casks << name
      :success
    end

    def installed_casks
      @installed_casks ||= Bundle::CaskDumper.casks
    end
  end
end

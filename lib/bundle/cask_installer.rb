module Bundle
  module CaskInstaller
    module_function

    def install(name, options = {})
      if installed_casks.include? name
        puts "Skipping install of #{name} cask. It is already installed." if ARGV.verbose?
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

      return :failed unless Bundle.system "brew", "cask", "install", name, *args

      installed_casks << name
      :success
    end

    def installed_casks
      @installed_casks ||= Bundle::CaskDumper.casks
    end
  end
end

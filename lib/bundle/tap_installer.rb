module Bundle
  module TapInstaller
    module_function

    def install(name, clone_target)
      if installed_taps.include? name
        puts "Skipping install of #{name} tap. It is already installed." if ARGV.verbose?
        return :skipped
      end

      puts "Installing #{name} tap. It is not currently installed." if ARGV.verbose?
      success = if clone_target
        Bundle.system "brew", "tap", name, clone_target
      else
        Bundle.system "brew", "tap", name
      end

      return :failed unless success

      installed_taps << name
      :success
    end

    def installed_taps
      @installed_taps ||= Bundle::TapDumper.tap_names
    end
  end
end

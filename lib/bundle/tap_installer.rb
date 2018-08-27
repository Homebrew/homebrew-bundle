# frozen_string_literal: true

module Bundle
  module TapInstaller
    module_function

    def install(name, options = {})
      if installed_taps.include? name
        puts "Skipping install of #{name} tap. It is already installed." if ARGV.verbose?
        return :failed unless check_pinning(name, options)
        return :skipped
      end

      puts "Installing #{name} tap. It is not currently installed." if ARGV.verbose?
      success = if options[:clone_target]
        Bundle.system "brew", "tap", name, options[:clone_target]
      else
        Bundle.system "brew", "tap", name
      end

      return :failed unless success

      return :failed unless check_pinning(name, options)

      installed_taps << name
      :success
    end

    def installed_taps
      @installed_taps ||= Bundle::TapDumper.tap_names
    end

    def pinned_installed_taps
      @pinned_installed_taps ||= Bundle::TapDumper.pinned_tap_names
    end

    def check_pinning(name, options)
      pin = options[:pin]
      currently_pinned = pinned_installed_taps.include? name
      if pin && !currently_pinned
        puts "Pinning #{name} tap." if ARGV.verbose?
        return :failed unless Bundle.system "brew", "tap-pin", name
        pinned_installed_taps << name
      elsif currently_pinned && !pin
        puts "Unpinning #{name} tap." if ARGV.verbose?
        return :failed unless Bundle.system "brew", "tap-unpin", name
        pinned_installed_taps.delete(name)
      end
      :success
    end
  end
end

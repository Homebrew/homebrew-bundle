# frozen_string_literal: true

require "English"

module Bundle
  class << self
    def system(cmd, *args, verbose: false)
      return super cmd, *args if verbose

      logs = []
      success = nil
      IO.popen([cmd, *args], err: [:child, :out]) do |pipe|
        while (buf = pipe.gets)
          logs << buf
        end
        Process.wait(pipe.pid)
        success = $CHILD_STATUS.success?
        pipe.close
      end
      puts logs.join unless success
      success
    end

    def mas_installed?
      @mas_installed ||= begin
        !which("mas").nil?
      end
    end

    def whalebrew_installed?
      @whalebrew_installed ||= begin
        !which("whalebrew").nil?
      end
    end

    def mas_signedin?
      Kernel.system "mas account &>/dev/null"
    end

    def cask_installed?
      @cask_installed ||= begin
        File.directory?("#{HOMEBREW_PREFIX}/Caskroom") &&
          File.directory?("#{HOMEBREW_REPOSITORY}/Library/Taps/homebrew/homebrew-cask")
      end
    end

    def services_installed?
      @services_installed ||= begin
        !which("services.rb").nil?
      end
    end
  end
end

require "bundle/extend/os/bundle"

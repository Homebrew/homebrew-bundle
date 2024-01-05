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
      @mas_installed ||= which_formula("mas")
    end

    def vscode_installed?
      @vscode_installed ||= which("code").present?
    end

    def whalebrew_installed?
      @whalebrew_installed ||= which_formula("whalebrew")
    end

    def mas_signedin?
      # mas account doesn't work on Monterey (yet)
      # https://github.com/mas-cli/mas/issues/417#issuecomment-957963271
      return true if MacOS.version >= :monterey

      Kernel.system "mas account &>/dev/null"
    end

    def cask_installed?
      @cask_installed ||= File.directory?("#{HOMEBREW_PREFIX}/Caskroom") &&
                          (File.directory?("#{HOMEBREW_LIBRARY}/Taps/homebrew/homebrew-cask") ||
                           !Homebrew::EnvConfig.no_install_from_api?)
    end

    def services_installed?
      @services_installed ||= which("services.rb").present?
    end

    def which_formula(name)
      formula = Formulary.factory(name)
      ENV["PATH"] = "#{formula.opt_bin}:#{ENV.fetch("PATH", nil)}" if formula.any_version_installed?
      which(name).present?
    end
  end
end

require "bundle/extend/os/bundle"

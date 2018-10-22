# frozen_string_literal: true

require "English"

module Bundle
  module_function

  def system(cmd, *args)
    return super cmd, *args if ARGV.verbose?
    logs = []
    success = nil
    IO.popen([cmd, *args], err: [:child, :out]) do |pipe|
      while buf = pipe.gets
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
      !which("brew-services.rb").nil?
    end
  end
end

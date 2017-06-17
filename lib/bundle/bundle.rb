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
    @mas ||= begin
      !which("mas").nil?
    end
  end

  def mas_signedin?
    Bundle.system "mas", "account"
  end

  def cask_installed?
    @cask ||= begin
      File.directory?("#{HOMEBREW_PREFIX}/Caskroom") &&
        File.directory?("#{HOMEBREW_REPOSITORY}/Library/Taps/caskroom")
    end
  end

  def services_installed?
    @services ||= begin
      !which("brew-services.rb").nil?
    end
  end

  def brewfile
    if ARGV.include?("--global")
      file = Pathname.new("#{ENV["HOME"]}/.Brewfile")
    else
      filename = ARGV.value("file")
      filename = "/dev/stdin" if filename == "-"
      filename ||= "Brewfile"
      file = Pathname.new(filename).expand_path(Dir.pwd)
    end
    file.read
  rescue Errno::ENOENT
    raise "No Brewfile found"
  end
end

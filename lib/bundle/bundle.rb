module Bundle
  module_function

  def system(cmd, *args)
    if ARGV.verbose?
      return super cmd, *args
    end
    logs = []
    success = nil
    IO.popen([cmd, *args], err: [:child, :out]) do |pipe|
      while buf = pipe.gets
        logs << buf
      end
      Process.wait(pipe.pid)
      success = $?.success?
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

  def cask_installed?
    @cask ||= begin
      which("brew-cask") || which("brew-cask.rb")
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

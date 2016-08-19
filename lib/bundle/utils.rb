module Bundle
  def self.system(cmd, *args)
    if ARGV.verbose?
      return super cmd, *args
    end
    logs = []
    success = nil
    IO.popen([cmd, *args], :err => [:child, :out]) do |pipe|
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

  def self.mas_installed?
    @mas ||= begin
      !!which("mas")
    end
  end

  def self.cask_installed?
    @cask ||= begin
      which("brew-cask") || which("brew-cask.rb")
    end
  end

  def self.services_installed?
    @services ||= begin
      !!which("brew-services.rb")
    end
  end

  def self.brewfile
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

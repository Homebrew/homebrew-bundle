module Bundle
  def self.system cmd, *args
    verbose = ARGV.verbose?
    logs = []
    success = nil
    IO.popen([cmd, *args], :err => [:child, :out]) do |pipe|
      while buf = pipe.gets
        puts buf if verbose
        logs << buf
      end
      Process.wait(pipe.pid)
      success = $?.success?
      pipe.close
    end
    puts logs.join unless success || verbose
    success
  end

  def self.brew_installed?
    @@brew ||= Kernel.system("brew --version &>/dev/null")
  end

  def self.cask_installed?
    @@cask ||= Kernel.system("brew cask --version &>/dev/null")
  end

  def self.brewfile
    if ARGV.include?("--global")
      file = "#{ENV["HOME"]}/.Brewfile"
    else
      file = ARGV.value("file") || Dir["{*,.*}{B,b}rewfile"].first.to_s
    end
    File.read(file)
  rescue Errno::ENOENT
    raise "No Brewfile found"
  end
end

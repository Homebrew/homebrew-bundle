module Brewdler
  def self.system cmd, *args
    pid = fork do
      $stdout.reopen("/dev/null")
      exec(cmd, *args)
    end
    Process.wait(pid)
    $?.success?
  end

  def self.brew_installed?
    Kernel.system("brew --version &>/dev/null")
  end

  def self.cask_installed?
    Kernel.system("brew cask --version &>/dev/null")
  end

  def self.brewfile
    File.read(Dir['{*,.*}{B,b}rewfile'].first.to_s)
  rescue Errno::ENOENT
    raise "No Brewfile found"
  end
end

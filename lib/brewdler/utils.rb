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
    system("brew --version &>/dev/null")
  end

  def self.cask_installed?
    system("brew cask --version &>/dev/null")
  end
end

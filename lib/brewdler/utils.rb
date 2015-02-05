module Brewdler
  def self.system cmd, *args
    pid = fork do
      $stdout.reopen("/dev/null")
      exec(cmd, *args)
    end
    Process.wait(pid)
    $?.success?
  end
end

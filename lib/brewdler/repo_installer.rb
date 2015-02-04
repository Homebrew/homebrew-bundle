module Brewdler
  class RepoInstaller
    def self.install(name)
      if system "brew --prefix &>/dev/null"
        Brewdler.system "brew", "tap", name
      else
        raise "Unable to tap #{name}. Homebrew is not currently installed on your system"
      end
    end
  end
end

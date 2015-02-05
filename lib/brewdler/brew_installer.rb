module Brewdler
  class BrewInstaller
    def self.install(name, options = {})
      if Brewdler.brew_installed?
        command = [name]
        unless options[:args].nil?
          options[:args].each do |arg|
            command << "--#{arg}"
          end
        end

        Brewdler.system "brew", "install", *command
      else
        raise "Unable to install #{name}. Homebrew is not currently installed on your system"
      end
    end
  end
end

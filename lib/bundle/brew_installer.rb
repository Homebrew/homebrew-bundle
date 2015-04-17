module Bundle
  class BrewInstaller
    def self.install(name, options = {})
      if Bundle.brew_installed?
        command = [name]
        unless options[:args].nil?
          options[:args].each do |arg|
            command << "--#{arg}"
          end
        end

        Bundle.system "brew", "install", *command
      else
        raise "Unable to install #{name}. Homebrew is not currently installed on your system"
      end
    end
  end
end

module Brewdler
  class BrewInstaller
    def self.install(name, options = {})
      if `which brew`; $?.success?
        command = "brew install #{name}"
        unless options[:args].nil?
          options[:args].each do |arg|
            command << " --#{arg}"
          end
        end

        `#{command}`
      else
        raise "Unable to install #{name}. Homebrew is not currently installed on your system"
      end
    end
  end
end

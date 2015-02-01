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

    def self.upgrade(name, options = {})
      if `which brew`; $?.success?
        if `brew outdated --quiet #{name}`; !$?.success?
          command = "brew upgrade #{name}"
          unless options[:args].nil?
            options[:args].each do |arg|
              command << " --#{arg}"
            end
          end
          `#{command}`
        else
          puts "#{name} is up to date"
        end
      else
        raise "Unable to upgrade #{name}. Homebrew is not currently installed on your system"
      end
    end
  end
end

module Brewdler::Commands
  class Install
    def self.run
      begin
        file = File.read(File.join(Dir.pwd, "Brewfile"))
        Brewdler::Dsl.new(file).process
      rescue Errno::ENOENT => e
        raise "No Brewfile found."
      rescue NameError
        file = File.open(File.join(Dir.pwd, "Brewfile"))
        file.find_all do |name|
          name.chomp!
          Brewdler::BrewInstaller.install(name) if name.length > 0 && name !~ /^ *#/
        end
      end
    end
  end
end

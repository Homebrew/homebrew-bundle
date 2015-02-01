module Brewdler::Commands
  class Upgrade < Command
    def self.run
      begin
        Brewdler::Dsl.new(brewfile, "upgrade").process
      rescue Errno::ENOENT => e
        raise "No Brewfile found"
      rescue NameError
        brewfile.split("\n").each do |name|
          name.chomp!
          Brewdler::BrewInstaller.upgrade(name) if name.length > 0 && name !~ /^ *#/
        end
      end
    end
  end
end

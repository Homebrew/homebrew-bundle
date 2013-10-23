module Brewdler::Commands
  class Install
    def self.run
      begin
        Brewdler::Dsl.new(brewfile).process
      rescue Errno::ENOENT => e
        raise "No Brewfile found"
      rescue NameError
        brewfile.find_all do |name|
          name.chomp!
          Brewdler::BrewInstaller.install(name) if name.length > 0 && name !~ /^ *#/
        end
      end
    end

  private

    def self.brewfile
      File.read(Dir['{*,.*}{B,b}rewfile'].first)
    end
  end
end

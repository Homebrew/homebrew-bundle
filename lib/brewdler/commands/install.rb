module Brewdler::Commands
  class Install
    def self.run
      begin
        Brewdler::Dsl.new(brewfile).process
      rescue Errno::ENOENT => e
        raise "No Brewfile found"
      rescue NameError
        brewfile.split("\n").each do |name|
          name.chomp!
          Brewdler::BrewInstaller.install(name) if name.length > 0 && name !~ /^ *#/
        end
      end
    end

  private

    def self.brewfile
      File.read(Dir['{*,.*}{B,b}rewfile'].first.to_s)
    end
  end
end

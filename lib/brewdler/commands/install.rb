module Brewdler::Commands
  class Install
    def self.run
      begin
        Brewdler::Dsl.new(Brewdler.brewfile).process.install
      rescue NameError
        Brewdler.brewfile.split("\n").each do |name|
          name.chomp!
          Brewdler::BrewInstaller.install(name) if name.length > 0 && name !~ /^ *#/
        end
      end
    end
  end
end

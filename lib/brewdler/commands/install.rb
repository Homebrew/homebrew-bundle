module Brewdler::Commands
  class Install
    def self.run
      Brewdler::Dsl.new(Brewdler.brewfile).process.install
    end
  end
end

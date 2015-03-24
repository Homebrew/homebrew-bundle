module Brewdler::Commands
  class Install
    def self.run
      Brewdler::Dsl.new(Brewdler.brewfile).install
    end
  end
end

module Brewdler::Commands
  class Dump
    def self.run
      dumper = Brewdler::Dumper.new
      dumper.dump_brewfile
    end
  end
end

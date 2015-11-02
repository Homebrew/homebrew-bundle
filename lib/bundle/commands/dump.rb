module Bundle::Commands
  class Dump
    def self.run
      Bundle::Dumper.dump_brewfile
    end
  end
end

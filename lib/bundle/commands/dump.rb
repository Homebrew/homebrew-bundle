module Bundle::Commands
  class Dump
    def self.run
      dumper = Bundle::Dumper.new
      dumper.dump_brewfile
    end
  end
end

module Brewdler::Commands
    class Command
    private
      def self.brewfile
        File.read(Dir['{*,.*}{B,b}rewfile'].first.to_s)
      end
    end
end
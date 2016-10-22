module Bundle
  module Commands
    module Dump
      module_function

      def run
        Bundle::Dumper.dump_brewfile
      end
    end
  end
end

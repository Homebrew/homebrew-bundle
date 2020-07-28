# frozen_string_literal: true

module Bundle
  module Commands
    module Dump
      module_function

      def run(global: false, file: nil, describe: false, force: false, no_restart: false)
        Bundle::Dumper.dump_brewfile(
          global: global, file: file, describe: describe, force: force, no_restart: no_restart,
        )
      end
    end
  end
end

# frozen_string_literal: true

module Bundle
  module Commands
    module Dump
      module_function

      def run(global: false, file: nil, describe: false, force: false, no_restart: false,
              all: false, taps: false, brews: false, casks: false,
              mas: false, whalebrew: false, vscode: false)
        Bundle::Dumper.dump_brewfile(
          global:, file:, describe:, force:, no_restart:,
          all:, taps:, brews:, casks:,
          mas:, whalebrew:, vscode:
        )
      end
    end
  end
end

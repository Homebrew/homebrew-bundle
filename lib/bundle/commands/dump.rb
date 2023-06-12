# frozen_string_literal: true

module Bundle
  module Commands
    module Dump
      module_function

      def run(global: false, file: nil, describe: false, force: false, no_restart: false,
              all: false, taps: false, brews: false, casks: false,
              mas: false, whalebrew: false, vscode: false)
        Bundle::Dumper.dump_brewfile(
          global: global, file: file, describe: describe, force: force, no_restart: no_restart,
          all: all, taps: taps, brews: brews, casks: casks,
          mas: mas, whalebrew: whalebrew, vscode: vscode
        )
      end
    end
  end
end

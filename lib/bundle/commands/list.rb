# frozen_string_literal: true

module Bundle
  module Commands
    module List
      module_function

      def run(global: false, file: nil, all: false, casks: false, taps: false, mas: false, whalebrew: false,
              vscode: false, tlmgr: false, brews: false)
        parsed_entries = Bundle::Dsl.new(Brewfile.read(global:, file:)).entries
        Bundle::Lister.list(
          parsed_entries,
          all:, casks:, taps:, mas:, whalebrew:, vscode:, tlmgr:, brews:,
        )
      end
    end
  end
end

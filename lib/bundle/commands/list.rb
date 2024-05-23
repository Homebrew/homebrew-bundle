# frozen_string_literal: true

module Bundle
  module Commands
    module List
      module_function

      def run(global: false, file: nil, all: false, casks: false, taps: false, mas: false, whalebrew: false,
              vscode: false, brews: false)
        parsed_entries = Brewfile.read(global:, file:).entries
        Bundle::Lister.list(
          parsed_entries,
          all:, casks:, taps:, mas:, whalebrew:, vscode:, brews:,
        )
      end
    end
  end
end

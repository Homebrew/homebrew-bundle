# frozen_string_literal: true

module Bundle
  module Commands
    module List
      module_function

      def run(
        global: false, file: nil, all: false, casks: false, taps: false, mas: false, whalebrew: false, brews: false
      )
        parsed_entries = Bundle::Dsl.new(Brewfile.read(global: global, file: file)).entries
        Bundle::Lister.list(
          parsed_entries,
          all: all, casks: casks, taps: taps, mas: mas, whalebrew: whalebrew, brews: brews,
        )
      end
    end
  end
end

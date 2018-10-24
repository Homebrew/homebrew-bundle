# frozen_string_literal: true

module Bundle
  module Commands
    module List
      module_function

      def run
        parsed_entries = Bundle::Dsl.new(Brewfile.read).entries
        Bundle::Lister.list(parsed_entries) || exit(1)
      end
    end
  end
end

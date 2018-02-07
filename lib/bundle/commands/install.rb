# frozen_string_literal: true

module Bundle
  module Commands
    module Install
      module_function

      def run
        parsed_entries = Bundle::Dsl.new(Bundle.brewfile).entries
        Bundle::Installer.install(parsed_entries) || exit(1)
      end
    end
  end
end

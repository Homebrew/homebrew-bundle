# frozen_string_literal: true

module Bundle
  module Commands
    module Install
      module_function

      def run(global: false, file: nil, no_lock: false, no_upgrade: false, verbose: false)
        parsed_entries = Bundle::Dsl.new(Brewfile.read(global: global, file: file)).entries
        Bundle::Installer.install(
          parsed_entries,
          global: global, file: file, no_lock: no_lock, no_upgrade: no_upgrade, verbose: verbose,
        ) || exit(1)
      end
    end
  end
end

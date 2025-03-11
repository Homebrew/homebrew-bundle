# typed: true
# frozen_string_literal: true

module Bundle
  module Remover
    module_function

    def remove(*args, type:, global:, file:)
      brewfile = Brewfile.read(global:, file:)
      content = brewfile.input.split("\n")
      entry_type = type.to_s if type != :none
      escaped_args = args.map { |arg| Regexp.escape(arg) }
      content = content.grep_v(/#{entry_type}(\s+|\(\s*)"(#{escaped_args.join("|")})"/)
                       .join("\n") << "\n"
      path = Dumper.brewfile_path(global:, file:)

      Dumper.write_file path, content
    end
  end
end

# typed: true
# frozen_string_literal: true

module Bundle
  module Remover
    module_function

    def remove(*args, type:, global:, file:)
      raise "Implement me!"

      brewfile = Brewfile.read(global:, file:)
      content = brewfile.input
      new_content = ""
      content << new_content.join("\n") << "\n"
      path = Dumper.brewfile_path(global:, file:)

      Dumper.write_file path, content
    end
  end
end

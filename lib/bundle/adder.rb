# typed: true
# frozen_string_literal: true

module Bundle
  module Adder
    module_function

    def add(*args, type:, global:, file:)
      brewfile = Brewfile.read(global:, file:)
      content = brewfile.input
      # TODO: - validate formulae and casks
      #       - support `:describe`
      content << args.map { |arg| "#{type} \"#{arg}\"" }
                     .join("\n") << "\n"
      path = Dumper.brewfile_path(global:, file:)

      Dumper.write_file path, content
    end
  end
end

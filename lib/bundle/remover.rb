# typed: true
# frozen_string_literal: true

module Bundle
  module Remover
    module_function

    def remove(*args, type:, global:, file:)
      brewfile = Brewfile.read(global:, file:)
      content = brewfile.input.split("\n")
      entry_type = type.to_s if type != :none
      escaped_args = args.flat_map do |arg|
        names = if type == :brew
          formula = Formulary.factory(arg)

          [arg, formula.name, formula.full_name] + formula.aliases + formula.oldnames
        else
          [arg]
        end

        names.uniq.map { |a| Regexp.escape(a) }
      end

      content = content.grep_v(/#{entry_type}(\s+|\(\s*)"(#{escaped_args.join("|")})"/)
                       .join("\n") << "\n"
      path = Dumper.brewfile_path(global:, file:)

      Dumper.write_file path, content
    end
  end
end

# typed: true
# frozen_string_literal: true

module Bundle
  module Remover
    module_function

    def remove(*args, type:, global:, file:)
      brewfile = Brewfile.read(global:, file:)
      content = brewfile.input
      entry_type = type.to_s if type != :none
      escaped_args = args.flat_map do |arg|
        names = if type == :brew
          possible_names(arg)
        else
          [arg]
        end

        names.uniq.map { |a| Regexp.escape(a) }
      end

      new_content = content.split("\n")
                           .grep_v(/#{entry_type}(\s+|\(\s*)"(#{escaped_args.join("|")})"/)
                           .join("\n") << "\n"

      if content.chomp == new_content.chomp &&
         type == :none &&
         args.any? { |arg| possible_names(arg, raise_error: false).count > 1 }
        opoo "No matching entries found in Brewfile. Try again with `--formula` to match formula " \
             "aliases and old formula names."
        return
      end

      path = Dumper.brewfile_path(global:, file:)
      Dumper.write_file path, new_content
    end

    def possible_names(formula_name, raise_error: true)
      formula = Formulary.factory(formula_name)
      [formula_name, formula.name, formula.full_name, *formula.aliases, *formula.oldnames].compact.uniq
    rescue FormulaUnavailableError
      raise if raise_error
    end
  end
end

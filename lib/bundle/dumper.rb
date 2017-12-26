# frozen_string_literal: true

require "fileutils"
require "pathname"

module Bundle
  module Dumper
    module_function

    def dump_brewfile
      file = Bundle.brewfile
      raise "#{file} already exists" if Bundle.should_not_write_file?(file, ARGV.force?)

      content = []
      content << TapDumper.dump
      casks_required_by_formulae = BrewDumper.cask_requirements
      cask_before_formula, cask_after_formula = CaskDumper.dump(casks_required_by_formulae)
      content << cask_before_formula
      content << BrewDumper.dump
      content << cask_after_formula
      content << MacAppStoreDumper.dump
      content = content.reject(&:empty?).join("\n") + "\n"
      Bundle.write_file file, content
    end
  end
end

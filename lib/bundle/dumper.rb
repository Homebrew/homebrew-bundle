# frozen_string_literal: true

require "fileutils"
require "pathname"

module Bundle
  module Dumper
    module_function

    def can_write_to_brewfile?(brewfile_path, force: false)
      raise "#{brewfile_path} already exists" if should_not_write_file?(brewfile_path, force)

      true
    end

    def build_brewfile(describe: false, no_restart: false)
      content = []
      content << TapDumper.dump
      casks_required_by_formulae = BrewDumper.cask_requirements
      cask_before_formula, cask_after_formula = CaskDumper.dump(casks_required_by_formulae)
      content << cask_before_formula
      content << BrewDumper.dump(describe: describe, no_restart: no_restart)
      content << cask_after_formula
      content << MacAppStoreDumper.dump
      content << WhalebrewDumper.dump
      content.reject(&:empty?).join("\n") + "\n"
    end

    def dump_brewfile(global: false, file: nil, describe: false, force: false, no_restart: false)
      path = brewfile_path(global: global, file: file)
      can_write_to_brewfile?(path, force: force)
      content = build_brewfile(describe: describe, no_restart: no_restart)
      write_file path, content
    end

    def brewfile_path(global: false, file: nil)
      Brewfile.path(dash_writes_to_stdout: true, global: global, file: file)
    end

    def should_not_write_file?(file, overwrite = false)
      file.exist? && !overwrite && file.to_s != "/dev/stdout"
    end

    def write_file(file, content)
      file.open("w") { |io| io.write content }
    end
  end
end

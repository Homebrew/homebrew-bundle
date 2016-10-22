require "fileutils"
require "pathname"

module Bundle
  module Dumper
    module_function

    def dump_brewfile
      if ARGV.include?("--global")
        file = Pathname.new("#{ENV["HOME"]}/.Brewfile")
      else
        filename = ARGV.value("file")
        filename = "/dev/stdout" if filename == "-"
        filename ||= "Brewfile"
        file = Pathname.new(filename).expand_path(Dir.pwd)
      end
      raise "#{file} already exists" if should_not_write_file?(file, ARGV.force?)
      content = []
      content << TapDumper.dump
      casks_required_by_formulae = BrewDumper.cask_requirements
      cask_before_formula, cask_after_formula = CaskDumper.dump(casks_required_by_formulae)
      content << cask_before_formula
      content << BrewDumper.dump
      content << cask_after_formula
      content << MacAppStoreDumper.dump
      content = content.reject(&:empty?).join("\n") + "\n"
      write_file file, content
    end

    def should_not_write_file?(file, overwrite = false)
      file.exist? && !overwrite && file.to_s != "/dev/stdout"
    end

    def write_file(file, content)
      file.open("w") { |io| io.write content }
    end
  end
end

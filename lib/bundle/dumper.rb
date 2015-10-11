require "fileutils"
require "pathname"

module Bundle
  class Dumper
    attr_reader :brew, :cask, :tap

    def initialize
      @brew = BrewDumper.new
      @cask = CaskDumper.new
      @tap = TapDumper.new
    end

    def dump_brewfile
      if ARGV.include?("--global")
        file = Pathname.new("#{ENV["HOME"]}/.Brewfile")
      else
        filename = ARGV.value("file")
        filename = "/dev/stdout" if filename == "-"
        filename ||= "Brewfile"
        file = Pathname.new(filename).expand_path(Dir.pwd)
      end
      content = []
      content << tap.to_s
      formula_requirements = brew.expand_cask_requirements
      cask_before_formula, cask_after_formula = cask.dump_to_string(formula_requirements)
      content << cask_before_formula
      content << brew.to_s
      content << cask_after_formula
      content = content.reject(&:empty?).join("\n") + "\n"
      write_file file, content, ARGV.force?
    end

    private

    def write_file(file, content, overwrite = false)
      if file.exist? && !overwrite && file.to_s != "/dev/stdout"
        raise "#{file} already exists."
      end

      file.open("w") { |io| io.write content }
    end
  end
end

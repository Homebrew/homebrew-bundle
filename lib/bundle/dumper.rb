require "fileutils"
require "pathname"

module Bundle
  class Dumper
    def self.dump_brewfile
      if ARGV.include?("--global")
        file = Pathname.new("#{ENV["HOME"]}/.Brewfile")
      else
        filename = ARGV.value("file")
        filename = "/dev/stdout" if filename == "-"
        filename ||= "Brewfile"
        file = Pathname.new(filename).expand_path(Dir.pwd)
      end
      content = []
      content << TapDumper.dump
      casks_required_by_formulae = BrewDumper.cask_requirements
      cask_before_formula, cask_after_formula = CaskDumper.dump(casks_required_by_formulae)
      content << cask_before_formula
      content << BrewDumper.dump
      content << cask_after_formula
      content = content.reject(&:empty?).join("\n") + "\n"
      write_file file, content, ARGV.force?
    end

    private

    def self.write_file(file, content, overwrite = false)
      if file.exist? && !overwrite && file.to_s != "/dev/stdout"
        raise "#{file} already exists."
      end

      file.open("w") { |io| io.write content }
    end
  end
end

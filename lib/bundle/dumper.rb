require "fileutils"
require "pathname"

module Bundle
  class Dumper
    attr_reader :brew, :cask, :repo

    def initialize
      @brew = BrewDumper.new
      @cask = CaskDumper.new
      @repo = RepoDumper.new
    end

    def dump_brewfile
      if ARGV.include?("--global")
        file = Pathname.new("#{ENV["HOME"]}/.Brewfile")
      else
        file = Pathname.new(ARGV.value("file") || "Brewfile").expand_path(Dir.pwd)
      end
      content = [repo, brew, cask].map(&:to_s).reject(&:empty?).join("\n") + "\n"
      write_file file, content, ARGV.force?
    end

    private

    def write_file(file, content, overwrite=false)
      if file.exist? && !overwrite
        raise "#{file} already exists."
      end

      file.open("w") { |io| io.write content }
    end
  end
end

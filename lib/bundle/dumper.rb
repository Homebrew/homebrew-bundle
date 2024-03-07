# frozen_string_literal: true

require "fileutils"
require "pathname"

module Bundle
  module Dumper
    module_function

    def can_write_to_brewfile?(brewfile_path, force: false)
      raise "#{brewfile_path} already exists" if should_not_write_file?(brewfile_path, overwrite: force)

      true
    end

    def build_brewfile(describe: false, no_restart: false,
                       all: false, taps: false, brews: false, casks: false,
                       mas: false, whalebrew: false, vscode: false)
      all     ||= !(taps || brews || casks || mas || whalebrew || vscode)
      content = []
      content << TapDumper.dump if taps || all
      content << BrewDumper.dump(describe:, no_restart:) if brews || all
      content << CaskDumper.dump(describe:) if casks || all
      content << MacAppStoreDumper.dump if mas || all
      content << WhalebrewDumper.dump if whalebrew || all
      content << VscodeExtensionDumper.dump if vscode || all
      "#{content.reject(&:empty?).join("\n")}\n"
    end

    def dump_brewfile(global: false, file: nil, describe: false, force: false, no_restart: false,
                      all: false, taps: false, brews: false, casks: false,
                      mas: false, whalebrew: false, vscode: false)
      path = brewfile_path(global:, file:)
      can_write_to_brewfile?(path, force:)
      content = build_brewfile(describe:, no_restart:,
                               all:, taps:, brews:, casks:,
                               mas:, whalebrew:, vscode:)
      write_file path, content
    end

    def brewfile_path(global: false, file: nil)
      Brewfile.path(dash_writes_to_stdout: true, global:, file:)
    end

    def should_not_write_file?(file, overwrite: false)
      file.exist? && !overwrite && file.to_s != "/dev/stdout"
    end

    def write_file(file, content)
      file.open("w") { |io| io.write content }
    end
  end
end

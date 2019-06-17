# frozen_string_literal: true

module Bundle
  module Brewfile
    module_function

    def path(dash_writes_to_stdout: false)
      env_bundle_file = ENV.fetch("HOMEBREW_BUNDLE_FILE", "")

      filename =
          if ARGV.include?("--global")
            raise "'HOMEBREW_BUNDLE_FILE' can not be specified with '--global'" unless env_bundle_file.empty?
            "#{ENV["HOME"]}/.Brewfile"
          elsif ARGV.include?("--file")
            handle_file_value(ARGV.value("file"), dash_writes_to_stdout)
          elsif !env_bundle_file.empty?
            env_bundle_file
          else
            "Brewfile"
          end

      Pathname.new(filename).expand_path(Dir.pwd)
    end

    def read
      Brewfile.path.read
    rescue Errno::ENOENT
      raise "No Brewfile found"
    end

    def handle_file_value(filename, dash_writes_to_stdout)
      if filename != "-"
        filename
      elsif dash_writes_to_stdout
        "/dev/stdout"
      else
        "/dev/stdin"
      end
    end
  end
end

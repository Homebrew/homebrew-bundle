# frozen_string_literal: true

module Bundle
  module Brewfile
    module_function

    def path(dash_writes_to_stdout: false)
      env_bundle_file = ENV["HOMEBREW_BUNDLE_FILE"]

      filename =
        if Homebrew.args.global?
          raise "'HOMEBREW_BUNDLE_FILE' cannot be specified with '--global'" if env_bundle_file.present?

          "#{ENV["HOME"]}/.Brewfile"
        elsif Homebrew.args.file.present?
          handle_file_value(Homebrew.args.file, dash_writes_to_stdout)
        elsif env_bundle_file.present?
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

# frozen_string_literal: true

module Bundle
  module Commands
    module Init
      module_function

      def run
        if ARGV.include?("--global")
          filename = ".Brewfile"
          file = Pathname.new("#{ENV["HOME"]}/#{filename}")
        else
          filename = ARGV.value("file")
          filename = "/dev/stdout" if filename == "-"
          filename ||= "Brewfile"
          file = Pathname.new(filename).expand_path(Dir.pwd)
        end
        raise "#{file} already exists" if should_not_write_file?(file, ARGV.force?)

        content = <<~EOS
          # cask_args appdir: "/Applications"
          # tap "caskroom/cask"
          # tap "telemachus/brew", "https://telemachus@bitbucket.org/telemachus/brew.git"
          # brew "imagemagick"
          # brew "mysql@5.6", restart_service: true, link: true, conflicts_with: ["mysql"]
          # brew "emacs", args: ["with-cocoa", "with-gnutls"]
          # cask "google-chrome"
          # cask "java" unless system "/usr/libexec/java_home --failfast"
          # cask "firefox", args: { appdir: "~/my-apps/Applications" }
          # mas "1Password", id: 443987910
        EOS
        write_file file, content

        puts "Writing new #{filename} to #{file}"
      end

      def should_not_write_file?(file, overwrite = false)
        file.exist? && !overwrite && file.to_s != "/dev/stdout"
      end

      def write_file(file, content)
        file.open("w") { |io| io.write content }
      end
    end
  end
end

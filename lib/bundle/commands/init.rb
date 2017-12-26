# frozen_string_literal: true

module Bundle
  module Commands
    module Init
      module_function

      def run
        file = Bundle.brewfile
        raise "#{file} already exists" if Bundle.should_not_write_file?(file, ARGV.force?)

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
        Bundle.write_file file, content

        puts "Writing new #{file}"
      end
    end
  end
end

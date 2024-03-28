# frozen_string_literal: true

module Bundle
  module TlmgrPackageDumper
    module_function

    def reset!
      @packages = nil
      @outdated_packages = nil
    end

    def packages
      @packages ||= if Bundle.tlmgr_installed?
        `tlmgr info --only-installed 2>/dev/null`.split("\n").map { |l| l.match(/i ([^:]+).*/)[1] }.map(&:downcase)
      else
        []
      end
    end

    # TODO: See how we can get around the sudo requirement because of the way e.g. basictex installs itself
    # See also https://tug.org/texlive/doc/tlmgr.html#USER-MODE
    def outdated_packages
      @outdated_packages ||= if Bundle.tlmgr_installed?
        `sudo tlmgr update --all --dry-run 2>/dev/null`.split("\n")
                                                       .map { |l| l.match(/^update:\s+([^ ]+).*/)[1] }
                                                       .reject(&:empty?).map(&:downcase)
      else
        []
      end
    end

    def dump
      packages.map { |name| "tlmgr \"#{name}\"" }.join("\n")
    end
  end
end

# frozen_string_literal: true

module Bundle
  module Lister
    module_function

    def list(entries, all: false, casks: false, taps: false, mas: false, whalebrew: false,
             vscode: false, tlmgr: false, brews: false)
      entries.each do |entry|
        if show?(entry.type, all:, casks:, taps:, mas:, whalebrew:, vscode:, tlmgr:,
brews:)
          puts entry.name
        end
      end
    end

    def self.show?(type, all: false, casks: false, taps: false, mas: false, whalebrew: false,
                   vscode: false, tlmgr: false, brews: false)
      return true if all
      return true if casks && type == :cask
      return true if taps && type == :tap
      return true if mas && type == :mas
      return true if whalebrew && type == :whalebrew
      return true if vscode && type == :vscode
      return true if tlmgr && type == :tlmgr
      return true if brews && type == :brew
      return true if type == :brew && !casks && !taps && !mas && !whalebrew && !vscode && !tlmgr

      false
    end
  end
end

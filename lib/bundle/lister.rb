# frozen_string_literal: true

module Bundle
  module Lister
    module_function

    def list(entries)
      entries.each do |entry|
        puts entry.name if show? entry.type
      end
    end

    def self.show?(type)
      return true if Homebrew.args.all?
      return true if Homebrew.args.casks? && type == :cask
      return true if Homebrew.args.taps? && type == :tap
      return true if Homebrew.args.mas? && type == :mas
      return true if Homebrew.args.whalebrew? && type == :whalebrew
      return true if Homebrew.args.brews? && type == :brew
      return true if type == :brew && !Homebrew.args.casks? && !Homebrew.args.taps? && !Homebrew.args.mas?
    end
  end
end

# frozen_string_literal: true

module Bundle
  module Skipper
    class << self
      def skip?(entry, silent: false)
        return generic_skip?(entry) unless [:cask, :mas].include?(entry.type)
        return true if silent

        puts Formatter.warning "Skipping #{entry.type} #{entry.name} (on Linux)"
        true
      end
    end
  end
end

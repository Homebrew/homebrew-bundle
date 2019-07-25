# frozen_string_literal: true

module Bundle
  module Skipper
    class << self
      def skip?(entry)
        return generic_skip?(entry) unless [:cask, :mas].include?(entry.type)

        puts Formatter.warning "Skipping #{entry.name} (on Linux)"
        true
      end
    end
  end
end

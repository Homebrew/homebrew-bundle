# frozen_string_literal: true

module Cask
  class Cask
    def full_name
      ""
    end

    def to_s
      ""
    end

    def version
      ""
    end

    def desc
      ""
    end

    def depends_on
      {}
    end

    def config
      nil
    end

    def outdated?(greedy: false)
      false
    end
  end
end

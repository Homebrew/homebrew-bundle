# frozen_string_literal: true

module Cask
  class Config
    def explicit
      {}
    end

    def explicit_s
      explicit.to_s
    end
  end
end

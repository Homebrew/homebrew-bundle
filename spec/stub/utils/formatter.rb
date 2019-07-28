# frozen_string_literal: true

module Formatter
  class << self
    def columns(*); end

    def success(*args)
      args
    end
    alias warning success
    alias error success
  end
end

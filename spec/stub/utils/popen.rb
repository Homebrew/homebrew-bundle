# frozen_string_literal: true

module Utils
  class << self
    def safe_popen_read(*args)
      `#{args.join(" ")}`
    end
  end
end

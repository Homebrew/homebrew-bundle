# frozen_string_literal: true

module Homebrew
  class EnvConfig
    def self.no_env_hints?
      false
    end

    def self.no_install_from_api?
      false
    end
  end
end

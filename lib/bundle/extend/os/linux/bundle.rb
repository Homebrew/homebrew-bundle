# frozen_string_literal: true

module Bundle
  class << self
    def mas_installed?
      false
    end

    def cask_installed?
      false
    end

    def services_installed?
      false
    end
  end
end

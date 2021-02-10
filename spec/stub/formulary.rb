# frozen_string_literal: true

class Formulary
  def self.factory(name)
    Formula.new(name)
  end

  def self.enable_factory_cache!; end
end

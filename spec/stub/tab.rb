# frozen_string_literal: true

class Tab
  def self.for_keg(_keg)
    Tab.new
  end

  def used_options
    []
  end

  def installed_as_dependency; end

  def installed_on_request; end

  def runtime_dependencies
    []
  end

  def poured_from_bottle; end
end

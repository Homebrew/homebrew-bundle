# frozen_string_literal: true

require "pathname"

class Formula
  def initialize(name)
    @prefix = Pathname.new("/usr/local")
    @name = name
  end

  def opt_prefix
    @prefix.join("opt").join(@name)
  end

  def opt_bin
    opt_prefix.join("bin")
  end

  def recursive_dependencies
    []
  end

  def keg_only?
    false
  end

  def any_version_installed?
    true
  end

  def self.installed
    []
  end

  def self.[](name)
    new(name)
  end
end

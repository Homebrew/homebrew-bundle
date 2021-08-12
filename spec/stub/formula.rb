# frozen_string_literal: true

require "pathname"

class Formula
  def initialize(name)
    @prefix = Pathname("/usr/local")
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

  def linked_keg
    @prefix.join("var").join("homebrew").join("linked").join(@name)
  end

  def linked?
    true
  end

  def self.installed
    []
  end

  def self.[](name)
    new(name)
  end

  def bottle_disabled?
    false
  end

  def bottle_defined?
    true
  end

  def bottle_hash
    {}
  end

  attr_reader :name

  def full_name
    @name
  end

  def desc
    ""
  end

  def oldname
    nil
  end

  def aliases
    []
  end

  def runtime_dependencies
    []
  end

  def deps
    []
  end

  def conflicts
    []
  end

  def pinned?
    false
  end

  def outdated?
    false
  end

  def any_installed_prefix
    opt_prefix
  end

  def tap
    OpenStruct.new official?: true
  end
end

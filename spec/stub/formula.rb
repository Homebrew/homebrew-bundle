# frozen_string_literal: true

require "ostruct"
require "pathname"

# This pattern is a slight remix of `HOMEBREW_TAP_FORMULA_NAME_REGEX` and
# `HOMEBREW_TAP_FORMULA_REGEX`
# https://github.com/Homebrew/brew/blob/4.4.4/Library/Homebrew/tap_constants.rb#L4-L10
HOMEBREW_TAP_NAME_REGEX = %r{\A(?<tap>(?:[^/]+)/(?:[^/]+))/(?:[\w+\-.@]+)\Z}

class Formula
  def initialize(name)
    @prefix = Pathname("/usr/local")
    @name = name
    @tap_name = (match = HOMEBREW_TAP_NAME_REGEX.match(name)) && match[:tap]
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

  def oldnames
    []
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
    OpenStruct.new(official?: true, name: @tap_name)
  end

  def stable
    OpenStruct.new(bottled?: true, bottle_defined?: true)
  end
end

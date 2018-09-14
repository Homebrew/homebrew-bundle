# frozen_string_literal: true

# check ruby version before requiring any modules.
RUBY_VERSION_SPLIT = RUBY_VERSION.split "."
RUBY_X = RUBY_VERSION_SPLIT[0].to_i
RUBY_Y = RUBY_VERSION_SPLIT[1].to_i
TOO_OLD_RUBY = RUBY_X < 2 || (RUBY_X == 2 && RUBY_Y < 3)
raise "Homebrew Bundle must be run under Ruby 2.3!" if TOO_OLD_RUBY

require "bundle/bouncer"
require "bundle/brewfile"
require "bundle/bundle"
require "bundle/dsl"
require "bundle/checker"
require "bundle/brew_services"
require "bundle/brew_service_checker"
require "bundle/brew_installer"
require "bundle/brew_checker"
require "bundle/cask_installer"
require "bundle/mac_app_store_installer"
require "bundle/mac_app_store_checker"
require "bundle/tap_installer"
require "bundle/brew_dumper"
require "bundle/cask_dumper"
require "bundle/cask_checker"
require "bundle/mac_app_store_dumper"
require "bundle/tap_dumper"
require "bundle/tap_checker"
require "bundle/dumper"
require "bundle/installer"
require "bundle/lister"
require "bundle/commands/install"
require "bundle/commands/dump"
require "bundle/commands/cleanup"
require "bundle/commands/check"
require "bundle/commands/exec"
require "bundle/commands/list"

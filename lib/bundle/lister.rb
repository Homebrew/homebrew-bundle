# frozen_string_literal: true

module Bundle
  module Lister
    module_function

    def list(entries)
      entries.each do |entry|
        next if Bundle::Bouncer.refused? entry
        puts entry.name if show? entry.type
      end
    end

    def self.show?(type)
      return true if ARGV.include?("--all")
      return true if ARGV.include?("--casks") && type == :cask
      return true if ARGV.include?("--taps") && type == :tap
      return true if ARGV.include?("--mas") && type == :mac_app_store
      return true if ARGV.include?("--brews") && type == :brew
      return true if type == :brew && ["--casks", "--taps", "--mas"].none? { |e| ARGV.include?(e) }
    end
  end
end

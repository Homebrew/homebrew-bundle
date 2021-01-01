# frozen_string_literal: true

require "pathname"

def which(command)
  Pathname.new("/usr/local/bin/#{command}")
end

def opoo(*); end

def tap_and_name_comparison
  proc do |a, b|
    if a.include?("/") && b.exclude?("/")
      1
    elsif a.exclude?("/") && b.include?("/")
      -1
    else
      a <=> b
    end
  end
end

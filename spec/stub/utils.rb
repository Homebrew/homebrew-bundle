# frozen_string_literal: true

require "pathname"

def which(command)
  Pathname.new("/usr/local/bin/#{command}")
end

def opoo(*); end

# frozen_string_literal: true

require "pathname"

def which(command)
  Pathname("/usr/local/bin/#{command}")
end

def opoo(*); end

def odie(*)
  exit 1
end

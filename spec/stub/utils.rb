require "pathname"

def which(command)
  Pathname.new("/usr/local/bin/#{command}")
end

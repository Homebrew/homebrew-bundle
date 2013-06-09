module Brewdler
  class Installer
    def self.install(type, name)
      if type == 'brew'
        `brew install #{name}`
      elsif type == 'cask'
        `brew cask install #{name}`
      end 
    end
  end
end

module Brewdler
  class Dsl
    def initialize(input)
      @input = input
    end

    def process
      instance_eval(@input)
    end

    def brew(name)
      Brewdler::Installer.install('brew', name)
    end

    def cask(name)
      Brewdler::Installer.install('cask', name)
    end
  end
end

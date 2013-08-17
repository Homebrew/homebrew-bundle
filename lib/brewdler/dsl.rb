module Brewdler
  class Dsl
    def initialize(input)
      @input = input
    end

    def process
      instance_eval(@input)
    end

    def brew(name)
      Brewdler::BrewInstaller.install(name)
    end

    def cask(name)
      Brewdler::CaskInstaller.install(name)
    end

    def tap(name)
      Brewdler::RepoInstaller.install(name)
    end
  end
end

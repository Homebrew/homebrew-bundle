module Brewdler
  class Dsl
    def initialize(input)
      @input = input
    end

    def process
      instance_eval(@input)
    end

    def brew(name, options={})
      Brewdler::BrewInstaller.install(name, options)
    end

    def cask(name)
      Brewdler::CaskInstaller.install(name)
    end

    def tap(name)
      Brewdler::RepoInstaller.install(name)
    end
  end
end

module Brewdler
  class Dsl
    def initialize(input, mode)
      @input = input
      @mode = mode
    end

    def process
      eval(@input)
    end

    def brew(name, options={})
      if @mode == "install"
        Brewdler::BrewInstaller.install(name, options)
      elsif @mode == "upgrade"
        Brewdler::BrewInstaller.upgrade(name, options)
      end
    end

    def cask(name)
      Brewdler::CaskInstaller.install(name)
    end

    def tap(name)
      Brewdler::RepoInstaller.install(name)
    end
  end
end

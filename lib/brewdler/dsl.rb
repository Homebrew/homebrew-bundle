module Brewdler
  class Dsl
    class Entry
      attr_reader :type, :name, :extra

      def initialize(type, name, extra={})
        @type = type
        @name = name
        @extra = extra
      end
    end

    attr_reader :entries

    def initialize(input)
      @input = input
      @entries = []
    end

    def process
      instance_eval(@input)
      self
    end

    def install
      @entries.each do |entry|
        case entry.type
        when :brew then Brewdler::BrewInstaller.install(entry.name, entry.extra[:options])
        when :cask then Brewdler::CaskInstaller.install(entry.name)
        when :repo then Brewdler::RepoInstaller.install(entry.name)
        end
      end
    end

    def brew(name, options={})
      @entries << Entry.new(:brew, name, {:options => options})
    end

    def cask(name)
      @entries << Entry.new(:cask, name)
    end

    def tap(name)
      @entries << Entry.new(:repo, name)
    end
  end
end

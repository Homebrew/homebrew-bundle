module Bundle
  class Dsl
    class Entry
      attr_reader :type, :name, :options

      def initialize(type, name, options={})
        @type = type
        @name = name
        @options = options
      end
    end

    attr_reader :entries

    def initialize(input)
      @input = input
      @entries = []
      begin
        process
      rescue
        raise "Invalid Brewfile."
      end
    end

    def process
      @input.untaint
      proc {
        $SAFE = 3
        instance_eval(@input)
      }.call
    end

    def install
      success = fail = 0
      @entries.each do |entry|
        arg = [entry.name]
        cls = case entry.type
              when :brew
                arg << entry.options
                verb = "install"
                Bundle::BrewInstaller
              when :cask
                verb = "install"
                Bundle::CaskInstaller
              when :repo
                verb = "tap"
                Bundle::RepoInstaller
              end
        if cls.install(*arg)
          puts "Succeeded to #{verb} #{entry.name}"
          success += 1
        else
          puts "Failed to #{verb} #{entry.name}"
          fail += 1
        end
      end
      puts "\nSuccess: #{success} Fail: #{fail}"
    end

    def brew(name, options={})
      @entries << Entry.new(:brew, name, options)
    end

    def cask(name)
      @entries << Entry.new(:cask, name)
    end

    def tap(name)
      @entries << Entry.new(:repo, name)
    end
  end
end

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
      @cask_opts = {}
      process
    end

    def process
      instance_eval(@input)
    end

    def install
      success = fail = 0
      @entries.each do |entry|
        arg = [entry.name]
        cls = case entry.type
              when :brew
                arg << entry.options
                verb = "installing"
                Bundle::BrewInstaller
              when :cask
                arg << entry.options
                verb = "installing"
                Bundle::CaskInstaller
              when :repo
                arg << entry.options[:clone_target]
                verb = "tapping"
                Bundle::RepoInstaller
              end
        if cls.install(*arg)
          puts "Succeeded in #{verb} #{entry.name}"
          success += 1
        else
          puts "Failed in #{verb} #{entry.name}"
          fail += 1
        end
      end
      puts "\nSuccess: #{success} Fail: #{fail}"
      fail == 0
    end

    def cask_opts(args)
      @cask_opts = args
    end

    def brew(name, options={})
      @entries << Entry.new(:brew, name, options)
    end

    def cask(name, options={})
      options = @cask_opts.merge(options)

      @entries << Entry.new(:cask, name, options)
    end

    def tap(name, clone_target=nil)
      @entries << Entry.new(:repo, name, :clone_target => clone_target)
    end
  end
end

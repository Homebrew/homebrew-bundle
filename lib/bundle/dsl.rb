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
          puts "Succeed to #{verb} #{entry.name}"
          success += 1
        else
          puts "Fail to #{verb} #{entry.name}"
          fail += 1
        end
      end
      puts "\nSuccess: #{success} Fail: #{fail}"
    end

    def brew(*args)
      names, options = if args.last.is_a? Hash
        [args[0...-1], args.last]
      else
        [args, {}]
      end

      names.each do |name|
        @entries << Entry.new(:brew, name, options)
      end
    end

    def cask(*names)
      names.each do |name|
        @entries << Entry.new(:cask, name)
      end
    end

    def tap(*names)
      names.each do |name|
        @entries << Entry.new(:repo, name)
      end
    end
  end
end

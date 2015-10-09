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
      rescue => e
        error_msg = "Invalid Brewfile."
        if ARGV.verbose?
          error_msg += "\n#{e}"
          error_msg += "\n#{e.backtrace.join "\n"}"
        end
        raise error_msg
      end
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
                verb = "installing"
                Bundle::CaskInstaller
              when :tap
                arg << entry.options[:clone_target]
                verb = "tapping"
                Bundle::TapInstaller
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

    def brew(name, options={})
      @entries << Entry.new(:brew, name, options)
    end

    def cask(name)
      @entries << Entry.new(:cask, name)
    end

    def tap(name, clone_target=nil)
      @entries << Entry.new(:tap, name, :clone_target => clone_target)
    end
  end
end

module Bundle
  class Dsl
    class Entry
      attr_reader :type, :name, :options

      def initialize(type, name, options = {})
        @type = type
        @name = name
        @options = options
      end
    end

    attr_reader :entries

    def initialize(input)
      @input = input
      @entries = []
      @cask_args = {}

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
      success = 0
      failure = 0

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
          failure += 1
        end
      end
      puts "\nSuccess: #{success} Fail: #{failure}"

      failure.zero?
    end

    def cask_args(args)
      @cask_args = args
    end

    def brew(name, options = {})
      name = Bundle::Dsl.sanitize_brew_name(name)
      @entries << Entry.new(:brew, name, options)
    end

    def cask(name, options = {})
      name = Bundle::Dsl.sanitize_cask_name(name)
      options[:args] = @cask_args.merge options.fetch(:args, {})
      @entries << Entry.new(:cask, name, options)
    end

    def tap(name, clone_target = nil)
      name = Bundle::Dsl.sanitize_tap_name(name)
      @entries << Entry.new(:tap, name, :clone_target => clone_target)
    end

    private

    HOMEBREW_TAP_ARGS_REGEX = %r{^([\w-]+)/(homebrew-)?([\w-]+)$}.freeze
    HOMEBREW_CORE_FORMULA_REGEX = %r{^homebrew/homebrew/([\w+-.]+)$}i.freeze
    HOMEBREW_TAP_FORMULA_REGEX = %r{^([\w-]+)/([\w-]+)/([\w+-.]+)$}.freeze

    def self.sanitize_brew_name(name)
      name.downcase!
      if name =~ HOMEBREW_CORE_FORMULA_REGEX
        $1
      elsif name =~ HOMEBREW_TAP_FORMULA_REGEX
        user = $1
        repo = $2
        name = $3
        "#{user}/#{repo.sub /homebrew-/, ""}/#{name}"
      else
        name
      end
    end

    def self.sanitize_tap_name(name)
      name.downcase!
      if name =~ HOMEBREW_TAP_ARGS_REGEX
        "#{$1}/#{$3}"
      else
        name
      end
    end

    def self.sanitize_cask_name(name)
      name.downcase
    end
  end
end

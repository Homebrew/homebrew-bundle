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
      @caskdefaults = {}
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

    def cask_defaults(args)
      # You can also modify the default installation locations used when issuing brew cask install:
      #
      # --caskroom=/my/path determines where the actual applications will be located. Should be handled with care — setting it outside /opt or your home directory might mess up your system. Default is /opt/homebrew-cask/Caskroom.
      # --appdir=/my/path changes the path where the symlinks to the applications (above) will be generated. This is commonly used to create the links in the root Applications directory instead of the home Applications directory by specifying --appdir=/Applications. Default is ~/Applications.
      # --prefpanedir=/my/path changes the path for PreferencePane symlinks. Default is ~/Library/PreferencePanes
      # --qlplugindir=/my/path changes the path for Quicklook Plugin symlinks. Default is ~/Library/QuickLook
      # --fontdir=/my/path changes the path for Fonts symlinks. Default is ~/Library/Fonts
      # --binarydir=/my/path changes the path for binary symlinks. Default is /usr/local/bin
      # --input_methoddir=/my/path changes the path for Input Methods symlinks. Default is ~/Library/Input Methods
      # --screen_saverdir=/my/path changes the path for Screen Saver symlinks. Default is ~/Library/Screen Savers
      @caskdefaults = args
    end

    def brew(name, options={})
      @entries << Entry.new(:brew, name, options)
    end

    def cask(name, options={})
      options = @caskdefaults.merge(options)

      @entries << Entry.new(:cask, name, options)
    end

    def tap(name, clone_target=nil)
      @entries << Entry.new(:repo, name, :clone_target => clone_target)
    end
  end
end

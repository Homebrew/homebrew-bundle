# frozen_string_literal: true

module Bundle
  class Dsl
    class Entry
      attr_reader :type, :name, :options

      def initialize(type, name, options = {})
        @type = type
        @name = name
        @options = options
        @options[:group] ||= []
      end

      def to_s
        name
      end

      def excluded_by?(without_groups)
        return false if options[:group].empty?
        (options[:group] - without_groups).empty?
      end
    end

    attr_reader :entries, :cask_arguments, :groups

    def initialize(input)
      @input = input
      @current_groups = []
      @groups = Set.new
      @entries = []
      @cask_arguments = {}

      begin
        process
      # Want to catch all exceptions for e.g. syntax errors.
      rescue Exception => e # rubocop:disable Lint/RescueException
        error_msg = "Invalid Brewfile: #{e.message}"
        raise RuntimeError, error_msg, e.backtrace
      end
    end

    def process
      instance_eval(@input)
    end

    def cask_args(args)
      raise "cask_args(#{args.inspect}) should be a Hash object" unless args.is_a? Hash

      @cask_arguments = args
    end

    def brew(name, options = {})
      raise "name(#{name.inspect}) should be a String object" unless name.is_a? String
      raise "options(#{options.inspect}) should be a Hash object" unless options.is_a? Hash

      name = Bundle::Dsl.sanitize_brew_name(name)
      options[:group] = Bundle::Dsl.determine_groups(@current_groups, [*options[:group]])
      @entries << Entry.new(:brew, name, options)
    end

    def cask(name, options = {})
      raise "name(#{name.inspect}) should be a String object" unless name.is_a? String
      raise "options(#{options.inspect}) should be a Hash object" unless options.is_a? Hash

      options[:full_name] = name
      name = Bundle::Dsl.sanitize_cask_name(name)
      options[:args] = @cask_arguments.merge options.fetch(:args, {})
      options[:group] = Bundle::Dsl.determine_groups(@current_groups, [*options[:group]])
      @entries << Entry.new(:cask, name, options)
    end

    def mas(name, options = {})
      id = options[:id]
      raise "name(#{name.inspect}) should be a String object" unless name.is_a? String
      raise "options[:id](#{id}) should be an Integer object" unless id.is_a? Integer

      options = {
        id: id,
        group: Bundle::Dsl.determine_groups(@current_groups, [*options[:group]])
      }
      @entries << Entry.new(:mas, name, options)
    end

    def whalebrew(name, options = {})
      raise "name(#{name.inspect}) should be a String object" unless name.is_a? String

      options[:group] = Bundle::Dsl.determine_groups(@current_groups, [*options[:group]])
      @entries << Entry.new(:whalebrew, name, options)
    end

    def tap(name, clone_target = nil)
      raise "name(#{name.inspect}) should be a String object" unless name.is_a? String
      if clone_target && !clone_target.is_a?(String)
        raise "clone_target(#{clone_target.inspect}) should be nil or a String object"
      end

      name = Bundle::Dsl.sanitize_tap_name(name)
      @entries << Entry.new(:tap, name, clone_target: clone_target, group: @current_groups)
    end

    def group(*names, &block)
      raise "group cannot be used within a group" unless @current_groups.empty?
      names.each do |name|
        raise "name(#{name.inspect}) should be a Symbol object" unless name.is_a? Symbol
      end

      @groups.merge(names)
      @current_groups = names
      instance_exec self, &block
      @current_groups = []
    end

    HOMEBREW_TAP_ARGS_REGEX = %r{^([\w-]+)/(homebrew-)?([\w-]+)$}.freeze
    HOMEBREW_CORE_FORMULA_REGEX = %r{^homebrew/homebrew/([\w+-.@]+)$}i.freeze
    HOMEBREW_TAP_FORMULA_REGEX = %r{^([\w-]+)/([\w-]+)/([\w+-.@]+)$}.freeze

    def self.sanitize_brew_name(name)
      name = name.downcase
      if name =~ HOMEBREW_CORE_FORMULA_REGEX
        Regexp.last_match(1)
      elsif name =~ HOMEBREW_TAP_FORMULA_REGEX
        user = Regexp.last_match(1)
        repo = Regexp.last_match(2)
        name = Regexp.last_match(3)
        "#{user}/#{repo.sub(/homebrew-/, "")}/#{name}"
      else
        name
      end
    end

    def self.sanitize_tap_name(name)
      name = name.downcase
      if name =~ HOMEBREW_TAP_ARGS_REGEX
        "#{Regexp.last_match(1)}/#{Regexp.last_match(3)}"
      else
        name
      end
    end

    def self.sanitize_cask_name(name)
      name = name.split("/").last if name.include?("/")
      name.downcase
    end

    def self.pluralize_dependency(installed_count)
      (installed_count == 1) ? "dependency" : "dependencies"
    end

    def self.determine_groups(block_groups, options_groups)
      raise "groups cannot be specified as an option, if also within a group block" if block_groups.any? && options_groups.any?
      block_groups + options_groups
    end
  end
end

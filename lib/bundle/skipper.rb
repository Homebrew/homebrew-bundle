# frozen_string_literal: true

require 'yaml'

module Bundle
  module Skipper
    module_function

    def skip?(entry)
      Array(skipped_entries[entry.type.to_s]).include?(entry.name).tap do |skipped|
        puts Formatter.warning "Skipping #{entry.name}" if skipped
      end
    end

    private_class_method

    def skipped_entries
      #FIXME ought to be using XDG here but homebrew nukes the env :rage:
      @skipper ||= YAML.load_file Pathname.new("~/.config/homebrew/skipper.yml").expand_path rescue {}
    end
  end
end

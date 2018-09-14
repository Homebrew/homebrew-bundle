# frozen_string_literal: true

require 'yaml'

module Bundle
  module Bouncer
    module_function

    def refused?(entry)
      Array(refused_entries[entry.type.to_s]).include?(entry.name).tap do |refused|
        puts Formatter.warning "Refusing #{entry.name}" if refused
      end
    end

    private_class_method
    def refused_entries
      #FIXME ought to be using XDG here but homebrew nukes the env :rage:
      @bouncer ||= YAML.load_file Pathname.new("~/.config/homebrew/bounce.yml").expand_path rescue {}
    end
  end
end

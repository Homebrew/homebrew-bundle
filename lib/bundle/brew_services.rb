# frozen_string_literal: true

module Bundle
  module BrewServices
    module_function

    def reset!
      @started_services = nil
    end

    def stop(name, verbose: false)
      return true unless started?(name)

      return unless Bundle.system HOMEBREW_BREW_FILE, "services", "stop", name, verbose: verbose

      started_services.delete(name)
      true
    end

    def start(name, verbose: false)
      return unless Bundle.system HOMEBREW_BREW_FILE, "services", "start", name, verbose: verbose

      started_services << name
      true
    end

    def restart(name, verbose: false)
      return unless Bundle.system HOMEBREW_BREW_FILE, "services", "restart", name, verbose: verbose

      started_services << name
      true
    end

    def started?(name)
      started_services.include? name
    end

    def started_services
      @started_services ||= if Bundle.services_installed?
        states_to_skip = %w[stopped none]
        Utils.safe_popen_read(HOMEBREW_BREW_FILE, "services", "list").lines.filter_map do |line|
          name, state, _plist = line.split(/\s+/)
          next if states_to_skip.include? state

          name
        end
      else
        []
      end
    end
  end
end

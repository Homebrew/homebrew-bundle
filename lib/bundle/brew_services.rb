# frozen_string_literal: true

module Bundle
  module BrewServices
    module_function

    def reset!
      @started_services = nil
    end

    def stop(name, verbose: false)
      return true unless started?(name)

      if Bundle.system "brew", "services", "stop", name, verbose: verbose
        started_services.delete(name)
        true
      end
    end

    def restart(name, verbose: false)
      if Bundle.system "brew", "services", "restart", name, verbose: verbose
        started_services << name
        true
      end
    end

    def started?(name)
      started_services.include? name
    end

    def started_services
      @started_services ||= if Bundle.services_installed?
        `brew services list`.lines.map do |line|
          name, state, _plist = line.split(/\s+/)
          next if state == "stopped"

          name
        end.compact
      else
        []
      end
    end
  end
end

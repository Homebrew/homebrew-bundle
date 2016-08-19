module Bundle
  class BrewServices
    def self.reset!
      @started_services = nil
    end

    def self.stop(name)
      return true unless started?(name)
      if Bundle.system "brew", "services", "stop", name
        started_services.delete(name)
        true
      end
    end

    def self.restart(name)
      if Bundle.system "brew", "services", "restart", name
        started_services << name
        true
      end
    end

    def self.started?(name)
      started_services.include? name
    end

    def self.started_services
      @started_services ||= if Bundle.services_installed?
        `brew services list`.lines.map do |line|
          name, state, _plist = line.split(/\s+/)
          next unless state == "started"
          name
        end.compact
      else
        []
      end
    end
  end
end

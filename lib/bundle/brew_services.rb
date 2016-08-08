module Bundle
  class BrewServices
    attr_accessor :started_services

    def initialize()
      @started_services = []
      started = `brew services list`.lines.grep(/started/)
      for f in started
        parts=f.split(/\s+/)
        @started_services << Hash[:name => parts[0], :user => parts[2], :plist => parts[3]]
      end
    end

    def self.stop(name)
      started = `brew services list`.lines.grep(/^#{Regexp.escape(name)} +started/).any?
      return true unless started
      Bundle.system "brew", "services", "stop", name
    end

    def self.restart(name)
      Bundle.system "brew", "services", "restart", name
    end

    def started?(name)
      for svc in @started_services
        return true if svc[:name] == name
      end
      return false
    end
  end
end

module Bundle
  class BrewServices
    def self.stop(name)
      started = `brew services list`.lines.grep(/^#{Regexp.escape(name)} +started/).any?
      return true unless started
      Bundle.system "brew", "services", "stop", name
    end

    def self.restart(name)
      Bundle.system "brew", "services", "restart", name
    end

    def self.started?(name)
      if @started_services.nil?
        @started_services = []
        started = `brew services list`.lines.grep(/started/)
        for s in started
          parts=s.split(/\s+/)
          @started_services << Hash[:name => parts[0], :user => parts[2], :plist => parts[3]]
        end
      end

      ret = false
      for svc in @started_services
        ret = true if svc[:name] == name
      end
      return ret
    end
  end
end

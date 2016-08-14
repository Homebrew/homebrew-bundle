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
      @started_services ||= `brew services list`.lines.grep(/started/)
      started_service_names = @started_services.map {|s| s.split(/\s+/).first}
      started_service_names.include? name
    end
  end
end

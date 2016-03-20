module Bundle
  class BrewServices
    def self.stop(name)
      started = `brew services list`.lines.grep(/^#{name} +started/).any?
      return true unless started
      Bundle.system "brew", "services", "stop", name
    end

    def self.restart(name)
      Bundle.system "brew", "services", "restart", name
    end
  end
end

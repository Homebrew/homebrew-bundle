module Bundle
  class BrewServices
    def self.restart(name)
      Bundle.system "brew", "services", "restart", name
    end
  end
end

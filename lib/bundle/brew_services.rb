module Bundle
  class BrewServices
    def self.stop(name)
      started = !`brew services list | grep "#{name}" | grep -q "started"`.chomp.empty?
      return true unless started
      Bundle.system "brew", "services", "stop", name
    end

    def self.restart(name)
      Bundle.system "brew", "services", "restart", name
    end
  end
end

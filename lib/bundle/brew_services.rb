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
        @started_services ||= []
        @started_names ||= []
        `brew services list`.lines.grep(/started/).map do |s|
          s.split(/\s+/).each do |fname, state, user, plist|
            @started_services << Hash[:name => fname, :user => user, :plist => plist]
            @started_names << fname
          end
        end
      end

      @started_names.include? name
    end
  end
end

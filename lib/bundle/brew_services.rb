module Bundle
  class BrewServices
    def initialize(name)
      ensure_brew_services_installed
      @name = name
    end

    def self.restart(name)
      new(name).restart
    end

    def ensure_brew_services_installed
      unless Bundle.services_installed?
        Bundle.system "brew", "tap", "homebrew/services"

        unless Bundle.services_installed?
          raise "Unable to restart #{@name}. brew-services is not currently installed on your system"
        end
      end
    end

    def restart
      Bundle.system "brew", "services", "restart", @name
    end
  end
end

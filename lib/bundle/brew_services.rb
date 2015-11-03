module Bundle
  class BrewServices
    def self.restart(name)
      ensure_brew_services_installed!
      Bundle.system "brew", "services", "restart", name
    end

    def self.ensure_brew_services_installed!
      unless Bundle.services_installed?
        Bundle.system "brew", "tap", "homebrew/services"

        unless Bundle.services_installed?
          raise "Unable to restart #{@name}. brew-services is not currently installed on your system"
        end
      end
    end
  end
end

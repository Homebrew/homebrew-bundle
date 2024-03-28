# frozen_string_literal: true

module Bundle
  class TlmgrPackageInstaller
    def self.reset!
      @installed_packages = nil
      @outdated_packages = nil
    end

    def self.preinstall(name, no_upgrade: false, verbose: false, **options)
      new(name, options).preinstall(no_upgrade:, verbose:)
    end

    def self.install(name, preinstall: true, no_upgrade: false, verbose: false, force: false, **options)
      new(name, options).install(preinstall:, no_upgrade:, verbose:)
    end

    def initialize(name, options = {})
      @name = name
      @args = options.fetch(:args, []).map { |arg| "--#{arg}" }
      @changed = nil
    end

    def preinstall(no_upgrade: false, verbose: false)
      message = <<~EOM
        Unable to install #{name} TeX Live package. tlmgr is not installed. Provide it by installing one of 'basictex',
        'mactex', or 'mactex-no-gui'"
      EOM
      raise message unless Bundle.tlmgr_installed?

      if installed? && (no_upgrade || !upgradable?)
        puts "Skipping install of #{name} TeX Live package. It is already installed." if verbose
        @changed = nil
        return false
      end

      true
    end

    def install(preinstall: true, no_upgrade: false, verbose: false, force: false)
      if preinstall
        install_change_state!(no_upgrade:, verbose:, force:)
      else
        true
      end
    end

    def changed?
      @changed.present?
    end

    def self.package_installed_and_up_to_date?(package, no_upgrade: false)
      return false unless package_installed?(package)
      return true if no_upgrade

      !package_upgradable?(package)
    end

    def self.package_in_array?(package, array)
      return true if array.include?(package)

      resolved_name = Bundle::TlmgrPackageDumper.packages[package]
      return false unless resolved_name
      return true if array.include?(resolved_name)

      false
    end

    def self.package_installed?(package)
      package_in_array?(package, installed_packages)
    end

    def self.package_upgradable?(package)
      package_in_array?(package, upgradable_packages) && Formula[package].outdated?
    end

    def self.installed_packages
      @installed_packages ||= packages
    end

    def self.upgradable_packages
      outdated_packages
    end

    def self.outdated_packages
      @outdated_packages ||= Bundle::TlmgrPackageDumper.outdated_packages
    end

    def self.packages
      Bundle::TlmgrPackageDumper.packages
    end

    def installed?
      TlmgrPackageInstaller.package_installed?(@name)
    end

    def upgradable?
      TlmgrPackageInstaller.package_upgradable?(@name)
    end

    def install!(verbose:, force:)
      install_args = @args.dup
      with_args = " with #{install_args.join(" ")}" if install_args.present?
      puts "Installing #{name} TeX Live package#{with_args}. It is not currently installed." if verbose
      # TODO: See how we can get around the sudo requirement because of the way e.g. basictex installs itself
      # See also https://tug.org/texlive/doc/tlmgr.html#USER-MODE
      unless Bundle.system("sudo", "tlmgr", "install", *install_args, @name, verbose:)
        @changed = nil
        return false
      end

      TlmgrPackageInstaller.installed_packages << @name
      @changed = true
      true
    end

    def upgrade!(verbose:, force:)
      puts "Upgrading #{@name} TeX Live package. It is installed but not up-to-date." if verbose
      # TODO: See how we can get around the sudo requirement because of the way e.g. basictex installs itself
      # See also https://tug.org/texlive/doc/tlmgr.html#USER-MODE
      unless Bundle.system("sudo", "tlmgr", "update", @name, verbose:)
        @changed = nil
        return false
      end
      @changed = true
      true
    end

    def package_installed?(name)
      installed_packages.include? name.downcase
    end

    def installed_packages
      @installed_packages ||= Bundle::TlmgrPackageDumper.extensions
    end
  end
end

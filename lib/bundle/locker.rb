# frozen_string_literal: true

require "tap"
require "os"
require "development_tools"

module Bundle
  module Locker
    module_function

    def lockfile
      brew_file_path = Brewfile.path
      brew_file_path.dirname/"#{brew_file_path.basename}.lock.json"
    end

    def write_lockfile?
      return false if ARGV.include?("--no-lock")
      return false if ENV["HOMEBREW_BUNDLE_NO_LOCK"]

      # handle the /dev/stdin and /dev/stdout cases
      return false if lockfile.parent.to_s == "/dev"

      true
    end

    def lock(entries)
      return false unless write_lockfile?

      lock = JSON.parse(lockfile.read) if lockfile.exist?
      lock ||= {}
      lock["entries"] ||= {}
      lock["system"] ||= {}

      entries.each do |entry|
        next if Bundle::Skipper.skip?(entry, silent: true)

        entry_type_key = entry.type.to_s
        options = entry.options
        lock["entries"][entry_type_key] ||= {}
        lock["entries"][entry_type_key][entry.name] = case entry.type
        when :brew
          brew_list_info[entry.name]
        when :cask
          options.delete(:args) if options[:args].blank?
          { version: cask_list[entry.name] }
        when :mas
          options.delete(:id)
          mas_list[entry.name]
        when :tap
          options.delete(:clone_target) if options[:clone_target].blank?
          options.delete(:pin) if options[:pin] == false
          { revision: Tap.fetch(entry.name).git_head }
        end

        if options.present?
          lock["entries"][entry_type_key][entry.name] ||= {}
          lock["entries"][entry_type_key][entry.name]["options"] =
            options.deep_stringify_keys
        end
      end

      if OS.mac?
        lock["system"]["macos"] ||= {}
        version, hash = system_macos
        lock["system"]["macos"][version] = hash
      elsif OS.linux?
        lock["system"]["linux"] ||= {}
        version, hash = system_linux
        lock["system"]["linux"][version] = hash
      end

      json = JSON.pretty_generate(lock)
      begin
        lockfile.unlink if lockfile.exist?
        lockfile.write(json.to_s + "\n")
      rescue Errno::EPERM, Errno::EACCES, Errno::ENOTEMPTY => e
        opoo "Could not write to #{lockfile}!"
        return false
      end

      true
    end

    def brew_list_info
      @brew_list_info ||= begin
        name_bottles = JSON.parse(`brew info --json=v1 --installed`)
                            .inject({}) do |name_bottles, f|
          bottle = f["bottle"]["stable"]
          bottle&.delete("rebuild")
          bottle&.delete("root_url")
          bottle ||= false
          name_bottles[f["name"]] = bottle
          name_bottles
        end
        `brew list --versions`.lines
                              .inject({}) do |name_versions_bottles, line|
          name, version, = line.split
          name_versions_bottles[name] = {
            version: version,
            bottle: name_bottles[name],
          }
          name_versions_bottles
        end
      end
    end

    def cask_list
      @cask_list ||= begin
        `brew cask list --versions`.lines
                                    .inject({}) do |name_versions, line|
          name, version, = line.split
          name_versions[name] = version
          name_versions
        end
      end
    end

    def mas_list
      @mas_list ||= begin
        `mas list`.lines
                  .inject({}) do |name_id_versions, line|
          line = line.split
          id = line.shift
          version = line.pop.delete("()")
          name = line.join(" ")
          name_id_versions[name] = {
            id:      id,
            version: version,
          }
          name_id_versions
        end
      end
    end

    def system_macos
      [MacOS.version.to_sym.to_s, {
        "HOMEBREW_VERSION"       => HOMEBREW_VERSION,
        "HOMEBREW_PREFIX"        => HOMEBREW_PREFIX.to_s,
        "Homebrew/homebrew-core" => CoreTap.instance.git_head,
        "CLT"                    => MacOS::CLT.version.to_s,
        "Xcode"                  => MacOS::Xcode.version.to_s,
        "macOS"                  => MacOS.full_version.to_s,
      }]
    end

    def system_linux
      [OS::Linux.os_version, {
        "HOMEBREW_VERSION"        => HOMEBREW_VERSION,
        "HOMEBREW_PREFIX"         => HOMEBREW_PREFIX.to_s,
        "Homebrew/linuxbrew-core" => CoreTap.instance.git_head,
        "GCC"                     => DevelopmentTools.non_apple_gcc_version("gcc"),
      }]
    end
  end
end

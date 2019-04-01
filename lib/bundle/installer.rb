# frozen_string_literal: true

module Bundle
  module Installer
    module_function

    InstallerTask = Struct.new :cls, :arg, :verb

    def installer_class_and_args_for_entry(entry)
      verb = 'Installing'
      arg = [entry.name]
      cls = case entry.type
            when :brew
              arg << entry.options
              Bundle::BrewInstaller
            when :cask
              arg << entry.options
              Bundle::CaskInstaller
            when :mac_app_store
              arg << entry.options[:id]
              Bundle::MacAppStoreInstaller
            when :tap
              verb = 'Tapping'
              arg << entry.options
              Bundle::TapInstaller
            end
      InstallerTask.new cls, arg, verb
    end

    def install(entries)
      success = 0
      failure = 0
      errored_entries = {}

      entries.each do |entry|
        task = installer_class_and_args_for_entry(entry)
        task_header = "#{task.verb} #{entry.name}"
        begin
          case task.cls.install(*task.arg)
          when :success
            puts Formatter.success(task_header)
            success += 1
          when :skipped
            puts "Using #{entry.name}"
            success += 1
          else
            puts Formatter.error("#{task_header} has failed!")
            failure += 1
          end
        rescue => e
          puts Formatter.error("#{task_header} raised an exception: #{e}")
          errored_entries[entry.name] = e
        end
      end

      if failure.zero?
        puts Formatter.success("Homebrew Bundle complete! #{success} Brewfile #{Bundle::Dsl.pluralize_dependency(success)} now installed.")
      else
        puts Formatter.error("Homebrew Bundle failed! #{failure} Brewfile #{Bundle::Dsl.pluralize_dependency(failure)} failed to install.")
      end

      if errored_entries.any?
        error_count = errored_entries.size
        words = Bundle::Dsl.pluralize_dependency(error_count)
        error_text = "Homebrew Bundle encountered some errors. #{error_count} Brewfile #{words} failed badly:"
        puts Formatter.error(error_text)
        errored_entries.each do |entry, error|
          puts Formatter.error("\t#{entry}\t => \t#{error}")
        end
      end

      failure.zero? && errored_entries.empty?
    end
  end
end

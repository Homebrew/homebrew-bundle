# frozen_string_literal: true

module Bundle
  module Installer
    module_function

    def install(entries)
      end_state = install_entries(entries)

      failures = end_state[:failed]
      report_success_and_failure(end_state)

      errored_entries = end_state[:errored]
      report_errors(errored_entries) if errored_entries.any?

      failures.zero? && errored_entries.empty?
    end

    def task_for_entry(entry)
      # TODO: move verb into the Installer classes
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
      InstallerTask.new cls, arg, verb, entry
    end

    def report_result(task, result)
      case result
      when :success
        puts Formatter.success(task.header)
      when :skipped
        puts "Using #{task.entry.name}"
      when :failed
        puts Formatter.error("#{task.header} has failed!")
      else
        puts Formatter.error("#{task.header} in unknown state: #{result}")
      end
    end

    def report_error(task, error)
      puts Formatter.error("#{task.header} raised an exception: #{error}")
    end

    def execute_task(task)
      begin
        result = task.cls.install(*task.arg)
        report_result(task, result)
        { result => 1 }
      rescue => error
        report_error(task, error)
        { errored: { task.entry.name => error } }
      end
    end

    def install_entries(entries)
      initial_state = {
        success: 0,
        skipped: 0,
        failed: 0,
        errored: {}
      }

      entries.reduce(initial_state) do |state, entry|
        task = task_for_entry(entry)
        result = execute_task(task)
        combine_states(state, result)
      end
    end

    def combine_states(state, result)
      state.merge(result) do |_, old, new|
        case old
        when Integer # for the counts
          old + new
        when Hash # for statuses with info
          old.merge(new)
        else
          raise "Unexpected class in state: #{old.class}"
        end
      end
    end

    def report_success_and_failure(end_state)
      failures = end_state[:failed]
      if failures.zero?
        succeeded = end_state[:success] || 0
        skipped = end_state[:skipped] || 0
        installed = succeeded + skipped
        puts Formatter.success("Homebrew Bundle complete! #{installed} Brewfile #{Bundle::Dsl.pluralize_dependency(installed)} now installed.")
      else
        puts Formatter.error("Homebrew Bundle failed! #{failures} Brewfile #{Bundle::Dsl.pluralize_dependency(failures)} failed to install.")
      end
    end

    def report_errors(errored_entries)
      error_count = errored_entries.size
      words = Bundle::Dsl.pluralize_dependency(error_count)
      error_text = "Homebrew Bundle encountered some errors. #{error_count} Brewfile #{words} failed badly:"
      puts Formatter.error(error_text)
      errored_entries.each do |entry, error|
        puts Formatter.error("\t#{entry}\t => \t#{error}")
      end
    end

    InstallerTask = Struct.new :cls, :arg, :verb, :entry do
      def header
        "#{verb} #{entry.name}"
      end
    end
  end
end

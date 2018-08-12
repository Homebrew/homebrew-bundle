# frozen_string_literal: true

module Bundle
  module Commands
    module Check
      module_function

      ARROW = "→"
      FAILURE_MESSAGE = "brew bundle can't satisfy your Brewfile's dependencies."

      def output_errors?
        ARGV.include?("--verbose")
      end

      def exit_on_first_error?
        !ARGV.include?("--verbose")
      end

      def run
        check_result = Bundle::Checker.check(exit_on_first_error?)

        if check_result.work_to_be_done
          puts FAILURE_MESSAGE

          if output_errors?
            checks = Bundle::Checker::CHECKS
            check_result.completed_checks.each { |checked| puts "#{checks[checked]} were checked." }
            check_result.unchecked_checks.each { |unchecked| puts "#{checks[unchecked]} were not checked." }
            check_result.errors.each { |package| puts "#{ARROW} #{package}" }
          end
          puts "Satisfy missing dependencies with `brew bundle install`."
          exit 1
        elsif Bundle::Checker.any_formulae_to_start?
          puts FAILURE_MESSAGE
          puts "At least one brew formula must be started."
          exit 1
        else
          puts "The Brewfile's dependencies are satisfied."
        end
      end
    end
  end
end

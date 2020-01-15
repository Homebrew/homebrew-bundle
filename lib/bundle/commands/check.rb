# frozen_string_literal: true

module Bundle
  module Commands
    module Check
      module_function

      ARROW = "→"
      FAILURE_MESSAGE = "brew bundle can't satisfy your Brewfile's dependencies."

      def output_errors?
        ARGV.verbose?
      end

      def exit_on_first_error?
        !ARGV.verbose?
      end

      def run
        check_result = Bundle::Checker.check(exit_on_first_error?)

        if check_result.work_to_be_done
          puts FAILURE_MESSAGE

          if output_errors?
            check_result.errors.each { |package| puts "#{ARROW} #{package}" }
          end
          puts "Satisfy missing dependencies with `brew bundle install`."
          exit 1
        else
          puts "The Brewfile's dependencies are satisfied."
        end
      end
    end
  end
end

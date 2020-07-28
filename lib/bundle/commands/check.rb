# frozen_string_literal: true

module Bundle
  module Commands
    module Check
      module_function

      ARROW = "→"
      FAILURE_MESSAGE = "brew bundle can't satisfy your Brewfile's dependencies."

      def output_errors?
        Homebrew.args.verbose?
      end

      def exit_on_first_error?
        !Homebrew.args.verbose?
      end

      def run(global: false, file: nil, no_upgrade: false)
        check_result = Bundle::Checker.check(exit_on_first_error?, global: global, file: file, no_upgrade: no_upgrade)

        if check_result.work_to_be_done
          puts FAILURE_MESSAGE

          check_result.errors.each { |package| puts "#{ARROW} #{package}" } if output_errors?
          puts "Satisfy missing dependencies with `brew bundle install`."
          exit 1
        else
          puts "The Brewfile's dependencies are satisfied."
        end
      end
    end
  end
end

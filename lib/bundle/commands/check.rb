# frozen_string_literal: true

module Bundle
  module Commands
    module Check
      module_function

      ARROW = "→"
      FAILURE_MESSAGE = "brew bundle can't satisfy your Brewfile's dependencies."

      def run(global: false, file: nil, no_upgrade: false, verbose: false)
        output_errors = verbose
        exit_on_first_error = !verbose
        check_result = Bundle::Checker.check(
          global: global, file: file,
          exit_on_first_error: exit_on_first_error, no_upgrade: no_upgrade, verbose: verbose
        )

        if check_result.work_to_be_done
          opoo FAILURE_MESSAGE

          check_result.errors.each { |package| ohai(ARROW, package.to_s) } if output_errors
          ohai "Satisfy missing dependencies with `brew bundle install`."
          exit 1
        else
          ohai "The Brewfile's dependencies are satisfied."
        end
      end
    end
  end
end

module Bundle
  module Commands
    module Install
      module_function

      def run
        Bundle::Dsl.new(Bundle.brewfile).install || exit(1)
      end
    end
  end
end

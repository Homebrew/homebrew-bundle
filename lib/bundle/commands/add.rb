# frozen_string_literal: true

module Bundle
  module Commands
    module Add
      module_function

      def run(*args, global: false, file: nil)
        raise UsageError, "No arguments were specified!" if args.blank?

        type = :brew # default to brew
        name = args.first # only support one formula at a time for now
        options = {} # we don't currently support passing options

        # read the relevant Brewfile
        parsed_entries = Bundle::Dsl.new(Brewfile.read(global: global, file: file)).entries

        # check each of the entries in the specified Brewfile
        parsed_entries.each do |entry|
          # raise an error if the entry already exists in the Brewfile
          # this could also be a noop, or print a friendly message
          opoo "'#{name}' already exists in Brewfile."
          raise RuntimeError if entry.name == name
        end

        # need some help / pointers here
        # is it possible to use Bundle::Dsl to create an in memory representation
        # of the brewfile that we read, add an entry and then dump that back to the file?
      end
    end
  end
end

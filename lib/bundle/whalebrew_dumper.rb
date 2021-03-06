# frozen_string_literal: true

module Bundle
  module WhalebrewDumper
    module_function

    def reset!
      @images = nil
    end

    def images
      return [] unless Bundle.whalebrew_installed?

      @images ||= `whalebrew list 2>/dev/null`.split("\n")
                                              .reject { |image| image.start_with?("COMMAND ") }
                                              .map { |image| image.sub(/\w*\s+/, "") }
                                              .uniq
    end

    def dump
      images.map { |image| "whalebrew \"#{image}\"" }.join("\n")
    end
  end
end

# frozen_string_literal: true

module Bundle
  module CaskDumper
    module_function

    def reset!
      @casks = nil
      @cask_info = nil
    end

    def casks
      return [] unless Bundle.cask_installed?

      @casks ||= `brew list --cask 2>/dev/null`.split("\n")
      @casks.map { |cask| cask.chomp " (!)" }
            .uniq
    end

    def dump(casks_required_by_formulae, describe: false)
      [
        (casks & casks_required_by_formulae).map { |cask| cask_line(cask, describe) }.join("\n"),
        (casks - casks_required_by_formulae).map { |cask| cask_line(cask, describe) }.join("\n"),
      ]
    end

    def cask_line(cask, describe)
      desc = cask_info&.flat_map.find { |info| info["token"] == cask }&["desc"]
      comment = "# #{desc}\n" if describe && !desc.blank?
      "#{comment}cask \"#{cask}\""
    end

    def cask_info
      @cask_info ||= begin
        output = `brew cask info #{casks.join(" ")} --json=v1`
        JSON.parse(output)
      rescue JSON::ParserError => e
        opoo "Failed to parse `brew cask info --json`: #{e}"
        []
      end
    end

    def formula_dependencies
      cask_info.flat_map do |cask|
        cask.dig("depends_on", "formula")
      end.compact.uniq
    end
  end
end

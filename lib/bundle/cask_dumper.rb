# frozen_string_literal: true

module Bundle
  module CaskDumper
    module_function

    def reset!
      @casks = nil
    end

    def casks
      return [] unless Bundle.cask_installed?

      require "cask/caskroom"

      @casks ||= Cask::Caskroom.casks.map(&:full_name).sort(&tap_and_name_comparison)
      @casks.map { |cask| cask.chomp " (!)" }
            .uniq
    end

    def dump(casks_required_by_formulae)
      [
        (casks & casks_required_by_formulae).map { |cask| "cask \"#{cask}\"" }.join("\n"),
        (casks - casks_required_by_formulae).map { |cask| "cask \"#{cask}\"" }.join("\n"),
      ]
    end

    def formula_dependencies(cask_list)
      return [] if cask_list.blank?

      cask_info_command = "brew info --cask --json=v2 #{cask_list.join(" ")}"
      cask_info_response = `#{cask_info_command}`
      cask_info = JSON.parse(cask_info_response)

      cask_info["casks"].flat_map do |cask|
        cask.dig("depends_on", "formula")
      end.compact.uniq
    rescue JSON::ParserError => e
      opoo "Failed to parse `#{cask_info_command}`:\n#{e}"
      []
    end
  end
end

# frozen_string_literal: true

module Bundle
  module CaskDumper
    module_function

    def reset!
      @full_name_casks = nil
      @short_name_casks = nil
    end

    def casks(full_names_only: false)
      return [] unless Bundle.cask_installed?

      @full_name_casks ||= `brew cask list --full-name 2>/dev/null`.split("\n")
      @short_name_casks ||= `brew cask list 2>/dev/null`.split("\n")

      casks = @full_name_casks
      casks += @short_name_casks unless full_names_only

      casks.map { |cask| cask.chomp " (!)" }
            .uniq
    end

    def dump(casks_required_by_formulae)
      full_name_casks = casks(full_names_only: true)
      [
        (full_name_casks & casks_required_by_formulae).map { |cask| "cask \"#{cask}\"" }.join("\n"),
        (full_name_casks - casks_required_by_formulae).map { |cask| "cask \"#{cask}\"" }.join("\n"),
      ]
    end

    def formula_dependencies(cask_list)
      return [] unless cask_list.present?

      cask_info_response = `brew cask info #{cask_list.join(" ")} --json=v1`
      cask_info = JSON.parse(cask_info_response)

      cask_info.flat_map do |cask|
        cask.dig("depends_on", "formula")
      end.compact.uniq
    end
  end
end

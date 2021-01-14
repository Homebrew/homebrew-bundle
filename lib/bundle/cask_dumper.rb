# frozen_string_literal: true

module Bundle
  module CaskDumper
    module_function

    def reset!
      @casks = nil
      @cask_list = nil
      @cask_hash = nil
    end

    def casks
      return [] unless Bundle.cask_installed?

      require "cask/caskroom"
      @casks ||= Cask::Caskroom.casks
    end

    def cask_list
      @cask_list ||= casks.map(&:to_s)
    end

    def cask_hash
      return {} unless Bundle.cask_installed?

      @cask_hash ||= casks.index_by(&:to_s)
    end

    def dump(casks_required_by_formulae, describe: false)
      [
        (cask_list & casks_required_by_formulae).map do |cask_token|
          dump_cask(cask_hash[cask_token], describe)
        end.join("\n"),
        (cask_list - casks_required_by_formulae).map do |cask_token|
          dump_cask(cask_hash[cask_token], describe)
        end.join("\n"),
      ]
    end

    def dump_cask(cask, describe)
      description = if describe && cask.desc.present?
        "# #{cask.desc}\n"
      else
        ""
      end
      config = if cask.config.present? && cask.config.explicit.present?
        cask.config.explicit.map do |k, v|
          "#{k}: \"#{v.sub(/^#{ENV['HOME']}/, "~")}\""
        end.join(",").prepend(", args: { ").concat(" }")
      else
        ""
      end
      "#{description}cask \"#{cask}\"#{config}"
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

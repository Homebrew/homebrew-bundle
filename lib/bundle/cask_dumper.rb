# frozen_string_literal: true

module Bundle
  module CaskDumper
    module_function

    def reset!
      @casks = nil
      @cask_names = nil
      @cask_hash = nil
    end

    def cask_names
      @cask_names ||= casks.map(&:to_s)
    end

    def outdated_cask_names(greedy: false)
      return [] unless Bundle.cask_installed?

      casks.select { |c| c.outdated?(greedy: greedy) }
           .map(&:to_s)
    end

    def cask_versions
      return {} unless Bundle.cask_installed?

      casks.each_with_object({}) do |cask, name_versions|
        name_versions[cask.to_s] = cask.version
      end
    end

    def dump(casks_required_by_formulae, describe: false)
      [
        (cask_names & casks_required_by_formulae).map do |cask_token|
          dump_cask(cask_hash[cask_token], describe: describe)
        end.join("\n"),
        (cask_names - casks_required_by_formulae).map do |cask_token|
          dump_cask(cask_hash[cask_token], describe: describe)
        end.join("\n"),
      ]
    end

    def formula_dependencies(cask_list)
      return [] unless Bundle.cask_installed?
      return [] if cask_list.blank?

      casks.flat_map do |cask|
        next unless cask_list.include?(cask.to_s)

        cask.depends_on[:formula]
      end.compact
    end

    def casks
      return [] unless Bundle.cask_installed?

      require "cask/caskroom"
      @casks ||= Cask::Caskroom.casks
    end
    private_class_method :casks

    def cask_hash
      return {} unless Bundle.cask_installed?

      @cask_hash ||= casks.index_by(&:to_s)
    end
    private_class_method :cask_hash

    def dump_cask(cask, describe:)
      description = "# #{cask.desc}\n" if describe && cask.desc.present?
      config = if cask.config.present? && cask.config.explicit.present?
        # TODO: replace this logic with an actual call in Library/Homebrew/cask/
        cask.config.explicit.map do |key, value|
          if key.to_s == "languages"
            key = "language"
            value = value.join(",")
          end

          "#{key}: \"#{value.sub(/^#{ENV['HOME']}/, "~")}\""
        end.join(", ").prepend(", args: { ").concat(" }")
      end
      "#{description}cask \"#{cask}\"#{config}"
    end
    private_class_method :dump_cask
  end
end

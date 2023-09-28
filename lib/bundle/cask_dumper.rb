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

    def dump(describe: false)
      casks.map do |cask|
        description = "# #{cask.desc}\n" if describe && cask.desc.present?
        config = ", args: { #{cask.config.explicit_s} }" if cask.config.present? && cask.config.explicit.present?
        "#{description}cask \"#{cask}\"#{config}"
      end.join("\n")
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
  end
end

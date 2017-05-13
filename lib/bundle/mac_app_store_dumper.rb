require "json"

module Bundle
  module MacAppStoreDumper
    module_function

    def reset!
      @apps = nil
    end

    def apps
      @apps ||= if Bundle.mas_installed?
        `mas list 2>/dev/null`.split("\n").map do |app|
          id, name_with_version = app.split(" ", 2)
          name = name_with_version.gsub(/ \([\d\.]+\)$/, "")
          [id, name]
        end
      else
        []
      end
    end

    def app_ids
      apps.map { |id, _| id.to_i }
    end

    def dump
      apps.sort_by { |_, name| name.downcase }.map { |id, name| "mas \"#{name}\", id: #{id}" }.join("\n")
    end
  end
end

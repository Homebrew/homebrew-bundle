require "json"

module Bundle
  module MacAppStoreDumper
    module_function

    def reset!
      @apps = nil
    end

    def apps
      @apps ||= if Bundle.mas_installed?
        `mas list 2>/dev/null`.split("\n").map { |app| app.split(" ", 2) }
      else
        []
      end
    end

    def app_ids
      apps.map { |id, _| id.to_i }
    end

    def dump
      apps.map { |id, name| "mas '#{name}', id: #{id}" }.join("\n")
    end
  end
end

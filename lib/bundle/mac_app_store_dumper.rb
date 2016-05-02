require "json"

module Bundle
  class MacAppStoreDumper
    def self.reset!
      @apps = nil
    end

    def self.apps
      @apps ||= if Bundle.mas_installed?
        `mas list 2>/dev/null`.split("\n").map {|app| app.split(" ", 2)}
      else
        []
      end
    end

    def self.app_ids
      apps.map {|id,_| id.to_i }
    end

    def self.dump
      apps.map {|id, name| "mas '#{name}', id: #{id}"}.join("\n")
    end
  end
end

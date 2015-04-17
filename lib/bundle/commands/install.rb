module Bundle::Commands
  class Install
    def self.run
      Bundle::Dsl.new(Bundle.brewfile).install
    end
  end
end

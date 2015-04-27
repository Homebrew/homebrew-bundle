module Bundle::Commands
  class Install
    def self.run
      Bundle::Dsl.new(Bundle.brewfile).install || exit(1)
    end
  end
end

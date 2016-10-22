ENV.instance_eval do
  def deps
    @deps || []
  end

  def deps=(other)
    @deps = other
  end

  def keg_only_deps=(other)
    @keg_only_deps = other
  end

  def self.activate_extensions!; end
  def setup_build_environment; end
  def refurbish_args; end
  def prepend_path(*args); end
end

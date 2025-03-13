# frozen_string_literal: true

class PATH
  def initialize(*paths)
    @paths = parse(paths)
  end

  def prepend(*paths)
    @paths = parse(paths + @paths)
  end

  def reject(&block)
    self.class.new(@paths.reject(&block))
  end

  def to_s
    @paths.join(File::PATH_SEPARATOR)
  end

  private

  def parse(paths)
    paths.flatten
         .compact
         .flat_map { |p| Pathname(p).to_path.split(File::PATH_SEPARATOR) }
         .uniq
  end
end

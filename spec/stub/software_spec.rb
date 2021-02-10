# frozen_string_literal: true

class BottleSpecification
  def cellar
    :any
  end

  def collector
    {}
  end

  def rebuild
    0
  end

  def root_url
    "https://brew.sh"
  end
end

class Bottle
  class Filename
    def bintray
      "foo-1.0.big_sur.bottle.tar.gz"
    end

    def self.create(_formula, _tag, _rebuild)
      new
    end
  end
end

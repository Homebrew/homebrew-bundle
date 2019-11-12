# frozen_string_literal: true

module Tap
  module_function

  def fetch(*)
    OpenStruct.new(git_head: "9f30b86b0fd5845e47b19947f6a78ff4f9544fba")
  end

  def map
    []
  end
end

class CoreTap
  def self.instance
    Tap.fetch
  end
end

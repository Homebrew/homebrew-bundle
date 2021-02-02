# frozen_string_literal: true

class Tap
  def self.each
    []
  end

  def self.fetch(*)
    OpenStruct.new(git_head: "9f30b86b0fd5845e47b19947f6a78ff4f9544fba")
  end

  def name
    ""
  end

  def custom_remote?
    false
  end

  def remote
    ""
  end
end

class CoreTap
  def self.instance
    Tap.fetch
  end
end

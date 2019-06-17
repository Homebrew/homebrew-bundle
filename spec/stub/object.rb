# frozen_string_literal: true

# monkeypatch Object so it behaves as if ActiveSupport were present
class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  def present?
    !blank?
  end
end


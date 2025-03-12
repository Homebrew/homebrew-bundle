# frozen_string_literal: true

module Kernel
  def with_env(_hash)
    yield if block_given?
  end

  def redirect_stdout(_file)
    yield if block_given?
  end
end

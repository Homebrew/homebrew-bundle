# frozen_string_literal: true

module Formatter
  module_function

  def columns(*); end

  def success(*args)
    args
  end

  def error(*args)
    args
  end
end

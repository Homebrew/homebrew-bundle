#!/usr/bin/env ruby

BREWDLER_ROOT = File.expand_path "#{File.dirname(__FILE__)}/.."
ENV["RUBYLIB"] = "#{BREWDLER_ROOT}/lib:#{ENV["RUBYLIB"]}"
exec "#{BREWDLER_ROOT}/bin/brewdle"

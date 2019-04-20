#!/usr/bin/env rake
# frozen_string_literal: true

require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new("spec")

desc "Run Rubocop locally"
RuboCop::RakeTask.new(:rubocop) do |task|
  task.formatters = ["simple"]
  task.fail_on_error = false
end

task :default => :spec

task :pr => [:rubocop, :spec]

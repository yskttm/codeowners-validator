# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:test)

task :lint do
  sh "bundle exec standardrb"
end

task default: [:test, :lint]

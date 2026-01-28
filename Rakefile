# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

desc "Validate RBS type signatures"
task :rbs do
  sh "bundle exec rbs -I sig validate"
end

require "steep/rake_task"

Steep::RakeTask.new

task default: %i[test rubocop rbs steep]

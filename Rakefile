require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'bump/tasks'

# Pushing to rubygems is handled by a github workflow
ENV['gem_push'] = 'false'

Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/test*.rb'
  test.verbose = true
end

task default: "test"

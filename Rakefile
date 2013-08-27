require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs << 'test'
  #SO MUCH NOISE
  #test.warning = true
  test.pattern = 'spec/**/*_spec.rb'
end

task :default => :test
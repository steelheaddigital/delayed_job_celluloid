require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new(:test_launcher) do |test|
  test.libs << 'test'
  #SO MUCH NOISE
  #test.warning = true
  test.pattern = 'spec/launcher_spec.rb'
end

Rake::TestTask.new(:test_manager) do |test|
  test.libs << 'test'
  #SO MUCH NOISE
  #test.warning = true
  test.pattern = 'spec/manager_spec.rb'
end

Rake::TestTask.new(:test_worker) do |test|
  test.libs << 'test'
  #SO MUCH NOISE
  #test.warning = true
  test.pattern = 'spec/worker_spec.rb'
end

Rake::TestTask.new(:test_command) do |test|
  test.libs << 'test'
  #SO MUCH NOISE
  #test.warning = true
  test.pattern = 'spec/command_spec.rb'
end

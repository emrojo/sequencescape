# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Sequencescape::Application.load_tasks

begin
  require 'delayed/tasks'
rescue LoadError
  STDERR.puts "Run `rake gems:install` to install delayed_job"
end

begin
  require 'parallel_tests/tasks'
#   Setup:
#     rake parallel:create
#     rake parallel:prepare
#   Run:
#     rake parallel:test          # Test::Unit
#     rake parallel:spec          # RSpec
#     rake parallel:features      # Cucumber
rescue LoadError
  # just ignore it (because we have excluded the "test" gembundle group)
end


task :test => ["test:units", "test:functionals"]

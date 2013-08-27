require 'delayed_job_celluloid'
require 'delayed_job'
require 'delayed_job_active_record'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'rails'
require 'active_record'

# Connect to sqlite
ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3",
  "database" => ":memory:"
)
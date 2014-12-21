require 'delayed_job_celluloid'
require 'delayed_job'
require 'delayed_job_active_record'
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'active_record'
require 'sqlite3'
require 'logger'
require 'celluloid/autostart'
require 'rails'

ROOT = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT
$LOAD_PATH << File.join(ROOT, 'lib')

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/db.log")
ActiveRecord::Base.establish_connection(config['test'])
DelayedJobCelluloid::Worker.logger = Logger.new(File.dirname(__FILE__) + "/dj.log")

ActiveRecord::Base.connection.create_table :delayed_jobs, :force => true do |table|
  table.integer :priority, :default => 0 # Allows some jobs to jump to the front of the queue
  table.integer :attempts, :default => 0 # Provides for retries, but still fail eventually.
  table.text :handler # YAML-encoded string of the object that will do work
  table.string :last_error # reason for last failure (See Note below)
  table.datetime :run_at # When to run. Could be Time.now for immediately, or sometime in the future.
  table.datetime :locked_at # Set when a client is working on this object
  table.datetime :failed_at # Set when all retries have failed (actually, by default, the record is deleted instead)
  table.string :locked_by # Who is working on this object (if locked)
  table.string :queue
  table.timestamps
end
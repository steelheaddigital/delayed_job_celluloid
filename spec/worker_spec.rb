require_relative 'spec_helper'

Delayed::Worker.backend = :active_record

describe "Worker" do

  before :all do
    build_delayed_jobs
  end

  it "worker runs jobs" do
    manager = Minitest::Mock.new
    async = Minitest::Mock.new
    100.times {async.expect(:work, nil, [Celluloid::ActorProxy])}
    100.times {async.expect(:worker_done, nil, [Celluloid::ActorProxy])}
    100.times {manager.expect(:async, async, [])}
    
    worker = DelayedJobCelluloid::Worker.new({},manager)
    
    test = Test.new
    test.delay.test_this
    test.delay.test_this
    assert_equal 2, Delayed::Job.count
    
    worker.work_off
    
    assert_equal 0, Delayed::Job.count
    manager.verify
    async.verify
  end

  def build_delayed_jobs
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
  end
end

class Test

  def test_this
    say "Test"
  end

end
require_relative 'spec_helper'
require_relative 'test_job'

DelayedJobCelluloid::Worker.backend = :active_record

class WorkerSpec < Minitest::Unit::TestCase
    
  describe "Worker" do

    before :all do
      DelayedJobCelluloid::Worker.exit_on_complete = true
    end

    it "runs jobs" do
      
      manager = Minitest::Mock.new
      async = Minitest::Mock.new
      100.times {async.expect(:work, nil, [Celluloid::ActorProxy])}
      100.times {async.expect(:worker_done, nil, [Celluloid::ActorProxy])}
      100.times {manager.expect(:async, async, [])}
    
      worker = DelayedJobCelluloid::Worker.new({},manager)
      test = TestJob.new
      test.delay.test_this
      
      assert_equal 1, Delayed::Job.count
      
      worker.start

      assert_equal 0, Delayed::Job.count
      manager.verify
      async.verify
    end
    
  end
end
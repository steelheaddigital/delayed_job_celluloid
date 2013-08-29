require_relative 'spec_helper'

class ManagerSpec < Minitest::Unit::TestCase
  describe 'manager' do
  
    it "creates N worker instances" do
      mgr = DelayedJobCelluloid::Manager.new({}, 3)
      assert_equal mgr.ready.size, 3
    end
  
    it 'starts specified number of workers upon start' do
      worker = Minitest::Mock.new
      start = Minitest::Mock.new
      3.times {start.expect(:start, nil, [])}
      3.times {worker.expect(:async, start, [])}
    
      mgr = DelayedJobCelluloid::Manager.new({}, 0)
    
      i = 0
      while i < 3 do
        worker.expect(:name=, nil, ["delayed_job.#{i}"])
        mgr.ready << worker
        i += 1
      end
  
      mgr.start
    
      assert_equal mgr.ready.size, 3
      worker.verify
      start.verify
    end
  
    it 'stops workers on stop' do
      worker = Minitest::Mock.new
      3.times {worker.expect(:stop, nil, [])}
      3.times {worker.expect(:terminate, nil, [])}
      3.times {worker.expect(:alive?, true, [])}
    
      mgr = DelayedJobCelluloid::Manager.new({}, 0)
    
      i = 0
      while i < 3 do
        mgr.ready << worker
        i += 1
      end
  
      mgr.stop
    
      assert_equal mgr.ready.size, 0
      worker.verify
    end
  
  end
end

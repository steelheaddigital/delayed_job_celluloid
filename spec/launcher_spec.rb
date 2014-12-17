require_relative 'spec_helper'
require_relative 'test_job'

class LauncherSpec < Minitest::Test
  describe 'launcher' do
    
    it "starts working jobs" do    
      DelayedJobCelluloid::Worker.exit_on_complete = true
        
      i=0
      while i < 10 do
        test = TestJob.new
        test.delay.test_this
        i += 1
      end
      
      launcher = DelayedJobCelluloid::Launcher.new({}, 2)
      launcher.run
    end
    
  end
end

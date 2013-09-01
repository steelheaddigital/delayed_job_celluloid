require_relative 'spec_helper'
require_relative 'test_job'

class CommandSpec < Minitest::Unit::TestCase
  describe 'command' do
    
    it "starts workers" do  
      i = 0  
      while i < 10 do
        test = TestJob.new
        test.delay.test_this
        i += 1
      end
      DelayedJobCelluloid::Command.new(ARGV << '-n 2').run
    end
    
  end
end
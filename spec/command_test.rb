require_relative 'spec_helper'

class CommandSpec < Minitest::Unit::TestCase
  describe 'command' do
    
    it "starts workers" do    
      DelayedJobCelluloid::Command.new(ARGV << '-n 20').run
    end
    
  end
end
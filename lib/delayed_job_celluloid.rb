require 'delayed_job_celluloid/command'
require 'delayed_job_celluloid/launcher'
require 'delayed_job_celluloid/manager'
require 'delayed_job_celluloid/worker'
require 'delayed_job_celluloid/logger'

module DelayedJobCelluloid
  
  def self.logger
    DelayedJobCelluloid::Logger.new
  end
  
end

require 'rails/generators'
require 'delayed/compatibility'

class DelayedJobCelluloidGenerator < Rails::Generators::Base

  self.source_paths << File.join(File.dirname(__FILE__), 'templates')

  def create_executable_file
    template "script", "#{Delayed::Compatibility.executable_prefix}/delayed_job_celluloid"
    chmod "#{Delayed::Compatibility.executable_prefix}/delayed_job_celluloid", 0755
  end
end
require 'rails/generators'

class DelayedJobCelluloidGenerator < Rails::Generators::Base

  self.source_paths << File.join(File.dirname(__FILE__), 'templates')

  def create_executable_file
    template "script", "script/delayed_job_celluloid"
    chmod "script/delayed_job_celluloid", 0755
  end
end
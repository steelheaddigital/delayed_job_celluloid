require 'logger'

module DelayedJobCelluloid
  class Logger < Logger
    def initialize(logdev = STDOUT)
      super logdev
    end
  end
end
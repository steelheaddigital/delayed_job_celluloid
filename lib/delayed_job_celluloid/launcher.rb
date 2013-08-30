require_relative 'manager'

module DelayedJobCelluloid
  class Launcher
    attr_reader :manager, :options
    def initialize(options, worker_count)
      @options = options
      @manager = Manager.new(options, worker_count)
    end

    def run
      manager.async.start
    end

    def stop
      manager.async.stop
      manager.wait(:shutdown)
    end
  end
end
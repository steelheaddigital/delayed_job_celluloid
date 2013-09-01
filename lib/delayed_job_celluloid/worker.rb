require 'delayed_job'
require 'delayed/performable_mailer'

module DelayedJobCelluloid
  class Worker < Delayed::Worker
    include Celluloid

    attr_accessor :proxy_id

    def initialize(options={}, manager)
      @manager = manager
      super(options)
    end

    def name
      return @name unless @name.nil?
    end

    # Sets the name of the worker.
    def name=(val)
      @name = val
    end
    
    def start
      begin
        say "Starting job worker"
        @manager.async.real_thread(proxy_id, Thread.current)
        self.class.lifecycle.run_callbacks(:execute, self) do
          loop do
              self.class.lifecycle.run_callbacks(:loop, self) do
                @realtime = Benchmark.realtime do
                  @result = work_off
                end
              end

              count = @result.sum

              if count.zero?
                if self.class.exit_on_complete
                  say "No more jobs available. Exiting"
                  break
                else
                  sleep(self.class.sleep_delay) unless stop?
                end
              else
                say "#{count} jobs processed at %.4f j/s, %d failed" % [count / @realtime, @result.last]
              end

              break if stop?
          end
        end
        rescue DelayedJobCelluloid::Shutdown
      end
    end
    
    def stop
      say "Exiting..."
      @exit = true
    end
    
    def work_off(num = 100)
      success, failure = 0, 0
      
      @manager.async.work(current_actor)
      num.times do
        case reserve_and_run_one_job
        when true
          success += 1
        when false
          failure += 1
        else
          @manager.async.worker_done(current_actor)
          break # leave if no work could be done
        end
        if stop?
          @manager.async.worker_done(current_actor)
          break #leave if we're exiting
        end
      end

      return [success, failure]
    end
    
  end
end
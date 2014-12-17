require_relative 'worker'

module DelayedJobCelluloid
  class Manager
    include Celluloid
    include Logger
    
    trap_exit :worker_died
    
    attr_reader :ready
    attr_reader :busy
    
    def initialize(options={}, worker_count)
      @options = options
      @worker_count = worker_count || 1
      @done_callback = nil

      @in_progress = {}
      @threads = {}
      @done = false
      @busy = []
      @ready = @worker_count.times.map do
        w = Worker.new_link(options, current_actor)
        w.proxy_id = w.object_id
        w
      end
    end
    
    def start
      @ready.each_with_index do |worker, index|
        worker.name = "delayed_job.#{index}"
        worker.async.start 
      end
    end

    def stop(timeout)   
      @done = true
            
      info "Shutting down #{@ready.size} idle workers"
      @ready.each do |worker|
        worker.terminate if worker.alive?
      end
      @ready.clear
      
      return after(0) { signal(:shutdown) } if @busy.empty?
      hard_shutdown_in timeout
    end
    
    def work(worker)
      @ready.delete(worker)
      @busy << worker
    end
    
    def worker_done(worker)
      @busy.delete(worker)
      if stopped?
        worker.terminate if worker.alive?
        signal(:shutdown) if @busy.empty?
      else
        @ready << worker if worker.alive?
      end
    end
    
    def worker_died(worker, reason)
      debug "#{worker.inspect} died because of #{reason}" unless reason.nil?
      @busy.delete(worker)
      unless stopped?
        worker = Worker.new_link(@options, current_actor)
        worker.name = "restarted"
        @ready << worker
        worker.async.start
      else
        signal(:shutdown) if @busy.empty?
      end
    end

    def stopped?
      @done
    end
    
    def real_thread(proxy_id, thr)
      @threads[proxy_id] = thr
    end
    
    def hard_shutdown_in(delay)
      info "Pausing up to #{delay} seconds to allow workers to finish..." 

      after(delay) do
        # We've reached the timeout and we still have busy workers.
        # They must die but their messages shall live on.
        info "Still waiting for #{@busy.size} busy workers"

        debug "Terminating #{@busy.size} busy worker threads"
        @busy.each do |worker|
          if worker.alive? && t = @threads.delete(worker.object_id)
            t.raise Shutdown
          end
        end

        after(0) { signal(:shutdown) }
      end
    end
    
  end
end

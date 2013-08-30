#
#Copyright 2013 Neighbor Market
#
#This file is part of Neighbor Market.
#
#Neighbor Market is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Neighbor Market is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Neighbor Market.  If not, see <http://www.gnu.org/licenses/>.
#

require 'celluloid'
require_relative 'worker'

module DelayedJobCelluloid
  class Manager
    include Celluloid
    
    trap_exit :worker_died
    
    attr_reader :ready
    attr_reader :busy
    
    def initialize(options={}, worker_count)
      @options = options
      @worker_count = worker_count || 1
      @done_callback = nil

      @done = false
      @busy = []
      @ready = @worker_count.times.map do  
        Worker.new_link(options, current_actor)
      end
    end
    
    def start
      DelayedJobCelluloid.logger.info { "Starting #{@ready.size} worker threads" }
      @ready.each_with_index do |worker, index|
        worker.name = @worker_count == 1 ? "delayed_job" : "delayed_job.#{index}"
        worker.async.start 
      end
    end

    def stop      
      @done = true
      @ready.each do |worker|
        worker.stop
        worker.terminate if worker.alive?
      end
      @ready.clear
      
      return after(0) { signal(:shutdown) } if @busy.empty?
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
      DelayedJobCelluloid.logger.info { "worker #{worker.name} died for reason: #{reason}" }
      @busy.delete(worker)
      
      unless stopped?
        worker = Worker.new_link(@options, current_actor)
        @ready << worker
        worker.async.start
      else
        signal(:shutdown) if @busy.empty?
      end
    end

    def stopped?
      @done
    end
    
  end
end

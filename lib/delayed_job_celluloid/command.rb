$stdout.sync = true

require 'optparse'
require 'celluloid/autostart'

module DelayedJobCelluloid
  
  class Shutdown < Interrupt; end
  
  class Command
    
    attr_accessor :worker_count

    def initialize(args)
      parse_options(args)
    end
  
    def run
      self_read, self_write = IO.pipe
      
      %w(INT TERM).each do |sig|
        trap sig do
          self_write.puts(sig)
        end
      end
      
      require 'delayed_job_celluloid/launcher'
      @launcher = Launcher.new(@options, @worker_count)
      
      begin
        @launcher.run
        
        while readable_io = IO.select([self_read])
          signal = readable_io.first[0].gets.strip
          handle_signal(signal)
        end
      rescue Interrupt
        @launcher.stop
        exit(0)
      end
    end
    
    def handle_signal(signal)
      case signal
      when 'INT','TERM'
        raise Interrupt
      end
        
    end
    
    def parse_options(args)
      @options = {
        :quiet => true,
        :timeout => 8
      }

      @worker_count = 2

      opts = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} [options] start|stop|restart|run"

        opts.on('-h', '--help', 'Show this message') do
          puts opts
          exit 1
        end
        opts.on('-e', '--environment=NAME', 'Specifies the environment to run this delayed jobs under (test/development/production).') do |e|
          STDERR.puts "The -e/--environment option has been deprecated and has no effect. Use RAILS_ENV and see http://github.com/collectiveidea/delayed_job/issues/#issue/7"
        end
        opts.on('--min-priority N', 'Minimum priority of jobs to run.') do |n|
          @options[:min_priority] = n
        end
        opts.on('--max-priority N', 'Maximum priority of jobs to run.') do |n|
          @options[:max_priority] = n
        end
        opts.on('-n', '--number_of_workers=workers', "Number of worker threads to start") do |worker_count|
          @worker_count = worker_count.to_i rescue 1
        end
        opts.on('--sleep-delay N', "Amount of time to sleep when no jobs are found") do |n|
          @options[:sleep_delay] = n.to_i
        end
        opts.on('--read-ahead N', "Number of jobs from the queue to consider") do |n|
          @options[:read_ahead] = n
        end
        opts.on('-p', '--prefix NAME', "String to be prefixed to worker process names") do |prefix|
          @options[:prefix] = prefix
        end
        opts.on('--queues=queues', "Specify which queue DJ must look up for jobs") do |queues|
          @options[:queues] = queues.split(',')
        end
        opts.on('--queue=queue', "Specify which queue DJ must look up for jobs") do |queue|
          @options[:queues] = queue.split(',')
        end
        opts.on('--exit-on-complete', "Exit when no more jobs are available to run. This will exit if all jobs are scheduled to run in the future.") do
          @options[:exit_on_complete] = true
        end
        opts.on('-t', '--timeout NUM', "Shutdown timeout") do |prefix|
          @options[:timeout] = Integer(arg)
        end
      end
      @args = opts.parse!(args)
    end
    
  end
end
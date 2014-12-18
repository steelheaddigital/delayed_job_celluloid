# DelayedJobCelluloid

Based on awesome gems like Sidekiq and Suckerpunch, DelayedJobCelluloid allows delayed job workers to be run in multiple threads within a single process using the Celluloid actor pattern.  The delayed_job workers by default start a new single-threaded process for each worker.  By running workers in a single multi-threaded process instead, delayed_job_celluloid is more efficient in terms of memory use and speed.

## Installation

Add delayed_job_celluloid to your gem file

	gem 'delayed_job_celluloid'

Run bundle install

	bundle install delayed_job_celluloid

To add the startup script to your script directory, run the generator

	rails generate delayed_job_celluloid 	

## Usage

First, make sure you have your preferred delayed job backend installed, for instance delayed_job_activerecord, or delayed_job_mongoid.  See [delayed_job](https://github.com/collectiveidea/delayed_job) for more information.

To start working off of your delayed_job queues simply run the below from your application's root directory

	bundle exec script/delayed_job_celluloid

To specify the number of worker threads to start, pass the -n parameter to the startup script.  For example, the below command would start 5 worker threads.  The default is 2.

	bundle exec script/delayed_job_celluloid -n 5
	
One important thing to bear in mind with this is that you should have a database connection pool size that is at least equal to the number of worker threads you are running due to the fact that each thread will need its own connection.  if there are not enough connections available you will get database errors.  You can set this in the database.yml file in your app.

	development:
  		adapter: postgresql
  	  	database: dev
  	  	host: localhost
  	  	pool: 5

Currently the gem does not support daemonization of the main process because I haven't needed it as I am using it in conjuction with Unicorn on Heroku.  If you are running your app on Heroku, this gem will allow you to run multiple workers in a single Unicorn process.  An example unicorn config is as follows:

	# config/unicorn.rb
	worker_processes Integer(ENV["WEB_CONCURRENCY"] || 2)
	timeout 15
	preload_app true

	before_fork do |server, worker|
  
	  #Start the Delayed Job worker inside of a Unicorn process
	  @delayed_job_celluloid_pid ||= spawn("bundle exec script/delayed_job_celluloid -n 5")
  
	  Signal.trap 'TERM' do
	    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
	    Process.kill 'QUIT', Process.pid
	  end

	  defined?(ActiveRecord::Base) and
	    ActiveRecord::Base.connection.disconnect!
	end 

	after_fork do |server, worker|
  
	  Signal.trap 'TERM' do
	    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
	  end

	  defined?(ActiveRecord::Base) and
	    ActiveRecord::Base.establish_connection
	end

## Daemonization

    script/delayed_job_celluloid --daemonize --log /path/to/my/logfile.log start
    script/delayed_job_celluloid --daemonize --log /path/to/my/logfile.log stop

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

class WorkController < ApplicationController
  def index
    @count = rand(100)
    puts "Adding #{@count} jobs"
    @count.times do |x|
      Delayed::Job.enqueue HardWorker.new('bubba', 0.01, x)
    end
  end

  def email
    UserMailer.delay(run_at: 30.seconds.from_now).greetings(Time.now)
    render :text => 'enqueued'
  end
  
  def crash
    Delayed::Job.enqueue HardWorker.new('crash', 1, Time.now.to_f)
    render :text => 'enqueued'
  end
  
end

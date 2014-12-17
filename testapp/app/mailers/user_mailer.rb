class UserMailer < ActionMailer::Base
  default from: "testapp@example.com"

  def greetings(now)
    @now = now
    @hostname = `hostname`.strip
    mail(:to => 'tmooney3979@gmail.com', :subject => 'Ahoy Matey!')
  end
end

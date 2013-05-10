class Notification < ActionMailer::Base
  
  def send_queued(email)
      @email = email
      mail(
           :from => email.from,
           :reply_to => email.from,
           :to => email.to,
           :bcc => email.bcc,
           :subject => email.subject
          )
  end
end

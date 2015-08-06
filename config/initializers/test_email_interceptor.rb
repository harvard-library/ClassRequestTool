if defined?(MAIL_RECIPIENT_OVERRIDE)
  class TestEmailInterceptor
    def self.delivering_email(message)
      if message.to.kind_of?(Array)
        recipients = message.to.join(', ')
      else
        recipients = message.to
      end
      message.to = MAIL_RECIPIENT_OVERRIDE
      message.subject= "CRT TEST | #{message.subject} | Recipients: #{recipients}"
    end
  end

  ActionMailer::Base.register_interceptor(TestEmailInterceptor)
end
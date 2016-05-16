if defined?(MAIL_RECIPIENT_OVERRIDE) && !MAIL_RECIPIENT_OVERRIDE.blank?
  class TestEmailInterceptor
    def self.delivering_email(message)
      unless Rails.env.production? || Rails.env.test? || Customization.current.notifications_on?
        if message.to.kind_of?(Array)
          recipients = message.to.join(', ')
        else
          recipients = message.to
        end
        message.to = MAIL_RECIPIENT_OVERRIDE
        message.subject= "CRT TEST | #{message.subject} | Recipients: #{recipients}"
      end
    end
  end
  ActionMailer::Base.register_interceptor(TestEmailInterceptor)
end


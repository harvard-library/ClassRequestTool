class TestEmailInterceptor
  def self.delivering_email(message)
    unless Rails.env == :production || Rails.env == :test
      if message.to.kind_of?(Array)
        recipients = message.to.join(', ')
      else
        recipients = message.to
      end
      message.to = $test_email
      message.subject= "CRT TEST | #{message.subject} | Recipients: #{recipients}"
    end
  end
end


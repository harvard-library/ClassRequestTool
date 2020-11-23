class Email < ApplicationRecord

  validates_presence_of :to, :from, :reply_to, :subject, :body

  def self.to_send
    where(:message_sent => false).limit(EMAIL_BATCH_LIMIT)
  end
end

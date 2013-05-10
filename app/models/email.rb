class Email < ActiveRecord::Base
  attr_accessible :to, :bcc, :from, :reply_to, :subject, :body, :date_sent, :message_sent
  
  validates_presence_of :to, :from, :reply_to, :subject, :body
  
  def self.to_send
    self.find(:all, :conditions => {:message_sent => false}, :limit => EMAIL_BATCH_LIMIT)
  end
end

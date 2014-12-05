require 'test_helper'
require 'pp'

class NotificationTest < ActionMailer::TestCase
  
#  include FactoryGirl::Syntax::Methods

  def setup
    ActionMailer::Base.delivery_method    = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries         = []
  end
  
  context 'attached_repo' do
    context 'assessment' do
      setup do
        @course = courses(:attached_course)
        Notification.assessment(@course).deliver
        @recipient = [@course.primary_contact.email]
      end
    
      teardown do
        ActionMailer::Base.deliveries.clear
      end
  
      # Number of emails
      should 'send one email' do
        assert_equal(1, ActionMailer::Base.deliveries.count, "Sends the wrong number of emails")
      end
  
      # Sender email
      should 'use the default sender email' do
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.first.from, "The sender email is wrong")
      end
  
      # Destination email
      should 'send to the correct recipient' do
        assert_equal(@recipient, ActionMailer::Base.deliveries.first.to, "The requestor email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] Please Assess your Recent Class at #{@course.repo_name}", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end

    context 'cancellation' do
      setup do
        @course = courses(:attached_course)
        Notification.cancellation(@course).deliver
        @recipients = [@course.primary_contact.email]
        @recipients << @course.users.map {|e| e.email }
        @recipients.uniq.sort
      end
    
      teardown do
        ActionMailer::Base.deliveries.clear
      end
  
      # Number of emails
      should 'send one email' do
        assert_equal(1, ActionMailer::Base.deliveries.count, "Sends the wrong number of emails")
      end
  
      # Sender email
      should 'use the default sender email' do
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.first.from, "The sender email is wrong")
      end
  
      # Destination email
      should 'send to the correct recipients' do
        assert_equal(@recipients, ActionMailer::Base.deliveries.first.to, "The requestor email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] Class cancellation confirmation", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end

    context 'new request to requestor' do
      setup do
        @course = courses(:attached_course)
        Notification.new_request_to_requestor(@course).deliver
      end
    
      teardown do
        ActionMailer::Base.deliveries.clear
      end
  
      # Number of emails
      should 'send one email' do
        assert_equal(1, ActionMailer::Base.deliveries.count, "Sends the wrong number of emails")
      end
  
      # Sender email
      should 'use the default sender email' do
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.first.from, "The sender email is wrong")
      end
  
      # Destination email
      should 'send to the correct recipient' do
        assert_equal([@course.contact_email], ActionMailer::Base.deliveries.first.to, "The requestor email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] Class Request Successfully Submitted for Attached Course", ActionMailer::Base.deliveries.first.subject, "The subject is incorrect")
      end
    
    end
    
    context 'new request to admin' do
      setup do
        @course = courses(:attached_course)
        Notification.new_request_to_admin(@course).deliver
        @recipients = (@course.repository.users.pluck(:email) + User.where(superadmin: true).pluck(:email)).uniq.sort
      end
    
      teardown do
        ActionMailer::Base.deliveries.clear
      end
  
      # Number of emails
      should 'send one email' do
        assert_equal(1, ActionMailer::Base.deliveries.count, "Sends the wrong number of emails")
      end
  
      # Sender email
      should 'use the default sender email' do
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.first.from, "The sender email is wrong")
      end
  
      # Destination email
      should 'send to the correct recipients' do
        assert_equal(@recipients, ActionMailer::Base.deliveries.first.to, "The requestor email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] A New Class Request has been Received", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end

    context 'repository change' do
      setup do
        @course = courses(:attached_course)
        Notification.repo_change(@course).deliver
        @recipients = @course.users.map {|e| e.email }
        @recipients << users(:superadmin).email
        @recipients.uniq.sort
      end
    
      teardown do
        ActionMailer::Base.deliveries.clear
      end
  
      # Number of emails
      should 'send one email' do
        assert_equal(1, ActionMailer::Base.deliveries.count, "Sends the wrong number of emails")
      end
  
      # Sender email
      should 'use the default sender email' do
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.first.from, "The sender email is wrong")
      end
  
      # Destination email
      should 'send to the correct recipients' do
        assert_equal(@recipients, ActionMailer::Base.deliveries.first.to.uniq.sort, "The requestor email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] A Class has been Transferred to #{@course.repo_name}", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end
 
    context 'staff change' do
      setup do
        @course = courses(:attached_course)
        Notification.staff_change(@course, nil).deliver
        @recipients = @course.users.map {|e| e.email }
        @recipients << @course.primary_contact.email
        @recipients.uniq.sort
      end
    
      teardown do
        ActionMailer::Base.deliveries.clear
      end
  
      # Number of emails
      should 'send one email' do
        assert_equal(1, ActionMailer::Base.deliveries.count, "Sends the wrong number of emails")
      end
  
      # Sender email
      should 'use the default sender email' do
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.first.from, "The sender email is wrong")
      end
  
      # Destination email
      should 'send to the correct recipients' do
        assert_equal(@recipients, ActionMailer::Base.deliveries.first.to.uniq.sort, "The requestor email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] You have been assigned a class", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end
    
    context 'timeframe change' do
      setup do
        @course = courses(:attached_course)
        Notification.timeframe_change(@course).deliver
        @recipient = [@course.contact_email]
      end
    
      teardown do
        ActionMailer::Base.deliveries.clear
      end
  
      # Number of emails
      should 'send one email' do
        assert_equal(1, ActionMailer::Base.deliveries.count, "Sends the wrong number of emails")
      end
  
      # Sender email
      should 'use the default sender email' do
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.first.from, "The sender email is wrong")
      end
  
      # Destination email
      should 'send to the correct recipients' do
        assert_equal(@recipient, ActionMailer::Base.deliveries.first.to.uniq.sort, "The requestor email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] You have been assigned a class", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end
end
end


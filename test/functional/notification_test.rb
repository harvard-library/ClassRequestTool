require 'test_helper'
require 'pp'

class NotificationTest < ActionMailer::TestCase
  
  include FactoryGirl::Syntax::Methods

  def setup
    ActionMailer::Base.delivery_method    = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries         = []
    @staff = create(:user, :staff)
    @admin = create(:user, :admin)
    @superadmin = create(:user, :superadmin)
    @patron = create(:user, :patron)
  end
  
  context 'new request' do
    setup do
      @course = create(:course, :uu)
      Notification.new_request(@course).deliver
    end
    
    teardown do
      ActionMailer::Base.deliveries.clear
    end
  
    # Number of emails
    should 'send two emails' do
      assert_equal(2, ActionMailer::Base.deliveries.count, "Sends the wrong number of emails")
    end
  
    # Sender email
    should 'render the sender email' do
      assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.first.from, "The sender email is wrong")
    end
  
  
    # Destination email
    should 'use the requestor email' do
      assert_equal(@course.contact_email, ActionMailer::Base.deliveries.first.to, "The requestor email is incorrect")
    end
    
    should 'use the admin emails' do
      assert_equal( @admin_list.pluck(:email).join(', '), ActionMailer::Base.deliveries.last.to, "The admin emails are incorrect")
    end
  
    # Subject
    should 'set the requestor subject correctly' do
      assert_equal("[ClassRequestTool] Class Request Successfully Submitted for Test Course Title", ActionMailer::Base.deliveries.first.subject, "The requestor subject is incorrect")
    end
    
    should 'set the admin subject correctly' do
      assert_equal("[ClassRequestTool] A New Class Request has been Received", ActionMailer::Base.deliveries.last.subject.should, "The admins subject is incorrect")
    end
  end
  
end

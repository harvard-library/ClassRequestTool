require 'test_helper'

class NotificationTest < ActionMailer::TestCase
  
  include FactoryGirl::Syntax::Methods

  def setup
    ActionMailer::Base.delivery_method    = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries         = []
    @admin      = create(:user, :admin)
    @staff      = create(:user, :staff)
    @patron     = create(:user, :patron)
    @superadmin      = create(:user, :superadmin)
  end
  
  teardown do
    ActionMailer::Base.deliveries.clear
  end

  context 'course attached to repo' do
    setup do
      @course = create(:course)
      @course.repository.users = create_list(:user, 3, :staff)
    end
    
    context 'assessment_requested' do
      setup do
        Notification.assessment_requested(@course).deliver
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
        assert_equal([@course.contact_email], ActionMailer::Base.deliveries.first.to, "The recipient email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] Please Assess your Recent Class at #{@course.repo_name}", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end

    context 'cancellation' do
      setup do
        Notification.cancellation(@course).deliver
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
        recipients = [@course.primary_contact.email]
        recipients += @course.users.map {|e| e.email }
        recipients
        assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.first.to.uniq.sort, "The recipient email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] Class cancellation confirmation", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end

    context 'uncancellation' do
      setup do
        Notification.uncancellation(@course).deliver
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
        recipients = [@course.primary_contact.email]
        recipients += @course.users.map {|e| e.email }
        recipients
        assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.first.to.uniq.sort, "The recipient email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] Class uncancellation confirmation", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end
    
    context 'new_request_to_requestor' do
      setup do
        Notification.new_request_to_requestor(@course).deliver
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
        assert_equal([@course.contact_email], ActionMailer::Base.deliveries.first.to, "The recipient email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] Class Request Successfully Submitted for Test Course Title", ActionMailer::Base.deliveries.first.subject, "The subject is incorrect")
      end
    
    end
    
    context 'new_request_to_admin' do
      setup do
        Notification.new_request_to_admin(@course).deliver
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
        recipients = @course.repository.users.map{ |u| u.email }
        recipients += User.where(superadmin: true).pluck(:email)
        assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.first.to.uniq.sort, "The recipient email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] A New Class Request has been Received", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end

    context 'repo_change' do
      setup do
        Notification.repo_change(@course).deliver
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
        recipients = @course.repository.users.map {|e| e.email }
        recipients += User.where(superadmin: true).pluck(:email)
        recipients
        assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.first.to.uniq.sort, "The recipient email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] A Class has been Transferred to #{@course.repo_name}", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end
 
    context 'staff_change' do
      setup do
        Notification.staff_change(@course, @admin).deliver
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
        recipients = @course.users.map {|u| u.email }
        recipients << @course.primary_contact.email
        recipients
        assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.first.to.uniq.sort, "The recipient email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] You have been assigned a class", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end
    
    context 'timeframe_change' do
      setup do
        Notification.timeframe_change(@course).deliver
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
        recipient = [@course.contact_email]
        assert_equal(recipient, ActionMailer::Base.deliveries.first.to.uniq.sort, "The recipient email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] You have been assigned a class", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end

  end

  context 'homeless course' do
    context 'new_request_to_admin' do
      setup do
        @course = create(:course, :homeless)
        Notification.new_request_to_admin(@course).deliver
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
        recipients = User.where('superadmin = true OR admin = true').pluck(:email)
        assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.first.to.uniq.sort, "The recipient email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] A New Homeless Class Request has been Received", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end
  end
  
  context 'assessment_received' do
    context '(for course with assigned users)' do
      setup do
        @assessment = create(:assessment)
        @assessment.course.primary_contact = create(:user, :admin, :staff)
        @assessment.course.users = create_list(:user, 2, :staff)
        Notification.assessment_received(@assessment).deliver
      end

      # Number of emails
      should 'send one email' do
        assert_equal(1, ActionMailer::Base.deliveries.count, "Sends the wrong number of emails")
      end

      # Sender email
      should 'use the default sender email' do
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.first.from, "The sender email is wrong")
      end

      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] Class Assessment Received", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end

      # Destination email
      should 'send to the correct recipient' do
        recipients = []
        recipients += @assessment.course.users.map{ |u| u.email }
        recipients << @assessment.course.primary_contact.email
        assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.first.to.uniq.sort, "The recipient email is incorrect")
      end
    end
  
    context '(for course with no assigned users)' do

      # Destination email
      should 'send to the correct recipient' do
        @assessment = create(:assessment)
        @assessment.course.primary_contact = nil
        @assessment.course.users = []
        @assessment.save
        Notification.assessment_received(@assessment).deliver
        recipients = []
        recipients = User.where('admin = ? OR superadmin = ?', true, true).pluck(:email)
        assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.first.to.uniq.sort, "The recipient email is incorrect")
      end
    end
  end
    
  context 'new_note' do
        
    [:by_staff, :by_admin, :by_patron].each do |person|
      [:attached_course, :no_users_course, :homeless_course].each do |course|
      
        should "send to the correct recipient when #{person.to_s.sub('by_','')} writes the note for a(n) #{course.to_s.gsub('_',' ')}" do

          @note = create(:note, person, course)
          @current_user = create(:user, person.to_s.sub('by_', '').to_sym)
          Notification.new_note(@note, @current_user).deliver
  

          # Destination email
          recipients = []
          case (course)
            when :no_users_course, :homeless_course
              recipients=  User.where('admin = ? OR superadmin = ?', true, true).pluck(:email)
     
            when :attached_course
              recipients << @note.course.primary_contact.email
              recipients += @note.course.users.map{ |u| u.email }
          end
        
          recipients << @note.course.contact_email
          
          # Remove the current user's email if in the recipients list
          recipients -= [@current_user.email]
               
          assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.first.to.uniq.sort, "The recipient email is incorrect")
          
        end
        
        next if person == :by_patron

        should "send to the correct recipient for a staff-only comment when #{person.to_s.sub('by_','')} writes the note for a(n) #{course.to_s.gsub('_',' ')}" do

          @note = create(:note, person, course, :staff_only)
          @current_user = create(:user, person.to_s.sub('by_', '').to_sym)
          Notification.new_note(@note, @current_user).deliver
  

          # Destination email
          recipients = []
          case (course)
            when :no_users_course, :homeless_course
              recipients=  User.where('admin = ? OR superadmin = ?', true, true).pluck(:email)
     
            when :attached_course
              recipients << @note.course.primary_contact.email
              recipients += @note.course.users.map{ |u| u.email }
          end
          
          # Remove the current user's email if in the recipients list
          recipients -= [@current_user.email]
               
          assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.first.to.uniq.sort, "The recipient email is incorrect")
          
        end

      end
    end
  end
end


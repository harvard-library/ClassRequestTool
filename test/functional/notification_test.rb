require 'test_helper'
class NotificationTest < ActionMailer::TestCase
  
  include FactoryGirl::Syntax::Methods

  ENV['NOTIFICATIONS_STATUS'] = 'ON'

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
  
  # Testing delayed_job queue
  context 'using delayed_job queue' do
    setup do
      @run_at = Time.now + 1.hour
      Notification.delay(:run_at => @run_at, :queue => 'test').send_test_email(@patron, 'queued')
    end
    
    teardown do
      Delayed::Job.destroy_all
    end
    
    should 'submit entry to delayed_job_queue' do
      assert_equal(1, Delayed::Job.all.count, "Wrong number of jobs in the queue")
    end
    
    should 'have the right queue name' do
      assert_equal('test', Delayed::Job.first.queue, "Wrong queue assignment")
    end
    
    should 'have the right send time' do
      assert_equal(@run_at, Delayed::Job.first.run_at, "Wrong run_at time")
    end
      
    should 'have no send attempts' do
      assert_equal(0, Delayed::Job.first.attempts, "Wrong number of run attempts")
    end
    
    should 'have correct method information in the handler' do
      assert_match(/send_test_email/, Delayed::Job.first.handler, "Right method is not in the handler")
    end
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
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.last.from, "The sender email is wrong")
      end
  
      # Destination email
      should 'send to the requesting patron and additional contacts' do
        recipients = [@course.contact_email] + @course.additional_patrons.map { |ap| ap.email }
        assert_equal(recipients.sort, ActionMailer::Base.deliveries.last.to.sort, "The recipient email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] Please Assess your Recent Class at #{@course.repo_name}", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end  
    end

      # No emails for cancellations or uncancellations
#     context 'cancellation' do
#       setup do
#         Notification.cancellation(@course).deliver
#       end
#       
#       # Number of emails
#       should 'send one email' do
#         assert_equal(1, ActionMailer::Base.deliveries.count, "Sends the wrong number of emails")
#       end
#   
#       # Sender email
#       should 'use the default sender email' do
#         assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.last.from, "The sender email is wrong")
#       end
#   
#       # Destination email
#       should 'send to the correct recipients' do
#         recipients = [@course.primary_contact.email]
#         recipients += @course.users.map {|e| e.email }
#         recipients
#         assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.last.to.uniq.sort, "The recipient email is incorrect")
#       end
#       
#       # Subject
#       should 'set the subject correctly' do
#         assert_equal("[ClassRequestTool] Class cancellation confirmation", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
#       end  
#     end

#     context 'uncancellation' do
#       setup do
#         Notification.uncancellation(@course).deliver
#       end
#       
#       # Number of emails
#       should 'send one email' do
#         assert_equal(1, ActionMailer::Base.deliveries.count, "Sends the wrong number of emails")
#       end
#   
#       # Sender email
#       should 'use the default sender email' do
#         assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.last.from, "The sender email is wrong")
#       end
#   
#       # Destination email
#       should 'send to the correct recipients' do
#         recipients = [@course.primary_contact.email]
#         recipients += @course.users.map {|e| e.email }
#         recipients
#         assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.last.to.uniq.sort, "The recipient email is incorrect")
#       end
#       
#       # Subject
#       should 'set the subject correctly' do
#         assert_equal("[ClassRequestTool] Class uncancellation confirmation", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
#       end  
#     end
    
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
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.last.from, "The sender email is wrong")
      end
  
      # Destination email
      should 'send to the requesting patron and additional contacts' do
        recipients = [@course.contact_email] + @course.additional_patrons.map { |ap| ap.email }
        assert_equal(recipients.sort, ActionMailer::Base.deliveries.last.to.sort, "The recipient email is incorrect")
      end
      
      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] Class Request Successfully Submitted for Test Course Title", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
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
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.last.from, "The sender email is wrong")
      end
  
      # Destination email
      should 'send to all repository staff and superadmins' do
        recipients = @course.repository.users.map{ |u| u.email }
        recipients += User.where(superadmin: true).pluck(:email)
        assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.last.to.uniq.sort, "The recipient email is incorrect")
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
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.last.from, "The sender email is wrong")
      end
  
      # Destination email
      should 'send to all repository staff and superadmins' do
        recipients = @course.repository.users.map {|e| e.email }
        recipients += User.where(superadmin: true).pluck(:email)
        recipients
        assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.last.to.uniq.sort, "The recipient email is incorrect")
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
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.last.from, "The sender email is wrong")
      end
  
      # Destination email
      should 'send to assigned staff and the primary staff contact' do
        recipients = @course.users.map {|u| u.email }
        recipients << @course.primary_contact.email
        recipients
        assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.last.to.uniq.sort, "The recipient email is incorrect")
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
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.last.from, "The sender email is wrong")
      end
  
      # Destination email
      should 'send to the requesting patron and additional contacts' do
        recipients = [@course.contact_email] + @course.additional_patrons.map { |ap| ap.email }
        assert_equal(recipients.sort, ActionMailer::Base.deliveries.last.to.sort, "The recipient email is incorrect")
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
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.last.from, "The sender email is wrong")
      end
  
      # Destination email
      should 'send to all admins and superadmins' do
        recipients = User.where('superadmin = true OR admin = true').pluck(:email)
        assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.last.to.uniq.sort, "The recipient email is incorrect")
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
        Notification.assessment_received_to_users(@assessment).deliver
      end

      # Number of emails
      should 'send one email' do
        assert_equal(1, ActionMailer::Base.deliveries.count, "Sends the wrong number of emails")
      end

      # Sender email
      should 'use the default sender email' do
        assert_equal([DEFAULT_MAILER_SENDER], ActionMailer::Base.deliveries.last.from, "The sender email is wrong")
      end

      # Subject
      should 'set the subject correctly' do
        assert_equal("[ClassRequestTool] Class Assessment Received", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
      end

      # Destination email
      should 'send to assigned staff and the primary staff contact' do
        recipients = []
        recipients += @assessment.course.users.map{ |u| u.email }
        recipients << @assessment.course.primary_contact.email
        assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.last.to.uniq.sort, "The recipient email is incorrect")
      end
    end
  
    context '(for course with no assigned users)' do

      # Destination email
      should 'send to all admins and superadmins' do
        @assessment = create(:assessment)
        @assessment.course.primary_contact = nil
        @assessment.course.users = []
        @assessment.save
        Notification.assessment_received_to_admins(@assessment).deliver
        recipients = []
        recipients = User.where('admin = ? OR superadmin = ?', true, true).pluck(:email)
        assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.last.to.uniq.sort, "The recipient email is incorrect")
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
              recipients =  User.where('admin = ? OR superadmin = ?', true, true).pluck(:email)
     
            when :attached_course
              recipients << @note.course.primary_contact.email
              recipients += @note.course.users.map{ |u| u.email }
          end
        
          recipients << @note.course.contact_email
          recipients += @note.course.additional_patrons.map { |ap| ap.email }

          
          # Remove the current user's email if in the recipients list
          recipients -= [@current_user.email]
               
          assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.last.to.uniq.sort, "The recipient email is incorrect")
          
        end
        
        next if person == :by_patron

        should "send only to staff for a staff-only comment when #{person.to_s.sub('by_','')} writes the note for a(n) #{course.to_s.gsub('_',' ')}" do

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
               
          assert_equal(recipients.uniq.sort, ActionMailer::Base.deliveries.last.to.uniq.sort, "The recipient email is incorrect")
          
        end

      end
    end
  end
end


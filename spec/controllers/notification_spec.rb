require 'rails_helper'

describe Notification, :type => :mailer do

  # Set up delayed_job but keep the worker off because we'll deliver in real time
  before do
    ActionMailer::Base.delivery_method    = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries         = []
    @admin      = create(:user, :admin)
    @staff      = create(:user, :staff)
    @patron     = create(:user, :patron)
    @superadmin      = create(:user, :superadmin)
  end


#   before :each do
# #    allow(view).to receive(:site_url).and_return("http://example.com")
#   end

  after :each do
    ActionMailer::Base.deliveries.clear
  end

  # Testing delayed_job queue
  describe 'the delayed_job queue' do
    before do
      @wait_until = Time.now + 1.hour
      Notification.send_test_email(@patron, 'queued').deliver_later(:wait_until => @wait_until, :queue => 'test')
    end

    after do
      Delayed::Job.destroy_all
    end

    it 'accepts an entry' do
      expect(Delayed::Job.all.count).to eq(1)
    end

    it 'has the right queue name' do
      expect(Delayed::Job.first.queue).to eq('test')
    end

    it 'has the right send time' do
      expect(Delayed::Job.first.run_at.to_s).to eq(@wait_until.to_s)
    end

    it 'has no send attempts' do
      expect(Delayed::Job.first.attempts).to eq(0)
    end

    it 'has correct method information in the handler' do
      expect(Delayed::Job.first.handler).to match(/send_test_email/)
    end
  end

  describe 'notifications for' do
    before do
      Delayed::Worker.delay_jobs = false
    end
    describe 'a course attached to a repo' do
      before do
        @course = create(:course)
        @course.repository.users = create_list(:user, 3, :staff)
      end

      context 'assessment_requested' do
        before do
          @custom_text = create(:custom_text, :key => 'assessment_requested')
          Notification.assessment_requested(@course).deliver_later
        end

        # Number of emails
        it 'sends one email'  do
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end

        # Sender email
        it 'uses the default sender email' do
          expect(ActionMailer::Base.deliveries.last.from).to eq([DEFAULT_MAILER_SENDER])
        end

        # Destination email
        it 'sends to the requesting patron and additional contacts' do
          recipients = [@course.contact_email] + @course.additional_patrons.map { |ap| ap.email }
          expect(ActionMailer::Base.deliveries.last.to.sort).to eq(recipients.sort)
        end

        # Subject
        it 'sets the subject correctly' do
          expect(ActionMailer::Base.deliveries.last.subject).to eq("[ClassRequestTool] Please Assess your Recent Class at #{@course.repo_name}")
        end
      end

      context 'new_request_to_requestor' do
        before do
          custom_text = create(:custom_text, :key => 'new_request_to_requestor')
          Notification.new_request_to_requestor(@course).deliver_later
        end

        # Number of emails
        it 'sends one email' do
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end

        # Sender email
        it 'uses the default sender email' do
          expect(ActionMailer::Base.deliveries.last.from).to eq([DEFAULT_MAILER_SENDER])
        end

        # Destination email
        it 'sends to the requesting patron and additional contacts' do
          recipients = [@course.contact_email] + @course.additional_patrons.map { |ap| ap.email }
          expect(ActionMailer::Base.deliveries.last.to.sort).to eq(recipients.sort)
        end

        # Subject
        it 'sets the subject correctly' do
          assert_equal("[ClassRequestTool] Class Request Successfully Submitted for Test Course Title", ActionMailer::Base.deliveries.last.subject, "The subject is incorrect")
        end

      end

      context 'homeless course' do
        context 'new_request_to_admin' do
          before do
            @course = create(:course, :homeless)
            custom_text = create(:custom_text, :key => 'new_request_to_admin')
            Notification.new_request_to_admin(@course).deliver_later
          end

          # Number of emails
          it 'sends one email' do
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end

          # Sender email
          it 'uses the default sender email' do
            expect(ActionMailer::Base.deliveries.last.from).to eq([DEFAULT_MAILER_SENDER])
          end

          # Destination email
          it 'sends to all admins and superadmins' do
            recipients = User.where('superadmin = true OR admin = true').pluck(:email)
            expect(ActionMailer::Base.deliveries.last.to.uniq.sort).to eq(recipients.uniq.sort)
          end

          # Subject
          it 'sets the subject correctly' do
            expect(ActionMailer::Base.deliveries.last.subject).to eq("[ClassRequestTool] A New Homeless Class Request has been Received")
          end
        end
      end

      context 'emails to course staff' do
        before do
          @course = create(:course, :with_primary_contact, :with_staff)
        end

        context 'new_request_to_admin' do
          before do
            custom_text = create(:custom_text, :key => 'new_request_to_admin')
            Notification.new_request_to_admin(@course).deliver_later
          end

          # Number of emails
          it 'sends one email' do
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end

          # Sender email
          it 'uses the default sender email' do
            expect(ActionMailer::Base.deliveries.last.from).to eq([DEFAULT_MAILER_SENDER])
          end

          # Destination email
          it 'sends to all repository staff and superadmins' do
            recipients = @course.repository.users.map{ |u| u.email }
            recipients += User.where(superadmin: true).pluck(:email)
            expect(ActionMailer::Base.deliveries.last.to.uniq.sort).to eq(recipients.uniq.sort)
          end

          # Subject
          it 'sets the subject correctly' do
            expect(ActionMailer::Base.deliveries.last.subject).to eq("[ClassRequestTool] A New Class Request has been Received")
          end
        end

        context 'repo_change' do
          before do
            custom_text = create(:custom_text, :key => 'repo_change')
            Notification.repo_change(@course).deliver_later
          end

          # Number of emails
          it 'sends one email' do
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end

          # Sender email
          it 'uses the default sender email' do
            expect(ActionMailer::Base.deliveries.last.from).to eq([DEFAULT_MAILER_SENDER])
          end

          # Destination email
          it 'sends to all repository staff and superadmins' do
            recipients = @course.repository.users.map {|e| e.email }
            recipients += User.where(superadmin: true).pluck(:email)
            recipients
            expect(ActionMailer::Base.deliveries.last.to.uniq.sort).to eq(recipients.uniq.sort)
          end

          # Subject
          it 'sets the subject correctly' do
            expect(ActionMailer::Base.deliveries.last.subject).to eq("[ClassRequestTool] A Class has been Transferred to #{@course.repo_name}")
          end
        end

        context 'staff_change' do
          before do
            custom_text = create(:custom_text, :key => 'staff_change')
            Notification.staff_change(@course, @admin).deliver_later
          end

          # Number of emails
          it 'sends one email' do
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end

          # Sender email
          it 'uses the default sender email' do
           expect(ActionMailer::Base.deliveries.last.from).to eq([DEFAULT_MAILER_SENDER])
          end

          # Destination email
          it 'sends to assigned staff and the primary staff contact' do
            recipients = @course.users.map {|u| u.email }
            recipients << @course.primary_contact.email
            recipients
            expect(ActionMailer::Base.deliveries.last.to.uniq.sort).to eq(recipients.uniq.sort)
          end

          # Subject
          it 'sets the subject correctly' do
            expect(ActionMailer::Base.deliveries.last.subject).to eq("[ClassRequestTool] You have been assigned a class")
          end
        end

        context 'timeframe_change' do
          before do
            custom_text = create(:custom_text, :key => 'timeframe_change')
            Notification.timeframe_change(@course).deliver_later
          end

          # Number of emails
          it 'sends one email' do
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end

          # Sender email
          it 'uses the default sender email' do
           expect(ActionMailer::Base.deliveries.last.from).to eq([DEFAULT_MAILER_SENDER])
          end

          # Destination email
          it 'sends to the requesting patron and additional contacts' do
            recipients = [@course.contact_email] + @course.additional_patrons.map { |ap| ap.email }
            expect(ActionMailer::Base.deliveries.last.to.sort).to eq(recipients.sort)
          end

          # Subject
          it 'sets the subject correctly' do
            expect(ActionMailer::Base.deliveries.last.subject).to eq("[ClassRequestTool] Confirmation of time change")

          end
        end

      end

      context 'assessment_received' do
        context '(for course with assigned users)' do
          before do
            @assessment = create(:assessment)
            @assessment.course.primary_contact = create(:user, :admin, :staff)
            @assessment.course.save
            @assessment.course.users = create_list(:user, 2, :staff)
            custom_text = create(:custom_text, :key => 'assessment_received_to_users')
            Notification.assessment_received_to_users(@assessment).deliver_later
          end

          # Number of emails
          it 'sends one email' do
            expect(ActionMailer::Base.deliveries.count).to eq(1)
          end

          # Sender email
          it 'uses the default sender email' do
           expect(ActionMailer::Base.deliveries.last.from).to eq([DEFAULT_MAILER_SENDER])
          end

          # Subject
          it 'sets the subject correctly' do
            expect(ActionMailer::Base.deliveries.last.subject).to eq("[ClassRequestTool] Class Assessment Received")
          end

          # Destination email
          it 'sends to assigned staff and the primary staff contact' do
            recipients = []
            recipients += @assessment.course.users.map{ |u| u.email }
            recipients << @assessment.course.primary_contact.email
            expect(ActionMailer::Base.deliveries.last.to.uniq.sort).to eq(recipients.uniq.sort)
          end
        end
      end

      context '(for course with no assigned users)' do

        # Destination email
        it 'sends to all admins and superadmins' do
          @assessment = create(:assessment)
          @assessment.course.primary_contact = nil
          @assessment.course.users = []
          @assessment.save
          custom_text = create(:custom_text, :key => 'assessment_received_to_admins')
          Notification.assessment_received_to_admins(@assessment).deliver_later
          recipients = []
          recipients = User.where('admin = ? OR superadmin = ?', true, true).pluck(:email)
          expect(ActionMailer::Base.deliveries.last.to.uniq.sort).to eq(recipients.uniq.sort)
        end
      end
    end

    context 'new_note' do

      [:by_staff, :by_admin, :by_patron].each do |person|
        [:attached_course, :no_users_course, :homeless_course].each do |course|

          it "sends to the correct recipient when #{person.to_s.sub('by_','')} writes the note for a(n) #{course.to_s.gsub('_',' ')}" do

            @note = create(:note, person, course)
            @current_user = create(:user, person.to_s.sub('by_', '').to_sym)
            custom_text = create(:custom_text, :key => 'new_note')
            Notification.new_note(@note, @current_user).deliver_later


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

            expect(ActionMailer::Base.deliveries.last.to.uniq.sort).to eq(recipients.uniq.sort)

          end

          next if person == :by_patron

          it "sends only to staff for a staff-only comment when #{person.to_s.sub('by_','')} writes the note for a(n) #{course.to_s.gsub('_',' ')}" do

            @note = create(:note, person, course, :staff_only)
            @current_user = create(:user, person.to_s.sub('by_', '').to_sym)
            custom_text = create(:custom_text, :key => 'new_note')
            Notification.new_note(@note, @current_user).deliver_later


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

            expect(ActionMailer::Base.deliveries.last.to.uniq.sort).to eq(recipients.uniq.sort)

          end

        end
      end
    end
  end
end

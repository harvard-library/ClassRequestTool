class Admin::Notifications::NotificationController < Admin::AdminController

  # By default list links to all emails
  def action_missing(m, *args, &block)
  
    @test = true
    ct = Admin::CustomText.where(key: m).first
    @custom_text = ct.nil? ? '' : ct.text
  
    case (m)
      when 'assessment_received_to_admins'
        @assessment = test_assessment

      when 'assessment_received_to_users'
        @assessment = test_assessment

      when 'assessment_requested'
        @course = test_course('Closed')

      when 'cancellation'
        @course = test_course('Active')
        
      when 'homeless_courses_reminder'
        @courses = [test_course('Active', true)]

      when 'new_note'
        @course = test_course('Active')
        @note = Note.new(:staff_comment => false, :note_text => 'I have something to say about this!')

      when 'new_request_to_admin', 'new_request_to_requestor'
        @course = test_course('Active')

      when 'uncancellation'
        @course = test_course('Cancelled')

      when 'repo_change', 'staff_change', 'timeframe_change'
        @course = test_course('Active')
        
      when ':action'
        all_notifications = 'admin/notifications/all_notifications'
    end
    
    if all_notifications.nil?
      render :file => "notification/#{m}", :layout => 'notification_preview'
    else
      render :file => all_notifications
    end
  end
  
  def toggle_notifications
    if $local_config.notifications_on?
      $local_config.notifications_on = false
      status = 'OFF'
      Rails.configuration.action_mailer.perform_deliveries = false
    else  
      $local_config.notifications_on = true
      status = 'ON'      
      Rails.configuration.action_mailer.perform_deliveries = true
      # If any jobs are in the queue, send them
      Delayed::Job.all.each do |job|
        if job.run_at < Time.now
          job.run_at = Time.now
          job.last_error = nil
          job.failed_at = nil
          job.save!
        end
      end
    end
    
    if $local_config.save
      render :text => status
    else
      render :nothing
    end
  end
  
  private
    def test_assessment
      assessment = Assessment.new({
        using_materials: "This is some text", 
        involvement: "This is some text", 
        staff_experience: 2, 
        staff_availability: 2, 
        space: 2, 
        request_course: 2, 
        request_materials: 2, 
        catalogs: 2, 
        digital_collections: 2, 
        involve_again: 'No', 
        not_involve_again: 'This is some text', 
        better_future: 'This is what you could do better', 
        comments: 'These are my comments'
      })
      assessment.course = test_course('Closed')
      assessment
    end
    
    def test_course(status, homeless = false)
      course = Course.new({
        title: "Test Course Title", 
        contact_email: 'test@example.com', 
        contact_phone: '617-555-1234', 
        number_of_students: 10, 
        duration: '1.5', 
        goal: 'This is my goal', 
        contact_first_name: 'Zelda', 
        contact_last_name: 'Fitzgerald', 
        contact_username: 'ziffy',
        status: status
      })
      unless status == 'Homeless'
        course.repository = Repository.first
      end
      course
    end
end
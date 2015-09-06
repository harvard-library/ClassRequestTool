require 'csv'

class CoursesController < ApplicationController
  before_filter :authenticate_login!, :except => [:recent_show]
  before_filter :authenticate_admin_or_staff!, :only => [:take, :export, :edit]
  before_filter :process_datetimes, :only => [:create, :update]
#  before_filter :backdated?, :only => [:create, :update]

  # Formtastic inserts blank entry in user_ids, strip out any such from :user_ids
  # Ref: https://github.com/justinfrench/formtastic/issues/633
  before_filter ->(){params[:user_ids] && params[:user_ids].reject!(&:blank?)} , :only => [:create, :update]


  def additional_staff
    # Set additional staff
    if @course.repository.nil?
      User.all_admins
    elsif @course.primary_contact_id.nil?
      @course.repository.users
    else
      @course.repository.users.where('user_id <> ?', @course.primary_contact_id)
    end
  end

      
  def cancel
    course = Course.find(params[:id])
    course.status = 'Cancelled'
    if course.save(validate: false)         # Don't bother with validation since the class is being cancelled
      # Don't bother with notification
      flash_message :info, "The class <em>#{course.title}</em> was successfully cancelled.".html_safe
    else
      flash_message :danger, "There was an error cancelling the class."
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
  
  def close
    @course = Course.find(params[:id])
  
    return false unless @course.completed?
    
    if params[:class_action] == 'close-class'
      status = 'Closed'
    else
      status = 'Active'
    end
    
    if @course.update(:status => status)
      render :text => @course.status
    else 
      render :nothing
    end
  end
  
  def course_owner?(course)
    current_user == course.primary_contact|| course.users.include?(current_user)
  end
  
  def create

    unless params[:course][:repository_id].blank?
      @repository = Repository.find(params[:course][:repository_id])
    end

    # Do some parameter manipulation    
    process_params
            
    @course = Course.new(course_params)

    respond_to do |format|
      if @course.save
        unless @course.backdated?
          Notification.new_request_to_requestor(@course).deliver_later(:queue => 'notifications')
          Notification.new_request_to_admin(@course).deliver_later(:queue => 'notifications')
          flash_message :info, "New course request confirmation sent to patron"  unless $local_config.notifications_on? 
          flash_message :info, "New request notification sent to admins"  unless $local_config.notifications_on? 
        end
        flash_message :info, 'The class request was successfully submitted.'
        
        format.html { redirect_to @course }
        format.json { render json: @course, status: :created, location: @course }
      else
        error_messages = "<p><strong>Please fix these problems:</strong></p>\n"
        @course.errors.messages.each do |field, msgs|
          msgs.each do |msg|
            error_messages += "<p>#{field.to_s.titlecase}: #{msg}</p>\n"
          end
        end
        flash.now[:danger] = error_messages.html_safe

        format.html { render :new }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def dashboard
    @homeless               = []
    @closed                 = []
    @to_close               = []
    @unclaimed_unscheduled  = []
    @unclaimed_scheduled    = []
    @claimed_unscheduled    = []
    @claimed_scheduled      = []
    
    #Loop over courses and slot them into their categories
    @courses = Course.order_by_submitted.eager_load(:repository, :sections, :users, :primary_contact)
        
    @courses.each do |course|
      if course.homeless?
        @homeless << course
      elsif course_owner?(course)
        if course.completed?
          if course.closed?
            @closed << course
          else
            @to_close << course
          end
        else 
          if course.scheduled?     
            @claimed_scheduled << course
          else
            @claimed_unscheduled << course
            section_ids = course.missing_dates?
            if section_ids
              @sections = Section.find(section_ids)
            end
          end
        end
        
      elsif course.unclaimed? && current_user.repositories.include?(course.repository)
        if course.scheduled?     
          @unclaimed_scheduled << course
        else
          @unclaimed_unscheduled << course
          section_ids = course.missing_dates?
          if section_ids
            @sections = Section.find(section_ids)
          end
        end
      end
    end 
  end 

  def destroy
    @course = Course.find(params[:id])
    unless current_user.staff? || current_user.can_admin? || @course.contact_email == current_user.email
      redirect_to('/') and return
    end
    @course.destroy

    respond_to do |format|
      format.html { redirect_to courses_url }
      format.json { head :no_content }
    end
  end

  def edit
    unless current_user.staff? || current_user.can_admin? || @course.contact_email == current_user.email
       redirect_to('/') and return
    end

    @course = Course.find(params[:id])
    @additional_staff = additional_staff
    @collaboration_options = $local_config.collaboration_options
    
    # Set affiliation variables
    if $affiliates.map { |opt| opt.name }.include?(@course.affiliation)
      @affiliation_selection = 'yes'
      @local_affiliation = @course.affiliation
    elsif @course.affiliation =~ /\AOther:/
      @affiliation_selection = 'yes'
      @local_affiliation = "Other"
      @other_affiliation = @course.affiliation.gsub(/\aOther: /,'') 
    else
      @affiliation_selection = 'no'
      @other_affiliation = @course.affiliation
    end
    
    unless @course.repository.nil?
      @all_staff_services = @course.repository.all_staff_services
      @all_technologies   = @course.repository.all_technologies
      @possible_collaborations = Repository.all - [@course.repository]
    else
      @all_staff_services = StaffService.find($local_config.homeless_staff_services)
      @all_technologies   = ItemAttribute.find($local_config.homeless_technologies)
      @possible_collaborations = Repository.all
    end
  end


  def index
    if current_user.can_admin?
      @title = 'All Classes'
      @courses = Course.order_by_submitted.eager_load(:sections, :repository, :primary_contact)
      @nil_date_warning = false
      @courses.reverse.each do |c|
        if c.last_date.nil?
          @nil_date_warning = true
          break
        end
      end
      @csv = params[:csv]
    elsif current_user.staff?
      @title = 'Classes for Your Library/Archive'
      @courses = Course.where("repository_id IN (#{current_user.repositories.map { |r| r.id  }.join(',')})").order_by_submitted.includes(:sections)
    elsif current_user.patron?
      @title = 'My Classes'
      @courses = Course.user_is_patron(current_user.email).order_by_submitted.includes(:sections, :repository)
    end
    @repositories = Repository.order('name ASC')
  end

  def new
  
    @course = Course.new()
    @collaboration_options = $local_config.collaboration_options
    
    unless params[:repository].blank?
      @repository = Repository.find(params[:repository])
      @course.repository_id = @repository.id
      @all_staff_services = @repository.staff_services
      @all_technologies = @repository.item_attributes
      @possible_collaborations = Repository.all - [@repository]
    else
      @all_staff_services = StaffService.find($local_config.homeless_staff_services)
      @all_technologies   = ItemAttribute.find($local_config.homeless_technologies)
      @possible_collaborations = Repository.all
    end
    
    # Automatically create with 1 section
    if params[:course].blank? || params[:course][:sections_attributes].blank?
      @course.sections.build
    end

    @additional_staff = additional_staff

    @uploader = SyllabusUploader.new

    
  end

  def new_section_or_session_block
    session_count = params[:session_count].try(:to_i) || 1
    section_count = params[:section_count].try(:to_i) || 1
    
    # This requires a new section
    locals = { 
      :course_id => params[:course_id], 
      :session_count => session_count, 
      :section_count => section_count, 
      :admin => current_user.can_schedule?, 
      :section_index => params[:section_index],
    }
    respond_to do |format|
      format.html do
        if params[:to_render] == 'session'
          locals[:sesh] = [Section.new(:session => params[:session_count])]
          render :partial => 'session_block', :locals => locals
        elsif params[:to_render] == 'section'
          locals[:sect] = Section.new(:session => params[:session_count])
          render :partial => 'section_block', :locals => locals
        end
      end
    end
  end
  
  # Processes all datetime fields that map directly to AR columns
  # NOTE: Anything NOT mapping to a datetime column needs to be handled
  #   separately
  def process_datetimes
    dt_cols = Course.columns.select {|c| c.type == :datetime}
    dt_cols.each do |col|
      if params[:course] && params[:course].include?(col.name) && !params[:course][col.name].blank?
        unless col.array
          begin
            params[:course][col.name] = Time.zone.parse(params[:course][col.name]).utc.to_datetime
          rescue
            params[:course].delete(col.name)
          end
        else
          params[:course][col.name] = params[:course][col.name].map do |date|
            begin
              Time.zone.parse(date).utc.to_datetime
            rescue
              nil
            end
          end.reject(&:nil?)
          params[:course].delete(col.name) if params[:course][col.name].blank?
        end
      end
    end
    # Speaking of which, handle nested sessions
    if params[:course] && !params[:course][:sections_attributes].blank?
      sections = params[:course][:sections_attributes]
      sections.each_pair do |k, v|
        if v[:requested_dates]
          v[:requested_dates].map! do |date|
            begin
              Time.zone.parse(date).utc.to_datetime
            rescue
              nil
            end
          end
          v[:requested_dates].reject!(&:blank?)
        end
      end
    end
  end

  def recent_show
    @course = Course.find(params[:id])
  end

  def repo_select
    unless params[:repo] == ""
      @repository = Repository.find(params[:repo])
    else
      @repository = ""
    end
    #render :partial => "shared/forms/course_staff_service"
    redirect_to new_course_path(:repository => @repository)
  end

  def show
    @course = Course.includes(sections: :room).find(params[:id])
    unless current_user.staff? || current_user.can_admin? || @course.contact_email == current_user.email
       redirect_to('/') and return
    end
    @note = Note.new
    @notes = Note.where(:course_id => @course.id).order("created_at DESC").includes(:user)
    @note_type = {
      :system => false,
      :staff =>  false,
      :patron => false
    }
    @notes.each do |note|
      @note_type[:system] = true if note.auto?
      @note_type[:staff]  = true if note.staff_comment?
      @note_type[:patron] = true if !(note.auto? || note.staff_comment?)
      break if @note_type.inject(true) { |anded, n_type| anded && n_type[1] }
    end  
    
    first_section = @course.sections.where("actual_date IS NOT NULL").order("actual_date ASC").first
    if first_section.nil? || first_section.room.nil?
      room = ''
    else
      room = first_section.room.name
    end
    
    @aeon_data = {
      :room => room,
      :title => @course.title,
      :staffContact => @course.primary_contact.nil? ? '' : @course.primary_contact.full_name,
      :patronContact => @course.contact_full_name,
      :class => @course.course_number,
      :affiliation => @course.affiliation,
      :requestorUsername => @course.contact_username,
      :subject => @course.subject,
      :repository => @course.repo_name,
      :timeframe => first_section.nil? ? '' : first_section.actual_date.utc.strftime(DATETIME_AEON_FORMAT),
      :duration => @course.duration
    }    
  end

  # Helper for update, used to determine status
  def set_status(c_params)
    if c_params[:status] == "Closed" || @course && @course.status == "Closed"
      "Closed"
    elsif c_params[:status] == "Cancelled" || @course && @course.status == "Cancelled"
      "Cancelled"
    else
      "Active"
    end
  end

  def take
    @course = Course.find(params[:id])
    @course.users << current_user
    if @course.repository.nil?
      @course.repository = current_user.repositories[0]
    end
    @course.save
    respond_to do |format|
      format.html { redirect_to dashboard_welcome_index_url, info: 'Class was successfully claimed.' }
    end
  end 
  
  def uncancel
    course = Course.find(params[:id])
    course.status = 'Active'
    
    if course.save(validate: false)         # Don't bother with validation since the class is being recovered
#      Notification.uncancellation(course).deliver_later(:queue => 'notifications')
      flash_message :info, "The class <em>#{course.title}</em> was successfully uncancelled.".html_safe
    else
      flash_message :danger, "There was an error uncancelling the class."
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  def update
    unless current_user.staff? || current_user.can_admin? || @course.contact_email == current_user.email
      redirect_to('/') and return
    end

    @course = Course.find(params[:id])

    # Do some parameter manipulation
    process_params
    
    # Begin gross status manipulation *&!%    
    @course.attributes = course_params
    
    if @course.save
      if params[:course][:status] == "Closed" # check params because editing closed courses should not create notes
        @course.notes.create(:note_text => "Class has marked as closed.", :user_id => current_user.id, :auto => true)
        unless params[:send_assessment_email].blank?
          Notification.assessment_requested(@course).deliver_later(:queue => 'notifications') 
          flash_message :info, "Assessment requested notification sent"  unless $local_config.notifications_on? 
          @course.notes.create(:note_text => "Assessment email sent.", :user_id => current_user.id, :auto => true)
        end
      end

      if repo_change?
        # FIX INFO_NEEDED Should "changed from" repos get email? Inquiring Bobbis want to know
        Notification.repo_change(@course).deliver_later(:queue => 'changes') unless @course.repository.blank?
        flash_message :info, "Repository change notification sent"  unless $local_config.notifications_on? 
        @course.notes.create(:note_text => "Library/Archive changed to #{@course.repository.blank? ? "none" : @course.repository.name + ". Email sent."}.",
                             :user_id => current_user.id, :auto => true)
      end

      if staff_change?
        # FIX INFO_NEEDED Should "dropped" staff members get this email?
        Notification.staff_change(@course, current_user).deliver_later(:queue => 'notifications')
        flash_message :info, "Staff change notification sent"  unless $local_config.notifications_on? 
        @course.notes.create(:note_text => "Staff change email sent.", :user_id => current_user.id, :auto => true)
      end
      
      unless params[:send_timeframe_email].blank?
        Notification.timeframe_change.deliver_later(:queue => 'notifications')
        flash_message :info, "Time change confirmation sent"  unless $local_config.notifications_on?
      end

      respond_to do |format|
        format.html { redirect_to course_url(@course), info: 'Class was successfully updated.' }
        format.json { head :no_content }
      end

    else
      flash.now[:danger] = "Update Error: Could not save"
      @course.sections.blank? ? @course.sections << Section.new(:course => @course) : nil
      respond_to do |format|
        format.html { render :action => :edit }
        format.json { render :json => @course.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  private
    def process_params
      params[:course][:status] = set_status(params[:course])
      
      # strip out empty sections and convert section hash to section array
      if params.has_key?(:course) && params[:course].has_key?(:sections_attributes)
        params[:course][:sections_attributes].delete_if{|k,v| v[:requested_dates] && v[:requested_dates].reject(&:nil?).blank? && v[:actual_date].blank? && v[:_destroy].blank?}
        sections = []
        params[:course][:sections_attributes].each do |i, section|
          sections << section
        end
        params[:course][:sections_attributes] = sections
      end
      
      # Remove empty additional patrons
      if params.has_key?(:course) && params[:course].has_key?(:additional_patrons_attributes)
        params[:course][:additional_patrons_attributes].delete_if{|k,v| v[:email].blank?}
      end
      
      # Remove empty user ids
      params[:course][:user_ids].each do |id|
        if id.blank?
          params[:course][:user_ids].delete(id)
        end
      end
      
      # set affiliation
      if params[:local_affiliation].blank?
        params[:course][:affiliation] = params[:other_affiliation]
      elsif  params[:local_affiliation] == 'Other'
        params[:course][:affiliation] = "Other: #{params[:other_affiliation]}"
      else
        params[:course][:affiliation] = params[:local_affiliation]
      end
    
      # Use flash to save affiliation parameters in case there is a form error
      @affiliation_selection = params[:affiliation_selection]
      @other_affiliation   = params[:other_affiliation]
      @local_affiliation = params[:local_affiliation]
    end
    
    def repo_change?
      if params[:course][:repository_id].blank? || @course.repository_id == params[:course][:repository_id].to_i 
        return false
      else
        new_repo = Repository.find(params[:course][:repository_id].to_i)
        return ! new_repo.affiliated?(current_user)
      end
    end
    
    def staff_change?
      return true if @course.primary_contact.blank? && !params[:course][:primary_contact_id].blank?
      return true if !@course.primary_contact.blank? && (@course.primary_contact.id != params[:course][:primary_contact_id])
      return true if @course.users.blank? && !params[:course][:user_ids].blank?
      return true if !params[:course][:user_ids].nil? && (@course.users.map{ |u| u.id.to_s }.sort != params[:course][:user_ids].sort)
      false
    end 

    def course_params
      params.require(:course).permit(
        :title, :number_of_students, :goal,
        :contact_username, :contact_first_name, :contact_last_name, :contact_email, :contact_phone,   #contact info
        :room_id, :repository_id,
        :subject, :course_number, :affiliation,  :session_count,                                      #values
        :comments, :instruction_session, :status, :assisting_repository_id, 
        :syllabus, :remove_syllabus, :external_syllabus,                                              #syllabus
        :pre_class_appt, :timeframe, :timeframe_2, :timeframe_3, :timeframe_4, :duration,             #concrete schedule vals
        :time_choice_1, :time_choice_2, :time_choice_3, :time_choice_4,                               # tentative schedule vals
        #:pre_class_appt_choice_1, :pre_class_appt_choice_2, :pre_class_appt_choice_3,                #unused
        :section_count, :session_count, :total_attendance,                                            # stats
         
        :primary_contact_id,                                                                          # associations
        {:collaboration_options           => [] },
        { :item_attribute_ids             => [] },  
        { :user_ids                       => [] }, 
        { :staff_service_ids              => [] },
        { :additional_patrons_attributes  => [
          :id, :_destroy,
          :first_name, :last_name, :email, :role, :course_id
        ]}, 
        { :sections_attributes => [
          :id,
          :_destroy,
          {:requested_dates => []},   # Postgres array of DateTimes
          :actual_date,               # Single DateTime
          :session,                   # Integer representing session membership
          :session_duration,          # Section/session duration
          :room_id,
          :course,
          :headcount
        ]}
      )
    end    
end

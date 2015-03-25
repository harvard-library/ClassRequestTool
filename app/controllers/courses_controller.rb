require 'csv'

class CoursesController < ApplicationController
  before_filter :authenticate_login!, :except => [:recent_show]
  before_filter :authenticate_admin_or_staff!, :only => [:take, :export, :edit]
  before_filter :process_datetimes, :only => [:create, :update]
  before_filter :backdated?, :only => [:create, :update]

  # Formtastic inserts blank entry in user_ids, strip out any such from :user_ids
  # Ref: https://github.com/justinfrench/formtastic/issues/633
  before_filter ->(){params[:user_ids] && params[:user_ids].reject!(&:blank?)} , :only => [:create, :update]

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

  def backdated?
    unless params[:course][:sections_attributes] && params[:course][:sections_attributes].values.select{|s| !s[:actual_date].blank?}.blank?
      @backdated = (params[:course][:sections_attributes] && params[:course][:sections_attributes].values.select {|s| !s[:actual_date].blank? && s[:actual_date] < DateTime.now}.blank?)
    end
  end

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

  def cancel
    course = Course.find(params[:id])
    course.status = 'Cancelled'
    if course.save(validate: false)         # Don't bother with validation since the class is being cancelled
#      Notification.delay.cancellation(course)
      flash[:notice] = "The class <em>#{course.title}</em> was successfully cancelled.".html_safe
    else
      flash[:alert] = "There was an error cancelling the class."
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end
  
  def create

    unless params[:course][:repository_id].blank?
      @repository = Repository.find(params[:course][:repository_id])
    end

    params[:course][:status] = set_status(params[:course])

    # strip out empty sections
    if params.has_key?(:course) && params[:course].has_key?(:sections_attributes)
      params[:course][:sections_attributes].delete_if{|k,v| v[:requested_dates] && v[:requested_dates].reject(&:nil?).blank? && v[:actual_date].blank?}
    end
    
    # Remove empty additional patrons
    if params.has_key?(:course) && params[:course].has_key?(:additional_patrons_attributes)
      params[:course][:additional_patrons_attributes].delete_if{|k,v| v[:email].blank?}
    end
    
    # set affiliation
    if params[:harvard_affiliation].blank? || params[:harvard_affiliation] == 'Other'
      params[:course][:affiliation] = params[:other_affiliation]
    else
      params[:course][:affiliation] = "#{params[:harvard_affiliation] == 'Other' ? 'Other: ' : ''} #{params[:harvard_affiliation]}"
    end
    
    # Use flash to save affiliation parameters in case there is a form error
    flash[:harvard_affiliation] = params[:harvard_affiliation]
    flash[:other_affiliation]   = params[:other_affiliation]
    flash[:harvard_affiliation] = params[:harvard_affiliation]
            
    @course = Course.new(params[:course])

    respond_to do |format|
      if @course.save
        unless @backdated
          Notification.delay(:queue => 'new_requests').new_request_to_requestor(@course)
          Notification.delay(:queue => 'new_requests').new_request_to_admin(@course)
        end
        
        format.html { redirect_to @course, notice: 'The class request was successfully submitted.' }
        format.json { render json: @course, status: :created, location: @course }
      else
        flash.now[:error] = "Please correct the errors in the form."

        format.html { render :new }
        format.json { render json: @course.errors, status: :unprocessable_entity }
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
    @course = Course.find(params[:id])
    unless current_user.staff? || current_user.can_admin? || @course.contact_email == current_user.email
       redirect_to('/') and return
    end

    @additional_staff = additional_staff

    # @staff_involvement = @course.staff_involvement.split(',')
  end

  def export
    exportable = [
      :title,
      :subject,
      :course_number,
      :affiliation,
      :contact_email,
      :contact_phone,
      :pre_class_appt,
      :repository,
      :staff_involvement,
      :number_of_students,
      :status,
      :syllabus,
      :external_syllabus,
      :duration,
      :comments,
      :session_count,
      :goal,
      :instruction_session,
      :contact_first_name,
      :contact_last_name,
      :contact_username,
      :primary_contact,
      :staff
    ]
      
    @sections = Section.joins(:course).order('course_id ASC NULLS LAST, session ASC NULLS LAST, actual_date ASC NULLS LAST')
    csv = CSV.generate(:encoding => 'utf-8') do |csv|
      csv << (exportable + [:session, :section_id, :date, :headcount]).map { |c| c.to_s.gsub(/_/, ' ').titlecase }
      @sections.each do |section|
        course = section.course
        values = []
        exportable.each do |c|
          case (c)
            when :repository
              values << (course.repository.blank? ? '' : course.repository.name)
            when :primary_contact
              values << (course.primary_contact.blank? ? '' : course.primary_contact.full_name)
            when :staff
              values << (course.users.count > 0 ? course.users.map{ |u| u.full_name }.join('!') : '')
            else
              values << course.send("#{c}")
          end
        end
        values += [section.session, section.id, section.actual_date, (section.headcount || 'Not Entered')]
        csv << values
      end
    end
    render :text => csv
  end  

  def index
    if current_user.can_admin?
      @title = 'All Classes'
      @courses = Course.order_by_submitted.includes(:sections, :repository, :primary_contact)
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
      @title = 'Your Classes'
      @courses = Course.user_is_patron(current_user.email).order_by_submitted.includes(:sections, :repository)
    end
    @repositories = Repository.order('name ASC')
  end

  def new
  
    @course = Course.new()
    
    unless params[:repository].blank?
      @repository = Repository.find(params[:repository])
      @course.repository_id = @repository.id
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
  
  def show
    @course = Course.includes(sections: :room).find(params[:id])
    unless current_user.staff? || current_user.can_admin? || @course.contact_email == current_user.email
       redirect_to('/') and return
    end
    @note = Note.new
    notes = Note.where(:course_id => @course.id).order("created_at DESC").includes(:user).group_by(&:staff_comment)
    @staff_only_notes = notes[true]
    @notes = notes[false]
    
    first_section = @course.sections.where("actual_date IS NOT NULL").order("actual_date ASC").first
    if first_section.nil? || first_section.room.nil?
      room = ''
    else
      room = room.name
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
      :timeframe => first_section.nil? ? '' : first_section.actual_date.strftime(DATETIME_AEON_FORMAT),
      :duration => @course.duration
    }
  end

  def uncancel
    course = Course.find(params[:id])
    course.status = 'Active'
    
    if course.save(validate: false)         # Don't bother with validation since the class is being recovered
#      Notification.delay.uncancellation(course)
      flash[:notice] = "The class <em>#{course.title}</em> was successfully uncancelled.".html_safe
    else
      flash[:alert] = "There was an error uncancelling the class."
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
    end
  end

  def update
    @course = Course.find(params[:id])
    unless current_user.staff? || current_user.can_admin? || @course.contact_email == current_user.email
      redirect_to('/') and return
    end
    
    if params.has_key?(:course) && params[:course].has_key?(:sections_attributes)
      # strip out empty sections
      params[:course][:sections_attributes].delete_if{|k,v| v[:requested_dates] && v[:requested_dates].reject(&:nil?).blank? && v[:actual_date].blank? && v[:_destroy].blank?}
    end

    send_repo_change_notification = false
    send_staff_change_notification = false

    # Begin gross status manipulation *&!%
    # Set notification statuses
    send_repo_change_notification = repo_change?
    send_staff_change_notification = staff_change? && !(current_user.id == params[:course][:primary_contact_id].to_i)

    params[:course][:status] = set_status(params[:course])
    # End gross status manipulation
        
    @course.attributes = params[:course]

    if @course.save
      if params[:course][:status] == "Closed" # check params because editing closed courses should not create notes
        @course.notes.create(:note_text => "Class has marked as closed.", :user_id => current_user.id, :staff_comment => true)
        Notification.delay(:queue => 'assessments').assessment_requested(@course)
        @course.notes.create(:note_text => "Assessment email sent.", :user_id => current_user.id, :staff_comment => true)
      end

      if send_repo_change_notification
        # FIX INFO_NEEDED Should "changed from" repos get email? Inquiring Bobbis want to know
        Notification.delay(:queue => 'changes').repo_change(@course) unless @course.repository.blank?
        @course.notes.create(:note_text => "Library/Archive changed to #{@course.repository.blank? ? "none" : @course.repository.name + ". Email sent."}.",
                             :user_id => current_user.id, :staff_comment => true)
      end

      if send_staff_change_notification
        # FIX INFO_NEEDED Should "dropped" staff members get this email?
        Notification.delay(:queue => 'changes').staff_change(@course, current_user)
        @course.notes.create(:note_text => "Staff change email sent.", :user_id => current_user.id, :staff_comment => true)
      end

      respond_to do |format|
        format.html { redirect_to course_url(@course), notice: 'Class was successfully updated.' }
        format.json { head :no_content }
      end

    else
      flash.now[:error] = "Update Error: Could not save"
      @course.sections.blank? ? @course.sections << Section.new(:course => @course) : nil
      respond_to do |format|
        format.html { render :action => :edit }
        format.json { render :json => @course.errors, :status => :unprocessable_entity }
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
    #render :partial => "shared/forms/course_staff_involvement"
    redirect_to new_course_path(:repository => @repository)
  end

  def take
    @course = Course.find(params[:id])
    @course.users << current_user
    if @course.repository.nil?
      @course.repository = current_user.repositories[0]
    end
    @course.save
    respond_to do |format|
      format.html { redirect_to dashboard_welcome_index_url, notice: 'Class was successfully claimed.' }
    end
  end 
  
  private
    def repo_change?
      !params[:course][:repository_id].blank? && @course.repository_id != params[:course][:repository_id].to_i
    end
    
    def staff_change?
      return true if @course.primary_contact.blank? && !params[:course][:primary_contact_id].blank?
      return true if !@course.primary_contact.blank? && (@course.primary_contact.id != params[:course][:primary_contact_id])
      return true if @course.users.blank? && !params[:course][:user_ids].blank?
      return true if !params[:course][:user_ids].nil? && (@course.users.map{ |u| u.id.to_s }.sort != params[:course][:user_ids].sort)

      false
    end 
end

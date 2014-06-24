require 'csv'

class CoursesController < ApplicationController
  before_filter :authenticate_login!, :except => [:recent_show]
  before_filter :authenticate_admin_or_staff!, :only => [:take, :export]
  #before_filter :authenticate_user!, :except => [:take, :recent_show]
  before_filter :process_datetimes, :only => [:create, :update]

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

  def index
    @courses_all = Course.ordered_by_last_section.all #.all required due to AR inelegance (count drops the select off of ordered_by_last_section)
    @courses_mine_current = current_user.mine_current
    @courses_mine_past = current_user.mine_past
    @repositories = Repository.order('name ASC')
    @csv = params[:csv]
  end

  def show
    @course = Course.find(params[:id])
    unless current_user.try(:staff?) || current_user.try(:admin?) || current_user.try(:superadmin?) || @course.contact_email == current_user.email
       redirect_to('/') and return
    end
    @note = Note.new
    notes = Note.where(:course_id => @course.id).order("created_at DESC").group_by(&:staff_comment)
    @staff_only_notes = notes[true]
    @notes = notes[false]
  end

  def new
    unless params[:repository].blank?
      @course = Course.new(:repository_id => Repository.find(params[:repository]).id)
      @repository = Repository.find(params[:repository])
    else
      @course = Course.new
    end
    @uploader = FileUploader.new
    @course.sections << (0..3).map {Section.new(:course => @course)}
  end

  def edit
    @course = Course.find(params[:id])
    unless current_user.try(:staff?) || current_user.try(:admin?) || current_user.try(:superadmin?) || @course.contact_email == current_user.email
       redirect_to('/') and return
    end
    @staff_involvement = @course.staff_involvement.split(',')
  end

  def create
    unless params[:course][:repository_id].blank?
      @repository = Repository.find(params[:course][:repository_id])
    end

    if params[:course][:repository_id].blank?
      params[:course][:status] = "Homeless"
    elsif params[:course][:sections_attributes].blank?
      if (params[:course][:primary_contact_id].blank?) && (params[:course][:user_ids].nil? || params[:course][:user_ids][1].nil? || params[:course][:user_ids][1].empty?)
        params[:course][:status] = "Unclaimed, Unscheduled"
      else
        params[:course][:status] = "Claimed, Unscheduled"
      end
    else
      if (params[:course][:primary_contact_id].blank?) && (params[:course][:user_ids].nil? || params[:course][:user_ids][1].nil? || params[:course][:user_ids][1].empty?)
        params[:course][:status] = "Scheduled, Unclaimed"
      else
        params[:course][:status] = "Scheduled, Claimed"
      end
    end

    # strip out empty sections
    params[:course][:sections_attributes].delete_if{|k,v| v[:requested_dates].reject(&:nil?).blank? && v[:actual_date].blank?}

    @course = Course.new(params[:course])

    respond_to do |format|
      if params[:schedule_future_class] == "1"
        unless params[:course][:sections_attributes].select {|s| !s[:actual_date].blank? && s[:actual_date] < DateTime.now}.blank?
          flash[:error] = "Please confirm scheduling class in the past."
          format.html { render action: "new" }
          format.json { render json: @course.errors, status: :unprocessable_entity }
        end
      end
      if @course.save
        if current_user.try(:patron?) || params[:schedule_future_class] == "1"
          @course.new_request_email
        end
        if user_signed_in?
          format.html { redirect_to summary_course_url(@course), notice: 'Class was successfully created.' }
        else
          format.html { redirect_to summary_course_url(:id => @course.id), notice: 'Class was successfully submitted for approval.' }
        end
      else
        flash[:error] = "Please correct the errors in the form."
        format.html { render action: "new" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @course = Course.find(params[:id])
    unless current_user.try(:staff?) || current_user.try(:admin?) || current_user.try(:superadmin?) || @course.contact_email == current_user.email
      redirect_to('/') and return
    end

    if params[:send_assessment_email] == "1" || params[:no_assessment_email] == "1"
      @course.status = "Closed"

      respond_to do |format|
        if @course.save
          #add note to course that course is closed
          note = Note.new(:note_text => "Class has been marked as closed.", :course_id => @course.id, :user_id => current_user.id)
          note.save

          if params[:send_assessment_email] == "1" && (params[:no_assessment_email].nil? || params[:no_assessment_email] == "0")
            @course.send_assessment_email
            #add note to course that an email has been sent
            note = Note.new(:note_text => "Assessment email sent.", :course_id => @course.id, :user_id => current_user.id)
            note.save
          end

          format.html { redirect_to course_url(@course), notice: 'Class was successfully closed.' }
          format.json { head :no_content }
        else
          flash[:error] = "Please correct the errors."
          format.html { render action: "show" }
          format.json { render json: @course.errors, status: :unprocessable_entity }
        end
      end
    else
      unless params[:course][:repository_id].blank?
        @repository = Repository.find(params[:course][:repository_id])
      end

      repo_change = false
      staff_change = false
      timeframe_change = false

      if @course.repository != @repository
        repo_change = true
      end
      if (@course.primary_contact.blank? && !params[:course][:primary_contact_id].blank?) ||
          (@course.users.blank? && !params[:course][:user_ids].blank? && !params[:course][:user_ids][1].blank?)
        staff_change = true
      end
      if not @course.sections.map(&:actual_date).reject(&:nil?).blank?
        timeframe_change = true
      end

      if params[:course][:repository_id].blank?
        params[:course][:status] = "Homeless"
      elsif params[:course][:sections_attributes].first && params[:course][:sections_attributes][:actual_date].blank?
        if (params[:course][:primary_contact_id].blank?) &&
            (params[:course][:user_ids].blank? || params[:course][:user_ids][1].blank?)
          params[:course][:status] = "Unclaimed, Unscheduled"
        else
          params[:course][:status] = "Claimed, Unscheduled"
        end
      else
        if (params[:course][:primary_contact_id].blank?) &&
            (params[:course][:user_ids].blank? || params[:course][:user_ids][1].blank?)
          params[:course][:status] = "Scheduled, Unclaimed"
        else
          params[:course][:status] = "Scheduled, Claimed"
        end
      end

      respond_to do |format|
        if params[:schedule_future_class] == "1"
          unless params[:course][:sections_attributes].select {|s| !s[:actual_date].blank? && s[:actual_date] < DateTime.now}.blank?
            flash[:error] = "Please confirm scheduling class in the past."
            format.html { render action: "edit" }
            format.json { render json: @course.errors, status: :unprocessable_entity }
          end
        end
        if params[:course][:status] == "Closed"
          #add note to course that course is closed
          note = Note.new(:note_text => "Class has been marked as closed.", :course_id => @course.id, :user_id => current_user.id)
          note.save
        end
        if @course.update_attributes(params[:course])
          if params[:send_assessment_email] == "1" && (params[:no_assessment_email].nil? || params[:no_assessment_email] == "0")
            @course.send_assessment_email
            #add note to course that an email has been sent
            note = Note.new(:note_text => "Assessment email sent.", :course_id => @course.id, :user_id => current_user.id)
            note.save
          end
          if repo_change == true
            unless @course.repository.blank?
              @course.send_repo_change_email
              #add note to course that an email has been sent
              note = Note.new(:note_text => "Library/Archive change email sent.", :course_id => @course.id, :user_id => current_user.id)
              note.save
            else
              #add note to course that an repo changed to null
              note = Note.new(:note_text => "Library/Archive changed to none.", :course_id => @course.id, :user_id => current_user.id)
              note.save
            end

          end
          if staff_change == true
            @course.send_staff_change_email(current_user)
            #add note to course that an email has been sent
            note = Note.new(:note_text => "Staff change email sent.", :course_id => @course.id, :user_id => current_user.id)
            note.save
          end
          if params[:send_timeframe_email] == "1"
            @course.send_timeframe_change_email
            #add note to course that an email has been sent
            note = Note.new(:note_text => "Date/Time set/change email sent.", :course_id => @course.id, :user_id => current_user.id)
            note.save
          end

          format.html { redirect_to course_url(@course), notice: 'Class was successfully updated.' }
          format.json { head :no_content }
        else
          flash[:error] = "Please correct the errors in the form."
          format.html { render action: "edit" }
          format.json { render json: @course.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @course = Course.find(params[:id])
    unless current_user.try(:staff?) || current_user.try(:admin?) || current_user.try(:superadmin?) || @course.contact_email == current_user.email
       redirect_to('/') and return
    end
    @course.destroy

    respond_to do |format|
      format.html { redirect_to courses_url }
      format.json { head :no_content }
    end
  end

  def summary
    @course = Course.find(params[:id])
    unless current_user.try(:staff?) || current_user.try(:admin?) || current_user.try(:superadmin?) || @course.contact_email == current_user.email
       redirect_to('/') and return
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

  def export
    @sections = Section.joins(:course).order('course_id ASC NULLS LAST, session ASC NULLS LAST, actual_date ASC NULLS LAST')
    csv = CSV.generate(:encoding => 'utf-8') do |csv|
      csv << Course.attribute_names + [:session, :section_id, :date]
      @sections.each do |section|
        values = Course.attribute_names.map {|name| section.course.send name}
        values += [section.session, section.id, section.actual_date]
        csv << values
      end
    end
    render :text => csv
  end

  def session_block
    index = params[:index].try(:to_i) || 1
    section_index = params[:section_index].try(:to_i) || 1
    respond_to do |format|
      format.html do
        render :partial => 'shared/forms/session_block',
               :locals => { :index => index, :section_index => section_index, :admin => current_user.can_schedule?}
      end
    end
  end
end

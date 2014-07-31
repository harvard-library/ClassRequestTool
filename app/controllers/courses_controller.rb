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

  def backdated?
    @backdated = (params[:course][:sections_attributes] && params[:course][:sections_attributes].values.select {|s| !s[:actual_date].blank? && s[:actual_date] < DateTime.now}.blank?)
  end

  # Helper for update, used to determine status
  def adjust_status(c_params)
    if c_params[:status] == "Closed" || @course && @course.status == "Closed"
      "Closed"
    elsif c_params[:repository_id].blank?
      "Homeless"
    elsif c_params[:sections_attributes] &&
          c_params[:sections_attributes].values.first &&
          c_params[:sections_attributes].values.first[:actual_date].blank?
      if c_params[:primary_contact_id].blank? && c_params[:user_ids].blank?
        "Unclaimed, Unscheduled"
      else
        "Claimed, Unscheduled"
      end
    else
      if c_params[:primary_contact_id].blank? && c_params[:user_ids].blank?
        "Scheduled, Unclaimed"
      else
        "Scheduled, Claimed"
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
    @course.sections = [Section.new(:course => @course)]
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

    params[:course][:status] = adjust_status(params[:course])

    # strip out empty sections
    if params.has_key?(:course) && params[:course].has_key?(:sections_attributes)
      params[:course][:sections_attributes].delete_if{|k,v| v[:requested_dates].reject(&:nil?).blank? && v[:actual_date].blank?}
    end
    @course = Course.new(params[:course])

    respond_to do |format|
      if @course.save
        unless @backdated
          @course.new_request_email
        end
        if user_signed_in?
          format.html { redirect_to summary_course_url(@course), notice: 'Class was successfully created.' }
        else
          format.html { redirect_to summary_course_url(:id => @course.id), notice: 'Class was successfully submitted for approval.' }
        end
      else
        flash.now[:error] = "Please correct the errors in the form."
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

    if params.has_key?(:course) && params[:course].has_key?(:sections_attributes)
      # strip out empty sections
      params[:course][:sections_attributes].delete_if{|k,v| v[:requested_dates].reject(&:nil?).blank? && v[:actual_date].blank? && v[:_destroy].blank?}
    end

    repo_change = false
    staff_change = false

    # Begin gross status manipulation *&!%
    if !params[:course][:repository_id].blank? && @course.repository_id != params[:course][:repository_id].to_i
      repo_change = true
    end

    if (@course.primary_contact.blank? && !params[:course][:primary_contact_id].blank?) ||
        (@course.users.blank? && !params[:course][:user_ids].blank?)
      staff_change = true
    end

    params[:course][:status] = adjust_status(params[:course])
    # End gross status manipulation

    @course.attributes = params[:course]

    if @course.save
      if params[:course][:status] == "Closed" # check params because editing closed courses should not create notes
        @course.notes.create(:note_text => "Class has marked as closed.", :user_id => current_user.id)
        if params[:send_assessment_email] == "1"
          @course.send_assessment_email
          @course.notes.create(:note_text => "Assessment email sent.", :user_id => current_user.id)
        end
      end

      if repo_change
        # FIX INFO_NEEDED Should "changed from" repos get email? Inquiring Bobbis want to know
        @course.send_repo_change_email unless @course.repository.blank?
        @course.notes.create(:note_text => "Library/Archive changed to #{@course.repository.blank? ? "none" : @course.repository.name + "Email sent"}.",
                             :user_id => current_user)
      end

      if staff_change
        # FIX INFO_NEEDED Should "dropped" staff members get this email?
        @course.send_staff_change_email(current_user)
        @course.notes.create(:note_text => "Staff change email sent.", :user_id => current_user.id)
      end
    else
      flash[:error] = "Update Error: Could not save"
      respond_to do |format|
        format.html { redirect_to :action => :edit }
        format.json { render :json => @course.errors, :status => :unprocessable_entity }
      end
    end

    respond_to do |format|
      format.html { redirect_to course_url(@course), notice: 'Class was successfully updated.' }
      format.json { head :no_content }
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

  def section_block
    display_section = params[:display_section].try(:to_i) || 1
    session_i = params[:session_i].try(:to_i) || 1
    section_index = params[:section_index].try(:to_i) || 1
    respond_to do |format|
      format.html do
        render :partial => 'shared/forms/section_block',
               :locals => { :display_section => display_section, :session_i => session_i, :section_index => section_index, :admin => current_user.can_schedule?}
      end
    end
  end


end

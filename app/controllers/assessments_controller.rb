class AssessmentsController < ApplicationController
  require 'csv'
  before_filter :authenticate_admin_or_staff!, :except => [:new, :create]

  def index
    if params[:test]
      @assessments = Assessment.where('course_id < 0').order('assessments.created_at DESC')
    else
      @assessments = Assessment.joins(:course).where('course_id > 0').order('assessments.created_at DESC').includes(:course)
    end
    @fields = {
      "staff_experience" => {
        :title => 'Reference Staff expertise',
        :slug => 'Expertise'
      },
      "staff_availability" => {
        :title => 'Reference Staff availability',
        :slug => 'Availability'
      },
      "space" => {
        :title => 'Instructional space',
        :slug => 'Space'
      },
      "request_course" => {
        :title => 'Online request system for class',
        :slug => 'CRT'
      },
      "request_materials" => {
        :title => 'Online request system for materials',
        :slug => 'Materials'
      },
      "catalogs" => {
        :title => 'Library catalogs (online catalogs of books, manuscripts, images, etc.)',
        :slug => 'Catalogs'
      },
      "digital_collections" => {
        :title => 'Digital collections',
        :slug => 'Digital Collections'
      },
      "involve_again" => {
        :title => 'Plans to involve repository again',
        :slug => 'Again?'
      },
      "created_at" => {
        :title => 'Creation Time',
        :slug => 'Date Submitted'
      }
    }
    @text_fields = {
      "not_involve_again" => {
        :title => 'Reason patron doesn\'t want to involve repository again',
        :slug => 'Why not?'
      },
      "better_future" => {
        :title => 'Suggestions for improvement',
        :slug => 'Suggestions'
      },
      "using_materials" => {
        :title => 'How using collection materials complemented teaching goals',
        :slug => 'Materials'
      },
      "involvement" => {
        :title => 'Repository involvement',
        :slug => 'Involvement'
      },
      "comments" => {
        :title => 'Comments',
        :slug => 'Comments'
      }
    }
  end

  def show
    @assessment = Assessment.find(params[:id])
    @repository_name = (@assessment.course.try(:repository).try(:name) ? @assessment.course.repository.name : 'our Library/Archive')
  end

  def new
    @assessment = Assessment.new
    @course = Course.find(params[:course_id])
    @repository_name = (@course.try(:repository).try(:name) ? @course.repository.name : 'our Library/Archive')
  end

  def edit
    @assessment = Assessment.find(params[:id])
    @repository_name = (@assessment.course.try(:repository).try(:name) ? @assessment.course.try(:repository).try(:name) : 'our Library/Archive')
  end

  def create
    params[:assessment][:involvement] = params[:assessment][:involvement].reject{ |e| e.empty? }.join(", ")
    @assessment = Assessment.new(assessment_params)
    @assessment.course = Course.find(params[:course_id])
    respond_to do |format|
      if @assessment.save
        if @assessment.course.primary_contact.blank? && @assessment.course.users.blank?
          Notification.assessment_received_to_admins(@assessment).deliver_later(:queue => 'notifications')
          flash_message :info, "Assessment receipt notification sent to admins"  unless $local_config.notifications_on? 
        else
          Notification.assessment_received_to_users(@assessment).deliver_later(:queue => 'notifications')
          flash_message :info, "Assessment receipt notification sent to users"  unless $local_config.notifications_on? 
        end
        format.html { redirect_to course_url(@assessment.course), notice: 'assessment was successfully created.' }
        format.json { render json: @assessment, status: :created, assessment: @assessment }
      else
        format.html { render action: "new" }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @assessment = Assessment.find(params[:id])
    params[:assessment][:involvement] = params[:assessment][:involvement].reject{ |e| e.empty? }.join(", ")

    respond_to do |format|
      if @assessment.update_attributes(assessment_params)
        format.html { redirect_to assessments_url, notice: 'assessment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @assessment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @assessment = Assessment.find(params[:id])
    @assessment.destroy

    respond_to do |format|
      format.html { redirect_to assessments_url }
      format.json { head :no_content }
    end
  end

  private
    def assessment_params
      params.require(:assessment).permit(
        :using_materials, 
        :involvement, 
        :staff_experience, 
        :staff_availability, 
        :space, 
        :request_materials, 
        :digital_collections, 
        :involve_again, 
        :not_involve_again, 
        :better_future, 
        :request_course, 
        :catalogs, 
        :comments
      )
    end
end

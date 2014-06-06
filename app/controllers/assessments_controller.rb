class AssessmentsController < ApplicationController
  require 'csv'
  before_filter :authenticate_admin_or_staff!, :except => [:new, :create]

  def index
    @assessments = Assessment.order('created_at DESC')
    @fields =  Assessment.attribute_names.reject do |el|
      ['id',
       'using_materials',
       'involvement',
       'comments',
       'not_involve_again',
       'created_at',
       'updated_at'].include?(el)
    end

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
    @assessment = Assessment.new(params[:assessment])
    @assessment.course = Course.find(params[:course_id])
    respond_to do |format|
      if @assessment.save
        @assessment.new_assessment_email
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
      if @assessment.update_attributes(params[:assessment])
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

  # CSV export
  def export
    @assessments = Assessment.order('created_at DESC')
    respond_to do |format|
      format.csv do
        csv = CSV.generate(:encoding => 'utf-8') do |csv|
          csv << Assessment.attribute_names
          @assessments.each do |row|
            csv << Assessment.attribute_names.map{|name| row.send name}
          end
        end
        render :text => csv
      end
    end
  end
end

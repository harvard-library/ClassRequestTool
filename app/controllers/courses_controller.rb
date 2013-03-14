class CoursesController < ApplicationController
  before_filter :authenticate_admin!, :except => [:index, :new, :create]
  
  def index
    @courses = Course.all
  end  
  
  def show
    @course = Course.find(params[:id])
  end
  
  def new
    @course = Course.new
    @uploader = FileUploader.new
  end
  
  def edit
    @course = Course.find(params[:id])
  end
  
  def create
    unless params[:other].empty?
      params[:course][:staff_involvement] = (params[:course][:staff_involvement] << params[:other]).reject{ |e| e.empty? }.join(", ")
    end  
    @course = Course.new(params[:course])
    respond_to do |format|
      if @course.save
        format.html { redirect_to courses_url, notice: 'Course was successfully created.' }
        format.json { render json: @course, status: :created, course: @course }
      else
        format.html { render action: "new" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.update_attributes(params[:course])
        format.html { redirect_to courses_url, notice: 'Course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    respond_to do |format|
      format.html { redirect_to courses_url }
      format.json { head :no_content }
    end
  end
   
end

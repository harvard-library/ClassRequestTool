class WelcomeController < ApplicationController
  before_filter :authenticate_admin_or_staff!, :only => [:dashboard]
  
  def index   
    @repositories = Repository.find(:all, :order => :name)
    @courses = Array.new
    @courses = Course.find(:all, :conditions => ["timeframe is not NULL and timeframe < ?", DateTime.now], :order => "timeframe DESC", :limit => 10)
  end  
  
  def dashboard    
    @homeless = Course.homeless
    @unscheduled_unclaimed = Course.unscheduled_unclaimed
    @scheduled_unclaimed = Course.scheduled_unclaimed
    
    @your_upcoming = current_user.upcoming_courses
    @your_past = current_user.past_courses
    @your_unscheduled = current_user.unscheduled_courses
    @your_repo_courses = current_user.upcoming_repo_courses
    @your_classes_to_close = current_user.classes_to_close
  end
  
  def dashboard_items      
    course_ids = params[:courses]
    @title = params[:title]
    unless course_ids.nil?
      @courses = Course.find(course_ids)
    end
  end
end

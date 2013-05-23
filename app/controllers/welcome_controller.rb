class WelcomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:dashboard]
  
  def index
    @repositories = Repository.find(:all, :order => :name)
    @courses = Array.new
    Course.find(:all, :order => "timeframe DESC", :limit => 10).collect{|course| !course.timeframe.nil? && course.timeframe < DateTime.now ? @courses << course : ''}
  end  
  
  def dashboard    
    @homeless = Course.homeless.paginate(:page => params[:homeless_page], :per_page => 5)
    @unassigned = Course.unassigned.paginate(:page => params[:unassigned_page], :per_page => 5)
    @roomless = Course.roomless.paginate(:page => params[:roomless_page], :per_page => 5)
    
    @your_repos = current_user.repositories.paginate(:page => params[:your_repos_page], :per_page => 5)
    @your_upcoming = current_user.upcoming_courses.paginate(:page => params[:your_upcoming_page], :per_page => 5)
    @your_past = current_user.past_courses.paginate(:page => params[:your_past_page], :per_page => 5)
  end
end

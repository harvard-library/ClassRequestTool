class WelcomeController < ApplicationController
  before_filter :authenticate_admin_or_staff!, :only => [:dashboard]
  
  def index      
    @repositories = Repository.find(:all, :order => :name)
    @courses = Array.new
    @courses = Course.find(:all, :conditions => ["timeframe is not NULL and timeframe < ?", DateTime.now], :order => "timeframe DESC", :limit => 10)
  end  
  
  def dashboard    
    @homeless = Course.homeless.paginate(:page => params[:homeless_page], :per_page => 5)
    @unscheduled_unclaimed = Course.unscheduled_unclaimed.paginate(:page => params[:unassigned_page], :per_page => 5)
    @scheduled_unclaimed = Course.scheduled_unclaimed.paginate(:page => params[:roomless_page], :per_page => 5)
    
    @your_repos = current_user.repositories.paginate(:page => params[:your_repos_page], :per_page => 5)
    @your_upcoming = current_user.upcoming_courses.paginate(:page => params[:your_upcoming_page], :per_page => 5)
    @your_past = current_user.past_courses.paginate(:page => params[:your_past_page], :per_page => 5)
    @your_unscheduled = current_user.unscheduled_courses.paginate(:page => params[:your_unscheduled_page], :per_page => 5)
    @your_repo_courses = current_user.upcoming_repo_courses.paginate(:page => params[:your_repos_page], :per_page => 5)
  end
end

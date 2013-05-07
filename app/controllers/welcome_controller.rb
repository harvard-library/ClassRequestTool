class WelcomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:dashboard]
  
  def index
    @repositories = Repository.find(:all, :order => :name)
    @courses = Array.new
    Course.find(:all, :order => "timeframe DESC", :limit => 10).collect{|course| !course.timeframe.nil? && course.timeframe < DateTime.now ? @courses << course : ''}
  end  
  
  def dashboard
    
  end
end

class WelcomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:dashboard]
  
  def index
    @repositories = Repository.find(:all, :order => :name)
    @courses = Array.new
    Course.all.collect{|course| !course.timeframe.nil? && course.timeframe < DateTime.now ? @courses << course : ''}
  end  
  
  def dashboard
    
  end
end

class WelcomeController < ApplicationController
  
  def index
    if user_signed_in?
      render "dashboard"
    else  
      @repositories = Repository.find(:all, :order => :name)
    end  
  end  
  
  def dashboard
    @repositories_all = Repository.all
    @repositories_mine = Array.new
    @repositories_all.collect {|repo| repo.users.include?(current_user) ? @repositories_mine << repo : '' }
    
    @courses_all = Course.all
    @courses_mine = Array.new
    @courses_all.collect {|course| course.users.include?(current_user) ? @courses_mine << course : '' }
  end
end

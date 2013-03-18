class WelcomeController < ApplicationController
  
  def index
    if user_signed_in?
      redirect_to dashboard_welcome_index_url
    else  
      @repositories = Repository.find(:all, :order => :name)
    end  
  end  
  
  def dashboard
    
  end
end

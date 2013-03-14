class ApplicationController < ActionController::Base
  #before_filter :authenticate_user!
  protect_from_forgery
  
  private 
  def authenticate_admin!
    if !current_user.try(:admin?)
      redirect_to(root_url)
    end  
    
  end
    
  def verify_credentials
    user_signed_in?
  end
end

class ApplicationController < ActionController::Base
  #before_filter :authenticate_user!
  protect_from_forgery
  
  def after_sign_in_path_for(user)
    cookies[:login_destination]
  end
  
  private 
  def authenticate_login!
    if !user_signed_in?
      cookies[:login_destination] = request.path
      redirect_to(login_welcome_index_url)
    end  
  end
  
  def authenticate_superadmin!
    if !current_user.try(:superadmin?)
      redirect_to(root_url)
    end  
  end
  
  def authenticate_admin!
    if !current_user.try(:admin?)
      redirect_to(root_url)
    end  
  end
  
  def authenticate_staff!
    if !current_user.try(:staff?)
      redirect_to(root_url)
    end  
  end
  
  def authenticate_admin_or_superadmin!
    if !current_user.try(:superadmin?) && !current_user.try(:admin?)
      redirect_to(root_url)
    end  
  end
  
  def authenticate_admin_or_staff!
    if !current_user.try(:superadmin?) && !current_user.try(:admin?) && !current_user.try(:staff?)
      redirect_to(root_url)
    end  
  end
    
  def verify_credentials
    user_signed_in?
  end
end

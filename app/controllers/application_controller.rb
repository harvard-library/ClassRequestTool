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
    if !current_user.superadmin?
      redirect_to(root_url)
    end  
  end
  
  def authenticate_admin!
    if !current_user.admin?
      redirect_to(root_url)
    end  
  end
  
  def authenticate_staff!
    if !current_user.staff?
      redirect_to(root_url)
    end  
  end
  
  def authenticate_admin_or_superadmin!
    if !current_user.can_admin?
      redirect_to(root_url)
    end  
  end
  
  def authenticate_admin_or_staff!
    if ! ( current_user.can_admin? || current_user.staff? )
      redirect_to(root_url)
    end  
  end
    
  def verify_credentials
    user_signed_in?
  end
end

class ApplicationController < ActionController::Base
  #before_filter :authenticate_user!

  before_filter :set_local

  protect_from_forgery

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
    if !user_signed_in?
      cookies[:login_destination] = request.path
      redirect_to(login_welcome_index_url)
    elsif ! (current_user.can_admin? || current_user.staff? )
      flash_message :danger, "You must be an admin to view that page."
      redirect_to(root_url)
    end
  end

  def verify_credentials
    user_signed_in?
  end

  def set_local
    # Set customization variables
    Thread.current['local_config'] = Customization.last || Customization.default
    $affiliates    = Affiliate.all
  end

  def flash_message(type, text)
    flash[type] ||= []
    flash[type] = text
  end

end

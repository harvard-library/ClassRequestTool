class SessionsController < ::Devise::SessionsController

  def after_sign_in_path_for(user)
    if cookies[:login_destination].nil?
      cookies[:login_destination]
    else
      root_url
    end
  end
  
  def after_sign_out_path_for(user)
    root_url
  end

end
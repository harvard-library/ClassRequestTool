class CustomFailure < Devise::FailureApp
  def redirect_url
    '/users/sign_in'
  end

  def respond
    binding.pry
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
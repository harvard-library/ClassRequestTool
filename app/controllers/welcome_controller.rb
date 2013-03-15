class WelcomeController < ApplicationController
  
  def index
    @repositories = Repository.all
  end  
end

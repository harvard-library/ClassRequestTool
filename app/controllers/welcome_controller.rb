class WelcomeController < ApplicationController
  
  def index
    @repositories = Repository.find(:all, :order => :name)
  end  
end

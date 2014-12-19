class Admin::AdminController < ApplicationController

  before_filter :admins_only
  
  def localize
    @custom = Customization.last
    @affiliates = Affiliate.all
    render 'admin/localize', :locals => { :custom => @custom, :affiliates => @affiliates }
  end

  def harvard_colors
  end
  
  private
    def admins_only
      unless current_user && (current_user.admin? || current_user.superadmin?)
        flash[:alert] = 'Sorry, only admins have permission to do that.'
        redirect_to '/'
      end
    end
end
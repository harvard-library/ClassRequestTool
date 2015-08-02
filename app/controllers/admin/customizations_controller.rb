class Admin::CustomizationsController < Admin::AdminController

  def update
    @custom = Customization.find(params[:id])
    respond_to do |format|
      if @custom.update_attributes(customization_params)
        format.html { redirect_to admin_localize_path, notice: 'Local customization was successfully updated.' }
        format.json { head :no_content }
      else
        logger.error '*** Error saving customization'
        logger.error @custom.errors.inspect
        logger.error '*** End customization save error'
        format.html { redirect_to admin_localize_path, alert: 'There was a problem saving the local customization.' }
        format.json { render json: @custom.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
    def customization_params
      params.require(:customization).permit(
        :institution,
        :institution_long,
        :tool_name,
        :slogan,
        :tool_tech_admin_name,
        :tool_tech_admin_email,
        :tool_content_admin_name,
        :tool_content_admin_email,
        :default_email_sender,
        :collaboration_options
      )
    end

end

class Admin::CustomizationsController < Admin::AdminController

  def update
    @custom = Customization.find(params[:id])
    respond_to do |format|
      if @custom.update_attributes(params[:customization])
        format.html { redirect_to admin_localize_path, notice: 'Local customization was successfully updated.' }
        format.json { head :no_content }
      else
        logger.error @custom.errors
        format.html { redirect_to admin_localize_path, alert: 'There was a problem saving the local customization.' }
        format.json { render json: @custom.errors, status: :unprocessable_entity }
      end
    end
  end
end

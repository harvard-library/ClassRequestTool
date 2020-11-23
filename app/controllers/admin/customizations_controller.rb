class Admin::CustomizationsController < Admin::AdminController

  def update
    
    # Reject empty strings in homeless attribute selections 
    # (see https://github.com/justinfrench/formtastic/issues/749)
    params[:customization][:homeless_staff_services] =
      params[:customization][:homeless_staff_services].reject{ |id| id.blank? }.map{ |s| s.to_i }
    params[:customization][:homeless_technologies] =
      params[:customization][:homeless_technologies].reject{ |id| id.blank? }.map{ |s| s.to_i}
      
    # Convert collaboration options to array
    params[:customization][:collaboration_options] =
      params[:customization][:collaboration_options].split(/\r?\n/).map(&:strip)
      
    # Remove attached image if image is blank
    if params[:customization][:attached_image_attributes][:image].nil?
      params[:customization].delete([:attached_image_attributes])
    end

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
        :welcome,
        :scheduling_intro,
        {:collaboration_options => []},
        :notifications_on,
        :homeless_staff_services => [],
        :homeless_technologies => [],
        :attached_image_attributes => [:id, :picture_id, :picture_type, :image, :image_cache, :remove_image]
      )
    end

end

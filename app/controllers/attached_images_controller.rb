class AttachedImagesController < ApplicationController
  
  def index
    @attached_images = AttachedImages.all
    render :json => @attached_images.collect { |img| img.to_jq_upload }.to_json
  end
  
  def create
    @attached_image = AttachedImage.new(attached_image_params)
    
    # if the image doesn't exist, fail silently
    if @attached_image.image.blank?
      render :nothing => true
    end
    if @attached_image.save
      respond_to do |format|
        format.html {
          render :json => [@attached_iamge.to_jq_upload].to_json,
          :content_type => 'text/html',
          :layout => false
        }
        format.json {
          render :json => [@attached_iamge.to_jq_upload].to_json
        }
      end
    else
      render :json => [{:error => "custom_failure"}], :status => 304
    end
  end
  
  def destroy
    @attached_image = AttachedImage.find(params[:id])
    @attached_image.destroy
    render :json => true
  end
  
  private
    def attached_image_params
      params.require(:attached_image).permit(:picture_id, :picture_type, :image, :image_cache, :remove_image, :caption)
    end
end
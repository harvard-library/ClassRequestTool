class Admin::CustomTextsController < ApplicationController
  before_action :require_superadmin
  
  def index
    @custom_texts = Admin::CustomText.all
  end
  
  def create
    @custom_text = Admin::CustomText.new(custom_text_params)
    
    if @custom_text.save
      respond_to do |format|
        format.html do
          render :partial => 'table_row', locals: { custom_text:  @custom_text }
#        format.json { render json: @custom_text }
        end
      end
    else
      respond_to do |format|
        format.json { render :nothing, status: 400 }
      end
    end
  end
  
  def update
    @custom_text = Admin::CustomText.find(params[:id])
    
    if @custom_text.update_attributes(custom_text_params)
      respond_to do |format|
        format.json { render json: @custom_text }
      end
    else
      respond_to do|format|
        format.json { render :nothing, status: 400 }
      end
    end      
  end
  
  def destroy
    @custom_text = Admin::CustomText.find(params[:id])
    
    @custom_text.destroy

    respond_to do |format|
      format.json { head :no_content }
    end
  end
    
  
  private
    def require_superadmin
      redirect_to :root, alert: "You're not authorized to see that." unless current_user.superadmin?
    end
    def custom_text_params
      params.require(:custom_text).permit(:key, :text)
    end
end

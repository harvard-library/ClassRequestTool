class Admin::AffiliatesController < Admin::AdminController

  def create
    @affiliate = Affiliate.new(params[:affiliate])
    
    if @affiliate.save
      render :json => @affiliate.to_json
    else
      render json: @affiliate.errors, status: :unprocessable_entity
    end 
  end
  
  def update
    @affiliate = Affiliate.find(params[:id])
    
    if @affiliate.update_attributes(params[:affiliate])
      render :json => @affiliate.to_json
    else
      render json: @affiliate.errors, status: :unprocessable_entity
    end
  end
  
  def destroy
    @affiliate = Affiliate.find(params[:id])
    @affiliate.destroy

    render :json => true
  end
end
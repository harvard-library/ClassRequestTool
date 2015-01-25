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
  
  def update_positions
    @affiliates = Affiliate.all
    @affiliates.each do |a|
      a.position = params["affiliate-#{a.id}"]
      unless a.save
        render json: { status: 'error', msg: 'There was a problem updating the affiliate order.' }
        return       
      end
    end
    render json: { status: 'success', msg: 'The affiliate order was successfully updated.' }
  end
  
  def destroy
    @affiliate = Affiliate.find(params[:id])
    @affiliate.destroy

    render :json => true
  end
end
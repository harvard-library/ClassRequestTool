class Admin::AffiliatesController < Admin::AdminController

  def create
    @affiliate = Affiliate.new(affiliate_params)
    
    if @affiliate.save
      render :json => @affiliate.to_json
    else
      render json: @affiliate.errors, status: :unprocessable_entity
    end 
  end
  
  def update
    @affiliate = Affiliate.find(affiliate_params[:id])
    
    if @affiliate.update_attributes(affiliate_params)
      render :json => @affiliate.to_json
    else
      render json: @affiliate.errors, status: :unprocessable_entity
    end
  end
  
  def update_positions
    @affiliates = Affiliate.all
    af_params = affiliate_params  # we do this to just process the params once
    @affiliates.each do |a|
      a.position = af_params["affiliate-#{a.id}"]
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
  
  private
  def affiliate_params
    af_params = {}
    if params.has_key? 'affiliate'
      af_params = params.require(:affiliate).permit(:name,:url, :description, :id)
    end
    # because the ordering update requires additional parameters we have an additional step
    # looking for parameters of the type affiliates[affiliate-\d+]
    if params.has_key? 'affiliates'
      pas = params[:affiliates]
      pas.each do |k,a|
        if ( k =~ /^affiliate-\d+$/ )
          af_params[k] = a
        end
      end
    end
    af_params
  end

end

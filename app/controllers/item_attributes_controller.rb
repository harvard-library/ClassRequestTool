class ItemAttributesController < ApplicationController
  before_filter :authenticate_superadmin!, :only => [:destroy]
  before_filter :authenticate_admin_or_superadmin!, :except => [:index]
  before_filter :authenticate_admin_or_staff!
  
  def index
    @attributes = ItemAttribute.order('name')
  end  
  
  def new
    @attribute = ItemAttribute.new
  end
  
  def edit
    @attribute = ItemAttribute.find(params[:id])
  end
  
  def create
    @attribute = ItemAttribute.new(item_attribute_params)
    respond_to do |format|
      if @attribute.save
        format.html { redirect_to item_attributes_url, notice: 'Item Attribute was successfully created.' }
        format.json { render json: @attribute, status: :created, attribute: @attribute }
      else
        format.html { render action: "new" }
        format.json { render json: @attribute.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @attribute = ItemAttribute.find(params[:id])

    respond_to do |format|
      if @attribute.update_attributes(item_attribute_params)
        format.html { redirect_to item_attributes_url, notice: 'Item Attribute was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @attribute.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @attribute = ItemAttribute.find(params[:id])
    @attribute.destroy

    respond_to do |format|
      format.html { redirect_to item_attributes_url }
      format.json { head :no_content }
    end
  end

  private
    def item_attribute_params
      params.require(:item_attribute).permit(:name, :description, :room_ids, :repository_ids)
    end
end

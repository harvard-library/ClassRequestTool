class RoomsController < ApplicationController
  before_action :authenticate_superadmin!, :only => [:destroy]
  before_action :authenticate_admin_or_superadmin!, :except => [:index]
  before_action :authenticate_admin_or_staff!
  
  def index
    @rooms = Room.order('name').includes(:repositories, :item_attributes)
  end  
  
  def new
    @room = Room.new
  end
  
  def edit
    @room = Room.find(params[:id])
  end
  
  def create
    @room = Room.new(room_params)
    respond_to do |format|
      if @room.save
        format.html { redirect_to rooms_url, notice: 'Room was successfully created.' }
        format.json { render json: @room, status: :created, room: @room }
      else
        format.html { render action: "new" }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @room = Room.find(params[:id])

    respond_to do |format|
      if @room.update_attributes(room_params)
        format.html { redirect_to rooms_url, notice: 'Room was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @room.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @room = Room.find(params[:id])
    @room.destroy

    respond_to do |format|
      format.html { redirect_to rooms_url }
      format.json { head :no_content }
    end
  end

  private
    def room_params
      rm_params = params.require(:room).permit(:name, {:repository_ids => []}, {:item_attribute_ids => []}, :class_limit)
      rm_params
    end
end

class StaffServicesController < ApplicationController
  before_filter :authenticate_superadmin!, :only => [:destroy]
  before_filter :authenticate_admin_or_superadmin!, :except => [:index]
  before_filter :authenticate_admin_or_staff!
  
  def index
    @staff_services = StaffService.order('description').includes(:repositories)
  end  
  
  def new
    @staff_service = StaffService.new
  end
  
  def edit
    @staff_service = StaffService.find(params[:id])
  end
  
  def create
    @staff_service = StaffService.new(params[:staff_service])
    respond_to do |format|
      if @staff_service.save
        format.html { redirect_to staff_services_url, notice: 'Staff Service was successfully created.' }
        format.json { render json: @staff_service, status: :created, staff_service: @staff_service }
      else
        format.html { render action: "new" }
        format.json { render json: @staff_service.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @staff_service = StaffService.find(params[:id])

    respond_to do |format|
      if @staff_service.update_attributes(params[:staff_service])
        format.html { redirect_to staff_services_url, notice: 'Staff Service was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @staff_service.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @staff_service = StaffService.find(params[:id])
    @staff_service.destroy

    respond_to do |format|
      format.html { redirect_to staff_services_url }
      format.json { head :no_content }
    end
  end
end

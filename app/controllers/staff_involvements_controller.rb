class StaffInvolvementsController < ApplicationController
  before_filter :authenticate_superadmin!, :only => [:destroy]
  before_filter :authenticate_admin_or_superadmin!, :except => [:index]
  before_filter :authenticate_admin_or_staff!
  
  def index
    @staff_involvements = StaffInvolvement.order('involvement_text')
  end  
  
  def new
    @staff_involvement = StaffInvolvement.new
  end
  
  def edit
    @staff_involvement = StaffInvolvement.find(params[:id])
  end
  
  def create
    @staff_involvement = StaffInvolvement.new(params[:staff_involvement])
    respond_to do |format|
      if @staff_involvement.save
        format.html { redirect_to staff_involvements_url, notice: 'StaffInvolvement was successfully created.' }
        format.json { render json: @staff_involvement, status: :created, staff_involvement: @staff_involvement }
      else
        format.html { render action: "new" }
        format.json { render json: @staff_involvement.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @staff_involvement = StaffInvolvement.find(params[:id])

    respond_to do |format|
      if @staff_involvement.update_attributes(params[:staff_involvement])
        format.html { redirect_to staff_involvements_url, notice: 'StaffInvolvement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @staff_involvement.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @staff_involvement = StaffInvolvement.find(params[:id])
    @staff_involvement.destroy

    respond_to do |format|
      format.html { redirect_to staff_involvements_url }
      format.json { head :no_content }
    end
  end
end

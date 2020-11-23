class RepositoriesController < ApplicationController
  before_action :authenticate_superadmin!, :only => [:destroy]
  before_action :authenticate_admin_or_staff!, :except => [:index, :show]

  def index
    @repositories = Repository.order('name')
  end

  def show
    @repository = Repository.includes(:collections).find(params[:id])
    @recent_courses = Course.where( repository_id: @repository.id ).past.order_by_last_date.limit(3)
  end

  def new
    @repository = Repository.new
  end

  def edit
    @repository = Repository.find(params[:id])
  end

  def create
    @repository = Repository.new(repository_params)
    respond_to do |format|
      if @repository.save
        format.html { redirect_to repositories_url, notice: 'Library/Archive was successfully created.' }
        format.json { render json: @repository, status: :created, location: @repository }
      else
        format.html { render action: "new" }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @repository = Repository.find(params[:id])
    
    respond_to do |format|
      if @repository.update_attributes(repository_params)
        format.html { redirect_to repository_path(@repository), notice: 'Library/Archive was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @repository.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @repository = Repository.find(params[:id])
    @repository.destroy

    respond_to do |format|
      format.html { redirect_to repositories_url }
      format.json { head :no_content }
    end
  end
  
  def staff
    if params[:id].blank?
      staff_members = User.all_admins.order("last_name ASC")
    else
      staff_members = Repository.find(params[:id]).users.order("last_name ASC")
    end
    
    respond_to do |format|
      format.html { render partial: 'repositories/staff_list', locals: { form: params[:form], assigned_staff: [], staff_members: staff_members }}
      format.json { render json: staff_members }
    end
  end
  
  def staff_services
    unless params[:id].blank?
      all_staff_services = Repository.find(params[:id]).all_staff_services
    end

    respond_to do |format|
      format.html { render partial: 'repositories/staff_services', locals: { staff_services: [], all_staff_services: all_staff_services }}
      format.json { render json: all_staff_services }
    end      
  end
  
  def all_technologies
    unless params[:id].blank?
      @all_technologies = Repository.find(params[:id]).item_attributes
    end

    respond_to do |format|
      format.html { render partial: 'repositories/technologies', locals: { technologies: [], all_technologies: @all_technologies }}
      format.json { render json: all_staff_services }
    end      
  end

  private
    def repository_params
      params.require(:repository).permit(
        :name, :description, :can_edit, :class_limit, {:room_ids => []}, {:user_ids => []}, {:item_attribute_ids => []}, :email_details,
        :calendar, :landing_page, :class_policies, 
        {:attached_images_attributes => [:id, :_destroy, :picture_id, :picture_type, :image, :image_cache, :remove_image, :caption, :featured]}, 
        :collections_attributes => [:id, :_destroy,:name, :description, :url, :repository_id]  
      )
    end
end

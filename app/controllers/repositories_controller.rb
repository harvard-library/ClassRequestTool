class RepositoriesController < ApplicationController
  before_filter :authenticate_admin!, :except => [:index, :show]
  
  def index
    @repositories = Repository.order('name').paginate(:page => params[:page], :per_page => 50)
  end  
  
  def show
    @repository = Repository.find(params[:id])
  end
  
  def new
    @repository = Repository.new
  end
  
  def edit
    @repository = Repository.find(params[:id])
  end
  
  def create
    @repository = Repository.new(params[:repository])
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
      if @repository.update_attributes(params[:repository])
        format.html { redirect_to repositories_url, notice: 'Library/Archive was successfully updated.' }
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
end

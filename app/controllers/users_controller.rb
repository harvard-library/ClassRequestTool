class UsersController < ApplicationController
  before_filter :authenticate_admin!, :except => [:edit, :update]
  before_filter :authenticate_admin_or_staff!
  
  def index
    @users = User.order('email').paginate(:page => params[:page], :per_page => 50)
  end
  
  def new
    @user = User.new
  end
  
  def create
    admin = params[:user][:admin]
    staff = params[:user][:staff]
    patron = params[:user][:patron]
    params[:user] = params[:user].delete_if{|key, value| key == "admin" || key == "staff" || key == "patron" }
    @user = User.new(params[:user])
    @user.password = User.random_password
    admin == "1" ? @user.admin = true : @user.admin = false
    staff == "1" ? @user.staff = true : @user.staff = false
    patron == "1" ? @user.patron = true : @user.patron = false
    respond_to do|format|
      if @user.save
        flash[:notice] = 'Added that User'
        format.html {redirect_to :action => :index}
      else
        flash[:error] = 'Could not add that User'
        format.html {render :action => :new}
      end
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    
    unless current_user.try(:admin?) || @user.email == current_user.email
       redirect_to('/') and return
    end
  end

  def destroy
    @user = User.find(params[:id])
    
    unless current_user.try(:admin?) || @user.email == current_user.email
       redirect_to('/') and return
    end
    
    user = @user.email
    if @user.destroy
      flash[:notice] = %Q|Deleted user #{user}|
      redirect_to :action => :index
    else

    end
  end

  def update
    @user = User.find(params[:id])
    unless current_user.try(:admin?) || @user.email == current_user.email
       redirect_to('/') and return
    end
    admin = params[:user][:admin]
    staff = params[:user][:staff]
    patron = params[:user][:patron]
    params[:user] = params[:user].delete_if{|key, value| key == "admin" || key == "staff" || key == "patron" }
    @user.attributes = params[:user]
    admin == "1" ? @user.admin = true : @user.admin = false
    staff == "1" ? @user.staff = true : @user.staff = false
    patron == "1" ? @user.patron = true : @user.patron = false
    respond_to do|format|
      if @user.save
        flash[:notice] = %Q|#{@user} updated|
        format.html {redirect_to :action => :index}
      else
        flash[:error] = 'Could not update that User'
        format.html {render :action => :new}
      end
    end
  end
end

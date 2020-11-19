class UsersController < ApplicationController
  before_action :authenticate_admin_or_staff!, :only => [:edit, :update]
  
  def index
    @users = User.order('username')
  end
  
  def new
    @user = User.new
    
    @options = ["Choose One...", "Admin", "Staff", "Patron"]
    @options_super = ["Choose One...", "Superadmin", "Admin", "Staff", "Patron"]
  end
  
  def create
    case params[:role]
      when "Superadmin"
        superadmin = true
      when "Admin"
        admin = true
      when "Staff"  
        staff = true
      when "Patron"  
        patron = true
    end
    
    params[:user] = params[:user].delete_if{|key, value| key == "superadmin" || key == "admin" || key == "staff" || key == "patron" }
    @user = User.new(user_params)
    @user.password = User.random_password
    
    superadmin ? @user.superadmin = true : @user.superadmin = false
    admin ? @user.admin = true : @user.admin = false
    staff ? @user.staff = true : @user.staff = false
    patron ? @user.patron = true : @user.patron = false
    
    respond_to do|format|
      if @user.save
        flash_message :info, 'Added that User'
        format.html {redirect_to :action => :index}
      else
        flash_message :danger, 'Could not add that User'
        format.html {render :action => :new}
      end
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @options = ["Choose One...", "Admin", "Staff", "Patron"]
    @options_super = ["Choose One...", "Superadmin", "Admin", "Staff", "Patron"]
    
    if @user.superadmin?
      @selected = "Superadmin"
    elsif @user.admin?
      @selected = "Admin"
    elsif @user.staff?
      @selected = "Staff"
    elsif @user.patron?
      @selected = "Patron"
    end
    
    unless current_user.can_admin? || @user.email == current_user.email
       redirect_to('/') and return
    end
  end

  def destroy
    @user = User.find(params[:id])
    
    unless current_user.superadmin? || @user.email == current_user.email
       redirect_to('/') and return
    end
    
    user = @user.email
    if @user.destroy
      flash_message :info, %Q|Deleted user #{user}|
      redirect_to :action => :index
    else

    end
  end

  def update
    @user = User.find(params[:id])
    unless current_user.can_admin? || @user.email == current_user.email
       redirect_to('/') and return
    end

    case params[:role]
      when "Superadmin"
        superadmin = true
      when "Admin"
        admin = true
      when "Staff"  
        staff = true
      when "Patron"  
        patron = true
    end
      
    params[:user] = params[:user].delete_if{|key, value| key == "superadmin" || key == "admin" || key == "staff" || key == "patron" }
    @user.attributes = user_params
    
    superadmin ? @user.superadmin = true : @user.superadmin = false
    admin ? @user.admin = true : @user.admin = false
    staff ? @user.staff = true : @user.staff = false
    patron ? @user.patron = true : @user.patron = false
    
    respond_to do|format|
      if @user.save
        flash_message :info, %Q|#{@user} updated|
        format.html {redirect_to :action => :index}
      else
        flash_message :danger, 'Could not update that User'
        format.html {render :action => :new}
      end
    end
  end
  
  private
    def user_params
      params.require(:user).permit(:email, :password, :first_name, :last_name, :username, :pinuser, :admin, :superadmin, 
                                   :staff, :patron, :repository_ids =>[])
    end
end

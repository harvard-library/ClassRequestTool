class WelcomeController < ApplicationController
  before_filter :authenticate_admin_or_staff!, :only => [:dashboard]
  before_filter :prevent_caching, :only => [:show]

  def show
    @repositories = Repository.order(:name)
    @courses = Course.with_status('Closed').past.limit(5).order_by_last_date
    @featured_image = AttachedImage.where(:featured => true, :picture_type => 'Repository').sample
    if @featured_image.blank?
      @featured_image = AttachedImage.new
      @featured_image.caption = "No image available"
    else
      @featured_repository = @featured_image.owner
    end
  end

  def dashboard
    @homeless               = []
    @unscheduled_unclaimed  = []
    @scheduled_unclaimed    = []
    @user_upcoming          = []
    @user_past              = []
    @user_unscheduled       = []
    @user_repo_courses      = []
    @user_to_close          = []
    
    @homeless = Course.select(%Q(id, title, repository_id, scheduled, primary_contact_id, first_date, last_date, status)) \
      .homeless \
      .order_by_submitted.includes(:repository, :sections)
      
    claimed = Course.select(%Q(id, title, repository_id, scheduled, primary_contact_id, first_date, last_date, status)) \
      .where(:primary_contact_id => !nil) \
      .order_by_submitted \
      .includes(:repository, :sections, :users)
      
    if current_user.admin?
      unclaimed =  Course.select(%Q(id, title, repository_id, scheduled, primary_contact_id, first_date, last_date, status)) \
        .housed.with_status('Active') \
        .where(:primary_contact_id => nil) \
        .order_by_submitted \
        .includes(:repository, :sections, :users)
    else   
      unclaimed =  Course.select(%Q(id, title, repository_id, scheduled, primary_contact_id, first_date, last_date, status)) \
        .housed.with_status('Active') \
        .order_by_submitted \
        .includes(:repository, :sections, :users)
    end
 
    unclaimed.each do |c|
      if c.scheduled?
        @scheduled_unclaimed   << c
      else 
        @unscheduled_unclaimed << c
      end
    end
    
    claimed.each do |c|
      if c.status == 'Active'
        if c.scheduled?
          if c.first_date > DateTime.now
            @user_upcoming << c
          elsif c.last_date < DateTime.now
            @user_to_close << c
          end
        else
          @user_unscheduled << c if c.primary_contact
        end
      elsif c.status == 'Closed'
        @user_past << c
      end
    end
  end 
  
  private
    def prevent_caching
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"    
    end 
end

class WelcomeController < ApplicationController
  before_filter :authenticate_admin_or_staff!, :only => [:dashboard]

  def show
    @repositories = Repository.order(:name)
    @courses = Course.with_status('Closed').past.limit(10).order_by_last_date
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
    
    Course.select(%Q(id, title, created_at, repository_id, scheduled, primary_contact_id, first_date, last_date, status))
          .order_by_submitted
          .includes(:repository, :sections).each do |c|
      @homeless               << c if c.homeless?
      @unscheduled_unclaimed  << c if !( c.scheduled? || c.claimed? )
      @scheduled_unclaimed    << c if  ( c.scheduled? || !c.claimed? )
      @user_upcoming          << c if  ( c.primary_contact_id == current_user.id &&
                                         c.scheduled?                          && 
                                         c.claimed?                            &&
                                         c.first_date > DateTime.now
                                       )
      @user_past              << c if ( c.primary_contact_id == current_user.id && c.status == 'Closed' )     
      @user_unscheduled       << c if ( c.primary_contact_id == current_user.id && !c.scheduled? )                                  
      @user_repo_courses      << c if ( !c.homeless? && c.repository.user_ids.include?(current_user.id) )
      @user_to_close          << c if ( c.primary_contact_id == current_user.id &&
                                        c.status == 'Active' &&
                                        c.last_date < DateTime.now
                                      )
    end
  end  
end

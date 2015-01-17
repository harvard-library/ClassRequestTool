class WelcomeController < ApplicationController
  before_filter :authenticate_admin_or_staff!, :only => [:dashboard]

  def index
    @repositories = Repository.order(:name)
    @courses = Course.with_status('Closed').past.limit(10).order_by_last_date
  end

  def dashboard
    @homeless               = []
    @unscheduled_unclaimed  = []
    @scheduled_unclaimed    = []
    @your_upcoming          = []
    @your_past              = []
    @your_unscheduled       = []
    @your_repo_courses      = []
    @your_classes_to_close  = []
    
    Course.order_by_last_date.includes(:repository, :sections).each do |c|
      @homeless               << c if c.homeless?
      @unscheduled_unclaimed  << c if !( c.scheduled? || c.claimed? )
      @scheduled_unclaimed    << c if  ( c.scheduled? || !c.claimed? )
      @your_upcoming          << c if  ( c.primary_contact_id == current_user.id &&
                                         c.scheduled?                          && 
                                         c.claimed?                            &&
                                         c.last_date > DateTime.now
                                       )
      @your_past              << c if ( c.primary_contact_id == current_user.id && c.status == 'Closed' )     
      @your_unscheduled       << c if ( c.primary_contact_id == current_user.id && !c.scheduled? )                                  
      @your_repo_courses      << c if ( !c.repository.nil? && c.repository.user_ids.include?(current_user.id) )
      @your_classes_to_close  << c if ( c.primary_contact_id == current_user.id &&
                                        c.status == 'Active' &&
                                        c.last_date < DateTime.now
                                      )
    end
  end  
end

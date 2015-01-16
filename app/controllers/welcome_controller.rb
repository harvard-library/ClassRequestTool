class WelcomeController < ApplicationController
  before_filter :authenticate_admin_or_staff!, :only => [:dashboard]

  def index
    @repositories = Repository.order(:name)
    @courses = Course.with_status('Closed').past.limit(10).order_by_last_date
  end

  def dashboard
    @homeless = Course.homeless
    @unscheduled_unclaimed = Course.unscheduled.unclaimed
    @scheduled_unclaimed = Course.scheduled.unclaimed

    @your_upcoming         = Course.user_is_primary_staff(current_user.id).scheduled.claimed.upcoming
    @your_past             = Course.user_is_primary_staff(current_user.id).with_status('Closed').order_by_last_date
    @your_unscheduled      = Course.user_is_primary_staff(current_user.id).scheduled.unclaimed.upcoming.order_by_last_date
    @your_repo_courses     = Course.user_is_primary_staff(current_user.id).upcoming.order_by_last_date
    @your_classes_to_close = Course.user_is_primary_staff(current_user.id).with_status('Active').past
  end  
end

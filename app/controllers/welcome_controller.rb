class WelcomeController < ApplicationController
  before_filter :authenticate_admin_or_staff!, :only => [:dashboard]

  def index
    @repositories = Repository.order(:name)
    @courses = Course.
      where(:status => 'Closed').
      having("MAX(actual_date) IS NOT NULL AND MAX(actual_date) < ?", DateTime.now).
      limit(10).
      ordered_by_last_section
  end

  def dashboard
    @homeless = Course.homeless
    @unscheduled_unclaimed = Course.unscheduled.unclaimed
    @scheduled_unclaimed = Course.scheduled.unclaimed

    @your_upcoming         = Course.user_is_primary_staff(current_user.id).scheduled.claimed.upcoming
    @your_past             = Course.user_is_primary_staff(current_user.id).with_status('Closed').ordered_by_last_section
    @your_unscheduled      = Course.user_is_primary_staff(current_user.id).scheduled.unclaimed.upcoming.ordered_by_last_section
    @your_repo_courses     = Course.user_is_primary_staff(current_user.id).upcoming.ordered_by_last_section
    @your_classes_to_close = Course.user_is_primary_staff(current_user.id).with_status('Active').past
  end  
end

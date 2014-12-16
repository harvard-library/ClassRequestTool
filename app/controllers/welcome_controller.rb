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

    @your_upcoming = current_user.courses.scheduled.upcoming
    @your_past = current_user.courses.with_status('Closed')
    @your_unscheduled = current_user.courses.unscheduled
    @your_repo_courses = current_user.repositories.courses.upcoming
    @your_classes_to_close = current_user.courses.with_status('Active').past
  end

end

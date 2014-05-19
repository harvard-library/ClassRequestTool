class WelcomeController < ApplicationController
  before_filter :authenticate_admin_or_staff!, :only => [:dashboard]

  def index
    @repositories = Repository.order(:name)
    @courses = Course.select('courses.*, MAX(actual_date) AS maxdate').
      joins('LEFT OUTER JOIN sections ON sections.course_id = courses.id').
      where(:status => 'Closed').
      group('courses.id').
      having("MAX(actual_date) IS NOT NULL AND MAX(actual_date) < ?", DateTime.now).
      order('maxdate DESC NULLS LAST').limit(10)
  end

  def dashboard
    @homeless = Course.homeless
    @unscheduled_unclaimed = Course.unscheduled_unclaimed
    @scheduled_unclaimed = Course.scheduled_unclaimed

    @your_upcoming = current_user.upcoming_courses
    @your_past = current_user.past_courses
    @your_unscheduled = current_user.unscheduled_courses
    @your_repo_courses = current_user.upcoming_repo_courses
    @your_classes_to_close = current_user.classes_to_close
  end

  def dashboard_items
    course_ids = params[:courses]
    @title = params[:title]
    unless course_ids.nil?
      @courses = Course.find(course_ids)
    end
  end
end

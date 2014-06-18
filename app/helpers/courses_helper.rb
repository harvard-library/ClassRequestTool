module CoursesHelper
  def display_with_tz(date)
    date
      .try(:in_time_zone, Rails.configuration.time_zone)
      .try(:strftime, "%Y-%m-%d %I:%M %P")
  end
end

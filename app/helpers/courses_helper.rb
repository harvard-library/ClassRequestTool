module CoursesHelper
  def display_with_tz(date)
    date
      .try(:in_time_zone, Rails.configuration.time_zone)
      .try(:strftime, "%Y-%m-%d %I:%M %P")
  end

  def searchable_fields(course)
    course.attributes.values_at("comments", "goal", "title", "subject", "affiliation", "course_number", "contact_first_name", "contact_last_name").reject(&:blank?).join(' ')
  end

end

module CoursesHelper
  def display_with_tz(date)
    date
      .try(:in_time_zone, Rails.configuration.time_zone)
      .try(:strftime, "%Y-%m-%d %I:%M %P")
  end

  def searchable_fields(course)
    course.attributes.values_at("comments", "goal", "title", "subject", "affiliation", "course_number", "contact_first_name", "contact_last_name").reject(&:blank?).join(' ')
  end
  
  def full_status(course)
    if 'Active' == course.status
      if course.homeless?
        status = "<span class='status danger'>Homeless</span>"
      else
        stat_array = [course.claimed? ? 'Claimed' : 'Unclaimed']
        stat_array << (course.scheduled? ? 'Scheduled' : 'Unscheduled')
        status = "<span class='status #{(course.claimed? && course.scheduled?) ? '' : 'warning'}'>#{stat_array.join(', ')}</span>"
      end
    else
      status = "<span class='status inactive'>#{course.status}</span>"
    end
    status.html_safe
  end

end

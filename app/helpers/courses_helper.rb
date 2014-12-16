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
    status = []
    if 'Active' == course.status
      if course.homeless?
        status << "<span class='status danger'>Homeless</span>"
      end
      status << "<span class='status #{course.claimed? ? '' : 'warning'}'>#{course.claimed? ? 'Claimed' : 'Unclaimed'}</span>"
      status << "<span class='status #{course.scheduled? ? '' : 'warning'}'>#{course.scheduled? ? 'Scheduled' : 'Unscheduled'}</span>"
    else
      status << "<span class='status inactive'>#{course.status}</span>"
    end
    status.join("<br />\n").html_safe
  end

end

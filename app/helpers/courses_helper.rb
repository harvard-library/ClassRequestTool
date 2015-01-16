module CoursesHelper

  def formtastic_wrapper(type, label, input_tag)
    id = /id="([a-z_0-9]*)"/.match(input_tag)[1]
    wrapper_id = "#{id}_input"
    type += ' numeric' if type == 'number'
    wrapper_class = "#{type} input stringish optional form-group"
    label = "<label class=' control-label' for='#{id}'>#{label}</label>"
    label_class = 'control-label'
    "<div id='#{wrapper_id}' class='#{wrapper_class}'>#{label}<span class='form-wrapper'>" + input_tag + "</span></div>"
  end
  
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
  
  # Sorts sections based first on actual date, then first requested date
  def sort_sections(sections, direction = 'ASC')
    unless sections.map { |section| section.actual_date.blank? }.include?(true)
      sections.sort! { |a, b| a.actual_date <=> b.actual_date }
    end
    sections.sort! { |a, b| a.requested_dates[0] <=> b.requested_dates[0] }
  end
  
  def date_range(course)
    if course.first_date.blank?
      range = '(Not set)'
    else 
      range = course.first_date.strftime('%m/%d/%Y')
    end
    
    unless course.last_date.blank? || (course.last_date == course.first_date)
      range += "&mdash;#{course.last_date.strftime('%m/%d/%Y')}"
    end
    range
  end
  
  def upcoming_or_past(date)
    if date.nil?
      "<span class='glyphicon glyphicon-minus-sign nil'></span>"
    else
      "<span class='glyphicon #{date > DateTime.now ? 'glyphicon-arrow-up upcoming' : 'glyphicon-arrow-down past'}'></span>"
    end
  end
end

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
      .try(:strftime, DATETIME_AT_FORMAT)
  end

  def searchable_fields(course)
    strip_tags(course.attributes.values_at("comments", "goal", "title", "subject", "affiliation", "course_number", "contact_first_name", "contact_last_name", "assisting_repository", "additional_patrons").reject(&:blank?).join(' ')).downcase.gsub(/[^a-z0-9\s]/i, '')
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
      range = course.first_date.strftime(DATE_FORMAT)
    end
    
    unless course.last_date.blank? || (course.last_date == course.first_date)
      range += "&mdash;#{course.last_date.strftime(DATE_FORMAT)}"
    end
    range
  end
  
  def status_class(status)
    case status
      when 'Active'
        'success'
      when 'Closed'
        'danger'
      when 'Cancelled'
        'info'
      else
        'warning'
      end
  end
  
  def upcoming_or_past(date)
    if date.nil?
      "<span class='glyphicon glyphicon-minus-sign nil'></span>"
    else
      "<span class='glyphicon #{date > DateTime.now ? 'glyphicon-upload upcoming' : 'glyphicon-download past'}'></span>"
    end
  end
  
  def scheduling_status(sections)
    return "<span class='status danger'>No sections!</span>" if sections.blank?
    
    all_scheduled = true
    no_request = false
    sections.each do |s|
      if s.actual_date.blank?
        all_scheduled = false
      end
      
      if s.requested_dates.blank?
        no_request = true
      end      
    end
    if all_scheduled
      "<span>Scheduled</span>"
    elsif no_request
      "<span class='status warning'>No date requested</span>"
    else
      "<span class='status warning'>Unscheduled</span>"
    end
  end
  
  def first_class(course)
    course.first_date.blank? ? '' :  course.first_date.strftime(SORTTIME_FORMAT)
  end
  
  def first_plus_multiple_sections(course)
    if course.sections.nil?
      return "<div class='alert alert-danger'>No sections!</div>"
    end
    multiple_sections = []
    scheduled_sections = course.sections.reject { |s| s.actual_date.blank? }
    scheduled_sections.sort_by!{ |s| [s.session, s.actual_date]  }

    # Always list first scheduled section date
    meeting_time = course.first_date.blank? ? '' :  course.first_date.strftime(DATETIME_AT_FORMAT)
    html = "<span class='time'>#{meeting_time}</span>"
    if meeting_time.blank?
      html += " <span class='status danger'>No dates</span>"
    end
    if scheduled_sections.count > 1
      html += ' <br /><span class="glyphicon glyphicon-th-list" '
      scheduled_sections.each do |s|
        multiple_sections << "<li class='list-group-item'>Session #{s.session}: #{s.actual_date.strftime(DATETIME_AT_FORMAT)}</li>"
      end
      html += "data-section_list=\"<ul class='list-group'>\n#{multiple_sections.join("\n")}\n</ul>\"></span>\n"
    end
    if course.sections.count > 1 && (course.sections.count - scheduled_sections.count > 0) 
      html += "<div class='alert alert-warning'>#{pluralize(course.sections.count - scheduled_sections.count, 'section')} of #{course.sections.count} unscheduled</div>"
    end
    html
  end  
end

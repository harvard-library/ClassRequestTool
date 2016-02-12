module ApplicationHelper
  def handle_empty( x, alt = '(None)' )
    if x.class == Array
      x.empty? ? [alt] : x
    elsif x.class == String
      x.blank? ? alt : x
    elsif x.class == Integer
      x.nil? || x == 0 ?  alt : x
    end      
  end
  
  def page_title(controller)
    subject = case controller.controller_name
      when 'admin'
        'Administration'
      when 'assessments'
        'Assessment'
      when 'courses'
        'Class'
      when 'item_attributes'
        'Technology'
      when 'repositories'
        'Library/Archive'
      when 'rooms'
        'Room'
      when 'staff_services'
        'Staff Service'
      when 'users'
        'User'
      when 'welcome'
        'Welcome'
      end
    case controller.action_name
    when  'index'
      "#{subject} List"
    when 'new'
      "New #{subject}"
    when 'show'
      subject
    when 'update'
      "Update #{subject}"
    when 'dashboard'
      "#{subject} Dashboard"
    end  
  end
  
  def photo_credit(source)
  
    if source.is_a? Repository
      "From the <a href='#{repository_path(source)}'>#{source.name}</a>"
      
    elsif source.is_a? String
      "Credit: #{source}"
        
    elsif source.respond_to? :to_s
      "Credit: #{source.to_s}"
    else
      ''
    end
  end
  
  def site_url
    config = Rails.configuration.action_mailer[:default_url_options]
    if config[:port].blank?
      config[:host]
    else
      "#{config[:host]}:#{config[:port]}"
    end
  end
  
  def test_mail_recipient
    return nil unless defined?(MAIL_RECIPIENT_OVERRIDE)
    
    if MAIL_RECIPIENT_OVERRIDE.kind_of? Array
      retval = MAIL_RECIPIENT_OVERRIDE.join(', ')
    else
      retval = MAIL_RECIPIENT_OVERRIDE
    end
    retval
  end
  
  def repository_list
    Repository.all.order(:name => 'ASC')
  end
  
  def mail_process_running?
    %x[ps -ef | grep jobs\:work | grep -v grep].match(/jobs\:work/)
  end
  
  # Handling flash
  def type_to_class(type)  
    case type
    when :notice, :info
      'info'
    when :error, :danger
      'danger'
    when :alert, :warning
      'warning'
    when :success
      'success'
    else
      'info'
    end
  end

end

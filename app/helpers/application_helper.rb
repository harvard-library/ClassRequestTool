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
    %x[ps -ef | grep delayed_job | grep -v grep].match(/delayed_job/)
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

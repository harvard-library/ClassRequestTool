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
end

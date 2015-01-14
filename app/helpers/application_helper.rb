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
end

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

  def pager_options_select(pager_id)
    options = %W(5 10 20 30 40)
    case pager_id
      when 'users-table'
        options_collection = options_for_select(options, 40) 
      when "your-repo-courses-table", "homeless-table", "your-unscheduled-table", "unassigned-table", 
                    "your-upcoming-table", "roomless-table", "your-to-close-table", "your-past-table"
        options_collection = options_for_select(options, 5) 
      else
        options_collection = options_for_select(options, 10) 
    end
      
    select_tag :people, options_collection, :class => 'pagesize'
  end
end

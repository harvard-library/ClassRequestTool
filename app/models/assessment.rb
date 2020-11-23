class Assessment < ApplicationRecord
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  belongs_to :course

  INVOLVEMENT = ['Class visit to see particular materials', 'Assisted in selecting materials for viewing in class', 'Presentation on use of primary sources in research', 'Class orientation in preparation for research assignment', 'Suggestions for materials appropriate to student research', 'Presentation on how to locate archival or rare book sources', 'Coordination of digital imaging for class use', 'Coordination of special projects (exhibits, etc.)', 'Other']
  RATINGS = {"0 Not Applicable" => 0, "1 Poor" => 1, "2 Sufficient" => 2, "3 Good" => 3, "4 Very Good" => 4, "5 Excellent" => 5 }
  
  # CSV export
  def self.csv_data(filters = {})
    fields =  [ "a.created_at",
                  'using_materials', 
                  'involvement', 
                  'staff_experience', 
                  'staff_availability', 
                  'space', 
                  'request_materials', 
                  'digital_collections', 
                  'involve_again', 
                  'not_involve_again', 
                  'better_future', 
                  'request_course', 
                  'catalogs', 
                  'a.comments',
                  'c.title'
                ]
    header_row = []
    formatted_fields = []
    fields.each do |field|
      case field
      when "a.created_at"
        header_row << 'Submitted'
        formatted_fields << "to_char(#{field}, 'YYYY-MM-DD HH:MIam') AS submitted"
      when 'a.comments'
        header_row << 'Comments'
        formatted_fields << field
      when 'c.title'
        header_row << 'Course title'
        formatted_fields << field
      else
        header_row << field.humanize
        formatted_fields << field
      end
    end
    
    select = "SELECT #{formatted_fields.join(',')} FROM assessments a "
    joins = [
      "INNER JOIN courses c ON a.course_id = c.id",
    ]
    
    order = 'a.created_at DESC'
    
    if filters.empty?
      sql = "#{select} #{joins.join(' ')} ORDER BY #{order}"
    else
      sql = "#{select} #{joins.join(' ')} WHERE #{filters.join(' AND ')} ORDER BY #{order}"
    end
    [header_row, sql]
  end
end

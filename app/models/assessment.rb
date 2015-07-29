class Assessment < ActiveRecord::Base
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers

  belongs_to :course

  INVOLVEMENT = ['Class visit to see particular materials', 'Assisted in selecting materials for viewing in class', 'Presentation on use of primary sources in research', 'Class orientation in preparation for research assignment', 'Suggestions for materials appropriate to student research', 'Presentation on how to locate archival or rare book sources', 'Coordination of digital imaging for class use', 'Coordination of special projects (exhibits, etc.)', 'Other']

  # CSV export
  def self.csv_data(filters = {})
    fields =  [ "to_char(a.created_at, 'YYYY-MM-DD HH:MIam')",
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
    fields.each do |field|
      case field
      when "to_char(a.created_at, 'YYYY-MM-DD HH:MIam')"
        heading = 'Submitted'
      when 'a.comments'
        heading = 'Comments'
      when 'c.title'
        heading = 'Course title'
      else
        heading = field.humanize
      end
      header_row << heading
    end
    
    select = "SELECT #{fields.join(',')} FROM assessments a "
    joins = [
      "INNER JOIN courses c ON a.course_id = c.id",
    ]
    
    order = 'ORDER BY a.created_at DESC'
    
    if filters.empty?
      sql = "#{select} #{joins.join(' ')} #{order}"
    else
      sql = "#{select} #{joins.join(' ')} WHERE #{filters.join(' AND ')} #{order}"
    end
    [header_row, sql]
  end
end

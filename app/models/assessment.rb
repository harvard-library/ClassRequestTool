class Assessment < ActiveRecord::Base
  attr_accessible :using_materials, :involvement, :staff_experience, :staff_availability, :space, :request_materials, :digital_collections, :involve_again, :not_involve_again, :better_future, :request_course, :catalogs
  
  belongs_to :course
  
  INVOLVEMENT = ['Class visit to see particular materials', 'Assisted in selecting materials for viewing in class', 'Presentation on use of primary sources in research', 'Class orientation in preparation for research assignment', 'Suggestions for materials appropriate to student research', 'Presentation on how to locate archival or rare book sources', 'Coordination of digital imaging for class use', 'Coordination of special projects (exhibits, etc.)', 'Other']

end

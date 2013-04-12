class Assessment < ActiveRecord::Base
  # attr_accessible :title, :body
  
  belongs_to :course
  
  INVOLVEMENT = ['Class visit to see particular materials', 'Assisted in selecting materials for viewing in class', 'Presentation on use of primary sources in research', 'Class orientation in preparation for research assignment', 'Suggestions for materials appropriate to student research', 'Presentation on how to locate archival or rare book sources', 'Coordination of digital imaging for class use', 'Coordination of special projects (exhibits, etc.)', 'Other']

end

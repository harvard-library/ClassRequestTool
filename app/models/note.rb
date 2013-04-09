class Note < ActiveRecord::Base
  attr_accessible :note_text, :user_id, :course_id
  
  belongs_to :user
  belongs_to :course
end

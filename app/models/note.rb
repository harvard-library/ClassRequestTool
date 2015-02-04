class Note < ActiveRecord::Base
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers
  attr_accessible :note_text, :user_id, :course_id, :staff_comment
  
  validates :note_text, :presence => true, length: { minimum: 3 }

  belongs_to :user
  belongs_to :course
end

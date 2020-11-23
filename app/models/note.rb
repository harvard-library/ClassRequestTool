class Note < ApplicationRecord
  include ActionDispatch::Routing::UrlFor
  include Rails.application.routes.url_helpers
  
  validates :note_text, :presence => true, length: { minimum: 3 }

  belongs_to :user
  belongs_to :course
end

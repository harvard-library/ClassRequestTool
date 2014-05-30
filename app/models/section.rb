class Section < ActiveRecord::Base
  belongs_to :course
  attr_accessible :requested_dates, :actual_date, :room_id, :session, :course
end

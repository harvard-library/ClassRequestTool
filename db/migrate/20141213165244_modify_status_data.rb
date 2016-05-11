class ModifyStatusData < ActiveRecord::Migration

  class Repository < ActiveRecord::Base
    has_many :courses
  end
  
  class Section < ActiveRecord::Base
    belongs_to :course
  end
  
  class User < ActiveRecord::Base
    has_and_belongs_to_many :courses
  end
  
  class Course < ActiveRecord::Base
    has_many :sections
    belongs_to :repository
    belongs_to :primary_contact, :class_name => 'User'
  end

# STATUS = ['Active', 'Cancelled', 'Closed']
    def up
    Course.find_each do |course|
      unless course.status == 'Closed' || course.status == 'Cancelled'
        course.status = 'Active'
        course.save
      end
    end
  end

# STATUS = ['Scheduled, Unclaimed', 'Scheduled, Claimed', 'Claimed, Unscheduled', 'Unclaimed, Unscheduled', 'Homeless', 'Cancelled', 'Closed']
  def down
    Course.find_each do |course|
      if 'Active' == course.status
        if course.repository.blank?
          course.status = 'Homeless'
        else
          if course.primary_contact.blank?
            claimed = false
          else
            claimed = true
          end
          
          scheduled = true
          course.sections.each do |section|
            if section.actual_date.blank?
              scheduled = false
              break
            end
          end
          
          if scheduled
            if claimed
              course.status = 'Scheduled, Claimed'
            else
              course.status = 'Scheduled, Unclaimed'
            end
          else
            if claimed
              course.status = 'Claimed, Unscheduled'
            else
              course.status = 'Unclaimed, Unscheduled'
            end
          end             
        end
        course.save
      end
    end
  end
end

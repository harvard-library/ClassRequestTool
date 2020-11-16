class ChangeContactPhoneToNullInCourses < ActiveRecord::Migration
  def change
    change_column_null :courses, :contact_phone, true
  end
end

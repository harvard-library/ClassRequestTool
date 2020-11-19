class ChangeContactPhoneToNullInCourses < ActiveRecord::Migration[4.2]
  def change
    change_column_null :courses, :contact_phone, true
  end
end

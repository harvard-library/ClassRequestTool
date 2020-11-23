class AddMeetingLinkToSections < ActiveRecord::Migration[4.2]
  def change
    add_column :sections, :meeting_link, :text
  end
end

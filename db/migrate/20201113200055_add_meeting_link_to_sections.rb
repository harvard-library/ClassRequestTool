class AddMeetingLinkToSections < ActiveRecord::Migration
  def change
    add_column :sections, :meeting_link, :text
  end
end

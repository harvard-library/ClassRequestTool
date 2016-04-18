class AddFeedbackLinkToCustomizations < ActiveRecord::Migration
  def change
    add_column :customizations, :feedback_link, :text
  end
end

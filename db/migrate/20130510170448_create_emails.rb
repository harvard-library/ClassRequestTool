class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :to
      t.string :bcc
      t.string :from
      t.string :reply_to
      t.string :subject
      t.text :body
      t.date :date_sent
      t.boolean :message_sent, :default => false
      t.timestamps
    end
  end
end

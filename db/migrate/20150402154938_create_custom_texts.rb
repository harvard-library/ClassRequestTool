class CreateCustomTexts < ActiveRecord::Migration
  def change
    create_table :custom_texts do |t|
      t.string :key, index: true
      t.text :text

      t.timestamps
    end
  end
end

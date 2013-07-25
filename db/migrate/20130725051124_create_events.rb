class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name, :default => ""
      t.timestamp :deadline
      t.attachment :photo
      t.text :description, :default => ""
      t.references :user
      t.timestamps
    end
  end
end

class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
    	t.string :category
    	t.references :source
    	t.references :target
    	t.references :recipe
    	t.integer :seen
      t.timestamps
    end
  end
end

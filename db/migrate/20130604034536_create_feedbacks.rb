class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
    	t.references :user
      t.string :type
      t.text :content
      t.timestamps
    end
  end
end

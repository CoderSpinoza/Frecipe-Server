class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
    	t.references :user, :null => false
    	t.references :follower, :null => false
      t.timestamps
    end

    add_index :follows, [:user_id, :follower_id], :unique => true
  end
end

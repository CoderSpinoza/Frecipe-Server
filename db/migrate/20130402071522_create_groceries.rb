class CreateGroceries < ActiveRecord::Migration
  def change
    create_table :groceries do |t|
    	t.references :user
    	t.references :ingredient
      t.timestamps
    end

    add_index :groceries, [:user_id, :ingredient_id], :unique => true
  end
end

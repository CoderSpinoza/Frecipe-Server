class CreateGroceries < ActiveRecord::Migration
  def change
    create_table :groceries do |t|
    	t.references :grocery_recipe
    	t.references :ingredient
    	t.integer :active, :default => 1
      t.timestamps
    end

    add_index :groceries, [:grocery_recipe_id, :ingredient_id], :unique => true
  end
end

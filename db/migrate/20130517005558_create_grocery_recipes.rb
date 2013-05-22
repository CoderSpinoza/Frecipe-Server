class CreateGroceryRecipes < ActiveRecord::Migration
  def change
    create_table :grocery_recipes do |t|
    	t.references :user
    	t.references :recipe
      t.timestamps
    end
    add_index :grocery_recipes, [:user_id, :recipe_id], :unique => true
  end

end

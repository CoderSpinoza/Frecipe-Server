class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
    	t.string :name
    	t.references :user
    	t.string :category
    	t.text :steps, :default => ""
    	t.attachment :recipe_image
      t.string :external
      t.integer :likes_count, :default => 0
      t.string :ingredients_string, :default => "", :limit => 1023
      t.string :username
      t.text :about
      t.timestamps
    end
  end
end

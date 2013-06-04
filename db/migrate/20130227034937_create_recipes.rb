class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
    	t.string :name
    	t.references :user
    	t.string :category
    	t.text :steps, :default => ""
    	t.attachment :recipe_image
      t.string :external
      t.timestamps
    end
  end
end

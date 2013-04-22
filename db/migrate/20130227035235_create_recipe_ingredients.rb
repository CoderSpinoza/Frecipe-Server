class CreateRecipeIngredients < ActiveRecord::Migration
  def change
    create_table :recipe_ingredients do |t|
    	t.references :ingredient
    	t.references :recipe
    	t.string :amount
    	t.string :unit
      t.timestamps
    end
  end
end

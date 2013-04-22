class CreateUserIngredients < ActiveRecord::Migration
  def change
    create_table :user_ingredients do |t|
    	t.references :ingredient
    	t.references :user
      t.timestamps
    end
  end
end

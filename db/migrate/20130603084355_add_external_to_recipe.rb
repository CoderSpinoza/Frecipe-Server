class AddExternalToRecipe < ActiveRecord::Migration
  def change
    add_column :recipes, :external, :string
  end
end

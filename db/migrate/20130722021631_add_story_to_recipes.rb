class AddStoryToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :story, :text, :default => ""
  end
end

class RecipeIngredient < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :ingredient
  belongs_to :recipe
  attr_accessible :ingredient, :recipe, :ingredient_id, :recipe_id
end

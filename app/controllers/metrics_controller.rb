class MetricsController < ApplicationController
  def index
  	@users = User.all
  	@recipes = Recipe.all
  	@UserIngredients = UserIngredient.all.length
  	@groceryRecipes = GroceryRecipe.where('recipe_id != 0').length
  end

  def show
  end
end

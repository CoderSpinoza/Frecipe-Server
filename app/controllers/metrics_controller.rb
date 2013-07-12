class MetricsController < ApplicationController
  def index
  	@users = User.all
  	@recipes = Recipe.all
  	@userIngredients = UserIngredient.all
  	@groceryRecipes = GroceryRecipe.where('recipe_id != 0')
  end

  def show
  end
end

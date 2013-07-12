class MetricsController < ApplicationController
  def index
  	@users = User.all
  	@recipes = Recipe.all
  	@userIngredients = UserIngredient.all
  	@groceryRecipes = GroceryRecipe.where('recipe_id != 0')
  	@likes = Like.all
  	@follows = Follow.all
  	@comments = Comment.all
  	@evaluations = RSEvaluation.all
  end

  def show
  end
end

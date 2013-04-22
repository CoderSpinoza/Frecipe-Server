class Ingredient < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :recipe_relationships, :class_name => "RecipeIngredient", :foreign_key => "recipe_id"
  has_many :recipes, :through => :recipe_relationships, :source => :recipe
  attr_accessible :name
end

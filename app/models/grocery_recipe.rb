class GroceryRecipe < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :user
  belongs_to :recipe

  has_many :groceries, :dependent => :destroy
  has_many :ingredient_relationships, :class_name => "Grocery", :foreign_key => "grocery_recipe_id"
  has_many :ingredients, :through => :ingredient_relationships, :source => :ingredient
  attr_accessible :user, :recipe, :user_id, :recipe_id

end

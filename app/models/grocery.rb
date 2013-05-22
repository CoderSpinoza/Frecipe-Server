class Grocery < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope order('created_at')
  belongs_to :grocery_recipe
  belongs_to :ingredient
  attr_accessible :grocery_recipe, :ingredient, :grocery_recipe_id, :ingredient_id, :active

  validates :grocery_recipe_id, :uniqueness => { :scope => :ingredient_id }
end

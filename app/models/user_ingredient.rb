class UserIngredient < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  belongs_to :ingredient
  attr_accessible :user, :user_id, :ingredient, :ingredient_id

  validates :user_id, :uniqueness => { :scope => :ingredient_id }
end

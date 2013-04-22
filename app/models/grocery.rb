class Grocery < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :user
  belongs_to :ingredient
  attr_accessible :user, :ingredient, :user_id, :ingredient_id
end

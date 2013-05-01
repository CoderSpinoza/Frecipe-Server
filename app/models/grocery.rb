class Grocery < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :user
  belongs_to :ingredient
  attr_accessible :user, :ingredient, :user_id, :ingredient_id

  validates :user_id, :uniqueness => { :scope => :ingredient_id }
end

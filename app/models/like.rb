class Like < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :user
  belongs_to :recipe

  attr_accessible :user, :recipe
  validates :user_id, :uniqueness => { :scope => :recipe_id }
end

class Comment < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :user
  belongs_to :recipe
  belongs_to :parent, :class_name => "Comment"
  attr_accessible :user, :recipe, :user_id, :recipe_id, :text
end

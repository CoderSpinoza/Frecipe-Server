class Follow < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user, :class_name => "User"
  belongs_to :follower, :class_name => "User"

  attr_accessible :user, :follower, :user_id, :follower_id
  validates :user_id, :uniqueness => { :scope => :follower_id }
end

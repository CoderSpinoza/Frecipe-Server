class Notification < ActiveRecord::Base
  # attr_accessible :title, :body

  default_scope order('updated_at DESC')
  belongs_to :source, :class_name => "User"
  belongs_to :target, :class_name => "User"
  belongs_to :recipe

  attr_accessible :category, :source_id, :target_id, :source, :target, :recipe, :seen
end

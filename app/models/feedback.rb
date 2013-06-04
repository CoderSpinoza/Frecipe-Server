class Feedback < ActiveRecord::Base
  attr_accessible :content, :type, :user, :user_id
end

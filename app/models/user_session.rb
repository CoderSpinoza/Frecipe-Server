class UserSession < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :user, :remember_me, :authentication_token, :device
  # attr_accessible :title, :body

  belongs_to :user

  def self.user_by_authentication_token(token)
  	session = UserSession.find_by_authentication_token(token)
  	return session.user
  end
end

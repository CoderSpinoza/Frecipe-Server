class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :omniauthable, :omniauth_providers => [:facebook]


  has_many :ingredient_relationships, :class_name => "UserIngredient", :foreign_key => "user_id"
  has_many :ingredients, :through => :ingredient_relationships, :source => :ingredient
  
  has_many :follow_relationships, :class_name => "Follow", :foreign_key => "user_id"
  has_many :followers, :through => :follow_relationships, :source => :follower

  has_many :grocery_relationships, :class_name => "Grocery", :foreign_key => "user_id"
  has_many :groceries, :through => :grocery_relationships, :source => :ingredient
  has_many :recipes
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :provider, :uid, :authentication_token, :profile_picture, :level
  has_attached_file :profile_picture, :path => "public/image/users/:id/:filename", :url => "image/users/:id/:filename", :default_url => "https://s3.amazonaws.com/Frecipe/public/image/users/default_profile_picture.jpg", :s3_permissions => "public_read_write"
  # attr_accessible :title, :body

  def self.from_omniauth(auth)
	  where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
	    user.provider = auth.provider
	    user.uid = auth.uid
	    user.name = auth.info.name
	    user.oauth_token = auth.credentials.token
	    user.oauth_expires_at = Time.at(auth.credentials.expires_at)
	    user.save!
	  end
	end

  def liked?(id)
    recipe = Recipe.find(id)

    if Like.where(:user_id => self.id, :recipe_id => recipe.id)
      return true
    else
      return false
    end
  end

end

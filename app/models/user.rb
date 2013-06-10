class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :omniauthable, :omniauth_providers => [:facebook]


  has_many :ingredient_relationships, :class_name => "UserIngredient", :foreign_key => "user_id"
  has_many :ingredients, :through => :ingredient_relationships, :source => :ingredient, :dependent => :destroy
  
  has_many :follow_relationships, :class_name => "Follow", :foreign_key => "user_id"
  has_many :followers, :through => :follow_relationships, :source => :follower, :dependent => :destroy

  has_many :following_relationships, :class_name => "Follow", :foreign_key => "follower_id"
  has_many :following, :through => :following_relationships, :source => :user, :dependent => :destroy

  has_many :liked_relationships, :class_name => "Like", :foreign_key => "user_id"
  has_many :liked, :through => :liked_relationships, :source => :recipe, :dependent => :destroy
  
  
  has_many :recipes, :dependent => :destroy
  has_many :comments, :dependent => :destroy

  has_many :notify, :class_name => "Notification", :foreign_key => "source_id", :dependent => :destroy
  has_many :notified, :class_name => "Notification", :foreign_key => "target_id", :dependent => :destroy

  has_many :user_sessions

  has_many :grocery_recipe_relationships, :class_name => "GroceryRecipe", :foreign_key => "user_id"
  has_many :recipes_for_grocery, :through => :grocery_recipe_relationships, :source => :recipe, :dependent => :destroy

  has_many :grocery_recipes, :dependent => :destroy
  has_many :evaluations, class_name: "RSEvaluation", as: :source
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name, :provider, :uid, :authentication_token, :profile_picture, :level, :about, :website
  has_attached_file :profile_picture, :path => "public/image/users/:id/:filename", :url => "image/users/:id/:filename", :default_url => "https://s3.amazonaws.com/Frecipe/public/image/users/default_profile_picture.png", :s3_permissions => "public_read_write"
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
    recipe = Recipe.find_by_id(id)

    if Like.where(:user_id => self.id, :recipe_id => recipe.id).length > 0
      return true
    else
      return false
    end
  end

  def rated_for?(recipe)
    evaluations.where(target_type: recipe.class, target_id: recipe.id).present?
  end

  def rate_value(recipe)
    evaluation = evaluations.where(target_type: recipe.class, target_id: recipe.id)
    if evaluation.length > 0
      return evaluation[0].value
    else
      return 0
    end
  end

  def average_rating
    recipes = self.recipes

    sum = 0
    count = 0 
    for recipe in recipes
      sum += recipe.reputation_for(:rating)
      count += 1
    end

    if count == 0
      return 0
    else
      return Float(sum) / count
    end
  end

  def upload_notification(recipe)
    for follower in self.followers
      Notification.create(:source => self, :target => follower, :recipe => recipe, :category => "upload", :seen => 0)
    end
  end

  def grocery_list
    recipes = self.recipes_for_grocery
    grocery_recipes = []

    # for recipe in recipes
    #   difference = recipe.
    #   grocery_recipes << { :id => recipe.id, :name => recipe.name, :recipe_image => recipe.recipe_image.url, :missing_ingredients => set_difference }
    # end

    groceries = []
    for grocery_recipe in self.grocery_recipes
      if grocery_recipe.recipe_id != 0
        temp_groceries = grocery_recipe.groceries.select { |grocery| grocery.fridge == 1 }
        ingredient_ids = temp_groceries.map { |grocery| grocery.ingredient_id }
        temp_ingredients = grocery_recipe.ingredients.select { |ingredient| ingredient_ids.include? ingredient.id }
        grocery_recipes << { :id => grocery_recipe.id, :name => grocery_recipe.recipe.name, :recipe_image => grocery_recipe.recipe.recipe_image.url, :missing_ingredients => temp_ingredients, :groceries => temp_groceries }
      else
        groceries = grocery_recipe.ingredients
      end
    end
    return { :groceries => groceries, :recipes => grocery_recipes }
  end

end

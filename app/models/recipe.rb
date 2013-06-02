class Recipe < ActiveRecord::Base
  # attr_accessible :title, :body

  belongs_to :user
  has_many :ingredient_relationships, :class_name => "RecipeIngredient", :foreign_key => "recipe_id"
  has_many :ingredients, :through => :ingredient_relationships, :source => :ingredient, :dependent => :destroy

  has_many :like_relationships, :class_name => "Like", :foreign_key => "recipe_id"
  has_many :likers, :through => :like_relationships, :source => :user, :dependent => :destroy

  has_many :comments, :dependent => :destroy
  attr_accessible :name, :user, :steps

  has_reputation :rating, source: :user, aggregated_by: :average

  has_many :notifications, :dependent => :destroy

  has_many :grocery_recipes, :dependent => :destroy

  has_attached_file :recipe_image, :path => "public/image/recipes/:id/:filename", :url => "image/recipes/:id/:filename", :default_url => "https://s3.amazonaws.com/Frecipe/public/image/recipe/default_recipe_image.png", :s3_permissions => "public_read_write"

  def self.find_by_user_ingredients(user)
  	ingredients = user.ingredients
  end
end

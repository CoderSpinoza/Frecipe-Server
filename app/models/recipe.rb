class Recipe < ActiveRecord::Base
  # attr_accessible :title, :body
  require 'rest-client'
  require 'open-uri'

  belongs_to :user
  has_many :ingredient_relationships, :class_name => "RecipeIngredient", :foreign_key => "recipe_id"
  has_many :ingredients, :through => :ingredient_relationships, :source => :ingredient, :dependent => :destroy

  has_many :like_relationships, :class_name => "Like", :foreign_key => "recipe_id"
  has_many :likers, :through => :like_relationships, :source => :user, :dependent => :destroy

  has_many :comments, :dependent => :destroy
  attr_accessible :name, :user, :steps, :likes_count

  has_reputation :rating, source: :user, aggregated_by: :average, :source_of => [{ :reputation => :average_rating, :of => :user}]

  has_many :notifications, :dependent => :destroy

  has_many :grocery_recipes, :dependent => :destroy

  has_attached_file :recipe_image, :path => "public/image/recipes/:id/:filename", :url => "/image/recipes/:id/:filename", :default_url => "https://s3.amazonaws.com/FrecipeProduction/public/image/recipes/default_recipe_image.png", :s3_permissions => "public_read_write"

  def self.find_by_user_ingredients(user)
  	ingredients = user.ingredients
  end

  def self.import_from_yummly
    categories = ['cuisine^cuisine-moroccan', 'cuisine^cuisine-indian', 'cuisine^cuisine-barbecue-bbq', 'cuisine^cuisine-mediterranean', 'cuisine^cuisine-french', 'cuisine^cuisine-asian', 'cuisine^cuisine-mexican', 'cuisine^cuisine-chinese', 'cuisine^cuisine-italian', 'cuisine^cuisine-american', 'cuisine^cuisine-thai', 'cuisine^cuisine-spanish', 'cuisine^cuisine-southern', 'cuisine^cuisine-greek', 'cuisine^cuisine-cajun', 'cuisine^cuisine-hawaiian']
    keywords = ['fruit', 'ice', 'rum', 'sandwich', 'steak', 'pork', 'chicken', 'butter', 'beef', 'stew', 'eggplant', 'peanut', 'pineapple', 'kimchi', 'curry', 'burrito', 'pho', 'pasta', 'fries', 'olive', 'caesar', 'bbq']
    count = 0
    keywords.each { |keyword|
      data = RestClient.get "http://api.yummly.com/v1/api/recipes?_app_id=6bf915ea&_app_key=23479030b7598f1834f192a297a1585f&requirePictures=true&q=" + keyword
      json = JSON.parse(data)
      recipes = json["matches"]
      user = User.all[0]
      recipes.each { |hash|
        recipe = Recipe.new(:name => hash["recipeName"].downcase.titleize)
        ingredients = hash["ingredients"]
        recipe.ingredients_string = ingredients.map { |ingredient| ingredient.titleize }.to_sentence(options = { :words_connector => ",", :two_words_connector => ",", :last_word_connector => ","})[0, 255]
        ingredients.each { |ingredient|
          recipe.ingredients << Ingredient.find_or_create_by_name(ingredient.titleize)
        }
        if hash["smallImageUrls"]
          url = hash["smallImageUrls"][0]
          url[".s."] = ".l."
          recipe.recipe_image = URI.parse(url)
        end
        recipe.user_id = user.id
        recipe.external = "http://www.yummly.com/recipe/external/" + hash["id"]
        recipe.save!
      }
      count += 1
    }    
  end

  def self.import_from_yummly_with_keyword(keyword)
    data = RestClient.get "http://api.yummly.com/v1/api/recipes?_app_id=6bf915ea&_app_key=23479030b7598f1834f192a297a1585f&requirePictures=true&q=" + keyword
    json = JSON.parse(data)
    recipes = json["matches"]
    user = User.all[0]
    recipes.each { |hash|
      recipe = Recipe.new(:name => hash["recipeName"].downcase.titleize)
      ingredients = hash["ingredients"]
      recipe.ingredients_string = ingredients.map { |ingredient| ingredient.titleize }.to_sentence(options = { :words_connector => ",", :two_words_connector => ",", :last_word_connector => ","})[0, 255]
      ingredients.each { |ingredient|
        recipe.ingredients << Ingredient.find_or_create_by_name(ingredient.titleize)
      }
    if hash["smallImageUrls"]
      url = hash["smallImageUrls"][0]
      url[".s."] = ".l."
      recipe.recipe_image = URI.parse(url)
    end
    recipe.user_id = user.id
    recipe.external = "http://www.yummly.com/recipe/external/" + hash["id"]
    recipe.save!
    }
  end

  def self.fetch_all
    return Recipe.select('recipes.name, recipes.id AS recipe_id, users.id AS user_id, users.first_name as first_name, users.last_name as last_name, recipes.likes_count, recipes.ingredients_string, recipes.recipe_image_file_name').joins(:user)
  end

  def self.fetch_with_user(user)
    return Recipe.select('recipes.name, recipes.id AS recipe_id, users.id AS user_id, users.first_name as first_name, users.last_name as last_name, recipes.likes_count, recipes.ingredients_string, recipes.recipe_image_file_name').joins(:user).where(:user_id => user.id)
  end

  def fetch_comments
    return self.comments.select('users.id AS user_id, users.first_name AS first_name, users.last_name AS last_name, users.provider AS provider, users.uid AS uid, users.profile_picture_file_name AS profile_picture, comments.id AS comment_id, comments.text AS text, comments.created_at').joins(:user)
  end
end

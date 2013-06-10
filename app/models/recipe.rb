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
  attr_accessible :name, :user, :steps

  has_reputation :rating, source: :user, aggregated_by: :average

  has_many :notifications, :dependent => :destroy

  has_many :grocery_recipes, :dependent => :destroy

  has_attached_file :recipe_image, :path => "public/image/recipes/:id/:filename", :url => "/image/recipes/:id/:filename", :default_url => "https://s3.amazonaws.com/Frecipe/public/image/recipes/default_recipe_image.png", :s3_permissions => "public_read_write"

  def self.find_by_user_ingredients(user)
  	ingredients = user.ingredients
  end

  def self.import_from_yummly
    categories = ['cuisine^cuisine-moroccan', 'cuisine^cuisine-indian', 'cuisine^cuisine-barbecue-bbq', 'cuisine^cuisine-mediterranean', 'cuisine^cuisine-french', 'cuisine^cuisine-asian', 'cuisine^cuisine-mexican', 'cuisine^cuisine-chinese', 'cuisine^cuisine-italian', 'cuisine^cuisine-american', 'cuisine^cuisine-thai', 'cuisine^cuisine-spanish', 'cuisine^cuisine-southern', 'cuisine^cuisine-greek', 'cuisine^cuisine-cajun', 'cuisine^cuisine-hawaiian']
    keywords = ['fruit', 'ice', 'rum', 'sandwich']
    count = 0
    keywords.each { |keyword|
      data = RestClient.get "http://api.yummly.com/v1/api/recipes?_app_id=6bf915ea&_app_key=23479030b7598f1834f192a297a1585f&requirePictures=true&q=" + keyword
      json = JSON.parse(data)
      recipes = json["matches"]
      user = User.all[0]
      recipes.each { |hash|
        recipe = Recipe.new(:name => hash["recipeName"].downcase.titleize)
        ingredients = hash["ingredients"]
        ingredients.each { |ingredient|
          recipe.ingredients << Ingredient.find_or_create_by_name(ingredient.titleize)
        }
        if hash["smallImageUrls"]
          url = hash["smallImageUrls"][0]
          url[".s."] = ".l."
          recipe.recipe_image = URI.parse(url)
        end
        recipe.user = user
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
      ingredients.each { |ingredient|
        recipe.ingredients << Ingredient.find_or_create_by_name(ingredient.titleize)
      }
    if hash["smallImageUrls"]
      url = hash["smallImageUrls"][0]
      url[".s."] = ".l."
      recipe.recipe_image = URI.parse(url)
    end
    recipe.user = user
    recipe.external = "http://www.yummly.com/recipe/external/" + hash["id"]
    recipe.save!
    }
  end
end

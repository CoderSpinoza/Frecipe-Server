class Ingredient < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope order('name')

  has_many :recipe_relationships, :class_name => "RecipeIngredient", :foreign_key => "recipe_id"
  has_many :recipes, :through => :recipe_relationships, :source => :recipe
  attr_accessible :name, :image

  has_attached_file :image, :path => "public/image/ingredients/:id/:filename", :url => "image/ingredients/:id/:filename", :default_url => "https://s3.amazonaws.com/Frecipe/public/image/ingredients/default_ingredient_image.png", :s3_permissions => "public_read_write"
  validates_attachment_size :image, :less_than => 5.megabytes
	validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png']
end

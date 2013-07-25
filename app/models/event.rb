class Event < ActiveRecord::Base
  attr_accessible :deadline, :description, :name, :photo, :posted_date, :user
  has_one :user
  has_attached_file :photo, :path => "public/image/events/:id/:filename", :url => 'image/events/:id/:filename', :s3_permissions => "public_read_write"
end

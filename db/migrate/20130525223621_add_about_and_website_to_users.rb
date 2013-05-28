class AddAboutAndWebsiteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :about, :text, :default => ""
    add_column :users, :website, :string, :default => ""
  end
end

class AddAboutAndWebsiteToUsers < ActiveRecord::Migration
  def change
    add_column :users, :about, :text
    add_column :users, :website, :string
  end
end

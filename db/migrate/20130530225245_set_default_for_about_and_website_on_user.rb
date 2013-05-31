class SetDefaultForAboutAndWebsiteOnUser < ActiveRecord::Migration
  def up
  	change_column :users, :about, :text, :default => ""
  	change_column :users, :website, :string, :default => ""
  end

  def down
  end
end

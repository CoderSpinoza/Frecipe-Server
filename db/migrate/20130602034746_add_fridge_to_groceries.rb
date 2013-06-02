class AddFridgeToGroceries < ActiveRecord::Migration
  def change
    add_column :groceries, :fridge, :integer
  end
end

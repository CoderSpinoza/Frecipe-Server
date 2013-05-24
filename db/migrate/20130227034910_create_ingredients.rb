class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
    	t.string :name, :unique => true
    	t.attachment :image
      t.timestamps
    end
  end
end

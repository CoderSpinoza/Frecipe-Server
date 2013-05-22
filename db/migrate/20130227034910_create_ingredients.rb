class CreateIngredients < ActiveRecord::Migration
  def change
    create_table :ingredients do |t|
    	t.string :name
    	t.attachment :image
      t.timestamps
    end
  end
end

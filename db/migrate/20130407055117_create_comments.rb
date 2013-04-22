class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
    	t.references :user
    	t.references :recipe
    	t.text :text
    	t.references :parent, :default => 0
    	t.integer :indent, :default => 0
      t.timestamps
    end
  end
end

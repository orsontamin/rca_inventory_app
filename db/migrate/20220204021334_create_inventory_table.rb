class CreateInventoryTable < ActiveRecord::Migration[7.0]
  def change
    create_table :inventories do |t|
      t.string :title
      t.string :description
      t.boolean :available, default: false
      t.integer :quantity
      t.timestamps
    end
  end
end

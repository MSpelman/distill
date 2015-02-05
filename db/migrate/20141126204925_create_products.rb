class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :product_type_id
      t.string :name
      t.decimal :price
      t.date :release_date
      t.text :description
      t.boolean :active

      t.timestamps
    end
  end
end

class AddQuantityInStockToProducts < ActiveRecord::Migration
  def change
    add_column :products, :quantity_in_stock, :integer
  end
end

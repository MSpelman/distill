class AddUnitPriceToOrderProducts < ActiveRecord::Migration
  def change
    add_column :order_products, :unit_price, :decimal
  end
end

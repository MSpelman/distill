class AddTotalsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :product_total, :decimal
    add_column :orders, :tax, :decimal
    add_column :orders, :amount_due, :decimal
  end
end

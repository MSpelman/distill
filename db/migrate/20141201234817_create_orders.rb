class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :order_status_id
      t.date :pickup_date
      t.date :order_date

      t.timestamps
    end
  end
end

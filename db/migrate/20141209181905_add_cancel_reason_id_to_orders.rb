class AddCancelReasonIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :cancel_reason_id, :integer
  end
end

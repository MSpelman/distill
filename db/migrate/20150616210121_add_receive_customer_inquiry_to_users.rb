class AddReceiveCustomerInquiryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :receive_customer_inquiry, :boolean
  end
end

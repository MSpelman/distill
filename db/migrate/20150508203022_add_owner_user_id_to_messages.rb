class AddOwnerUserIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :owner_user_id, :integer
  end
end

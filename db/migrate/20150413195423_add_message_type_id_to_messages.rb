class AddMessageTypeIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :message_type_id, :integer
  end
end

class AddCopiedMessageIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :copied_message_id, :integer
  end
end

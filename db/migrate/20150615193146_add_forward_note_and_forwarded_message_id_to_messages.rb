class AddForwardNoteAndForwardedMessageIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :forward_note, :text
    add_column :messages, :forwarded_message_id, :integer
  end
end

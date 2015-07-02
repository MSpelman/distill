class CreateRecipientUsers < ActiveRecord::Migration
  def change
    create_table :recipient_users do |t|
      t.integer :message_id
      t.integer :user_id

      t.timestamps
    end
  end
end

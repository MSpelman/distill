class AddActiveToMessageTypes < ActiveRecord::Migration
  def change
    add_column :message_types, :active, :boolean
  end
end

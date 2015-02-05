class CreateCancelReasons < ActiveRecord::Migration
  def change
    create_table :cancel_reasons do |t|
      t.string :name

      t.timestamps
    end
  end
end

class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :subject
      t.text :body
      t.boolean :deleted
      t.boolean :read
      t.datetime :took_ownership_at

      t.timestamps
    end
  end
end

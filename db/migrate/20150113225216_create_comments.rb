class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :summary
      t.text :detail
      t.integer :rating
      t.boolean :active

      t.timestamps
    end
  end
end

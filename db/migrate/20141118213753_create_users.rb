class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :hashed_password
      t.string :name
      t.string :address_1
      t.string :address_2
      t.string :apt_number
      t.string :city
      t.string :state
      t.string :zip_code
      t.boolean :newsletter
      t.boolean :active
      t.boolean :admin

      t.timestamps
    end
  end
end

# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150114225110) do

  create_table "cancel_reasons", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", force: true do |t|
    t.string   "summary"
    t.text     "detail"
    t.integer  "rating"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_id"
    t.integer  "user_id"
  end

  create_table "order_products", force: true do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "unit_price"
  end

  create_table "order_statuses", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: true do |t|
    t.integer  "order_status_id"
    t.date     "pickup_date"
    t.date     "order_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cancel_reason_id"
    t.integer  "user_id"
    t.decimal  "product_total"
    t.decimal  "tax"
    t.decimal  "amount_due"
  end

  create_table "product_types", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.integer  "product_type_id"
    t.string   "name"
    t.decimal  "price"
    t.date     "release_date"
    t.text     "description"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "hashed_password"
    t.string   "name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "apt_number"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.boolean  "newsletter"
    t.boolean  "active"
    t.boolean  "admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080808095031) do

  create_table "favors", :force => true do |t|
    t.string   "owner_id"
    t.string   "title"
    t.text     "description"
    t.string   "payment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.string   "owner_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listings", :force => true do |t|
    t.string   "author_id"
    t.integer  "category_id"
    t.string   "title"
    t.text     "content"
    t.date     "good_thru"
    t.integer  "times_viewed"
    t.string   "status"
    t.integer  "value_cc"
    t.string   "value_other"
    t.string   "language"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

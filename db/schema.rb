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

ActiveRecord::Schema.define(:version => 20100729112458) do

  create_table "cached_ressi_events", :force => true do |t|
    t.string   "user_id"
    t.string   "application_id"
    t.string   "session_id"
    t.string   "ip_address"
    t.string   "action"
    t.text     "parameters"
    t.string   "return_value"
    t.text     "headers"
    t.string   "semantic_event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversations", :force => true do |t|
    t.string   "title"
    t.integer  "listing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                 :default => "Conversation"
    t.string   "reserver_name"
    t.datetime "pick_up_time"
    t.datetime "return_time"
    t.string   "status"
    t.integer  "hidden_from_owner",    :default => 0
    t.integer  "hidden_from_reserver", :default => 0
    t.integer  "favor_id"
  end

  create_table "favors", :force => true do |t|
    t.string   "owner_id"
    t.string   "title"
    t.text     "description"
    t.integer  "payment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",      :default => "enabled"
    t.string   "visibility",  :default => "everybody"
  end

  create_table "feedbacks", :force => true do |t|
    t.text     "content"
    t.string   "author_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_handled", :default => 0
  end

  create_table "filters", :force => true do |t|
    t.string   "person_id"
    t.text     "keywords"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_favors", :id => false, :force => true do |t|
    t.string  "group_id"
    t.integer "favor_id"
  end

  create_table "groups_items", :id => false, :force => true do |t|
    t.string  "group_id"
    t.integer "item_id"
  end

  create_table "groups_listings", :id => false, :force => true do |t|
    t.string  "group_id"
    t.integer "listing_id"
  end

  create_table "item_reservations", :force => true do |t|
    t.integer  "item_id"
    t.integer  "reservation_id"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.string   "owner_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment"
    t.string   "status",      :default => "enabled"
    t.text     "description"
    t.string   "visibility",  :default => "everybody"
    t.integer  "amount",      :default => 1
  end

  create_table "kassi_event_participations", :force => true do |t|
    t.integer  "kassi_event_id"
    t.string   "person_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kassi_events", :force => true do |t|
    t.string   "receiver_id"
    t.string   "realizer_id"
    t.integer  "eventable_id"
    t.string   "eventable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "pending",        :default => 0
  end

  create_table "kassi_events_people", :id => false, :force => true do |t|
    t.string "person_id"
    t.string "kassi_event_id"
  end

  create_table "listing_comments", :force => true do |t|
    t.string   "author_id"
    t.integer  "listing_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_read",    :default => 0
  end

  create_table "listing_followers", :id => false, :force => true do |t|
    t.string   "person_id"
    t.integer  "listing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listings", :force => true do |t|
    t.string   "author_id"
    t.string   "category"
    t.string   "title"
    t.text     "content"
    t.date     "good_thru"
    t.integer  "times_viewed",            :default => 0
    t.string   "status"
    t.integer  "value_cc"
    t.string   "value_other"
    t.string   "language"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_modified"
    t.string   "visibility",              :default => "everybody"
    t.boolean  "close_notification_sent", :default => false
    t.string   "listing_type"
    t.text     "description"
    t.string   "share_type"
    t.string   "origin"
    t.string   "destination"
  end

  create_table "messages", :force => true do |t|
    t.string   "sender_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conversation_id"
  end

  create_table "people", :id => false, :force => true, :primary_key => :id do |t|
    t.string :id, :limit => 22, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_admin",   :default => 0
    t.string   "locale",     :default => "fi"
  end

  create_table "people_smerf_forms", :force => true do |t|
    t.string  "person_id",     :null => false
    t.integer "smerf_form_id", :null => false
    t.text    "responses",     :null => false
  end

  create_table "person_comments", :force => true do |t|
    t.string   "author_id"
    t.string   "target_person_id"
    t.text     "text_content"
    t.float    "grade"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "kassi_event_id"
  end

  create_table "person_conversations", :force => true do |t|
    t.string   "person_id"
    t.integer  "conversation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_read",          :default => 0
    t.datetime "last_sent_at"
    t.datetime "last_received_at"
  end

  create_table "person_interesting_listings", :force => true do |t|
    t.string   "person_id"
    t.integer  "listing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "person_read_listings", :force => true do |t|
    t.string   "person_id"
    t.integer  "listing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.integer  "email_when_new_message",                :default => 1
    t.integer  "email_when_new_comment",                :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "person_id"
    t.integer  "email_when_new_friend_request",         :default => 1
    t.integer  "email_when_new_kassi_event",            :default => 1
    t.integer  "email_when_new_comment_to_kassi_event", :default => 1
    t.integer  "email_when_new_listing_from_friend",    :default => 1
  end

  create_table "smerf_forms", :force => true do |t|
    t.string   "name",                             :null => false
    t.string   "code",                             :null => false
    t.integer  "active",                           :null => false
    t.text     "cache",      :limit => 2147483647
    t.datetime "cache_date"
  end

  add_index "smerf_forms", ["code"], :name => "index_smerf_forms_on_code", :unique => true

  create_table "smerf_responses", :force => true do |t|
    t.integer "people_smerf_form_id", :null => false
    t.string  "question_code",        :null => false
    t.text    "response",             :null => false
  end

  create_table "transactions", :force => true do |t|
    t.string   "sender_id"
    t.string   "receiver_id"
    t.integer  "listing_id"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110915101535) do

  create_table "badges", :force => true do |t|
    t.string   "person_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.integer  "test_group_number"
  end

  create_table "comments", :force => true do |t|
    t.string   "author_id"
    t.integer  "listing_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "communities", :force => true do |t|
    t.string   "name"
    t.string   "domain"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "settings"
    t.string   "consent",                        :default => "KASSI_FI1.0"
    t.boolean  "email_admins_about_new_members", :default => false
    t.boolean  "use_fb_like",                    :default => false
    t.boolean  "real_name_required",             :default => true
    t.boolean  "feedback_to_admin",              :default => false
    t.boolean  "automatic_newsletters",          :default => true
    t.boolean  "join_with_invite_only",          :default => false
    t.boolean  "use_captcha",                    :default => true
    t.boolean  "email_confirmation",             :default => false
    t.text     "allowed_emails"
  end

  create_table "communities_listings", :id => false, :force => true do |t|
    t.integer "community_id"
    t.integer "listing_id"
  end

  create_table "community_memberships", :force => true do |t|
    t.string   "person_id"
    t.integer  "community_id"
    t.boolean  "admin",         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "consent",       :default => "KASSI_FI1.0"
    t.integer  "invitation_id"
  end

  create_table "contact_requests", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conversations", :force => true do |t|
    t.string   "title"
    t.integer  "listing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reserver_name"
    t.datetime "pick_up_time"
    t.datetime "return_time"
    t.string   "status",               :default => "pending"
    t.integer  "hidden_from_owner",    :default => 0
    t.integer  "hidden_from_reserver", :default => 0
    t.integer  "favor_id"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

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
    t.string   "email"
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

  create_table "invitations", :force => true do |t|
    t.string   "code"
    t.integer  "community_id"
    t.integer  "usages_left"
    t.datetime "valid_until"
    t.string   "information"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "listing_images", :force => true do |t|
    t.integer  "listing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
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
    t.string   "origin"
    t.string   "destination"
    t.datetime "valid_until"
    t.boolean  "delta",                   :default => true,        :null => false
    t.boolean  "open",                    :default => true
  end

  create_table "locations", :force => true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.string   "address"
    t.string   "google_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "listing_id"
    t.string   "person_id"
    t.string   "location_type"
  end

  create_table "messages", :force => true do |t|
    t.string   "sender_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conversation_id"
  end

  create_table "notifications", :force => true do |t|
    t.string   "receiver_id"
    t.string   "type"
    t.boolean  "is_read",        :default => false
    t.integer  "badge_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "testimonial_id"
  end

  create_table "participations", :force => true do |t|
    t.string   "person_id"
    t.integer  "conversation_id"
    t.boolean  "is_read",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_sent_at"
    t.datetime "last_received_at"
    t.boolean  "feedback_skipped", :default => false
  end

 create_table "people", :id => false, :force => true do |t|
    t.string   "id",                  :limit => 22,                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_admin",             :default => 0
    t.string   "locale",               :default => "fi"
    t.text     "preferences"
    t.integer  "active_days_count",    :default => 0
    t.datetime "last_page_load_date"
    t.integer  "test_group_number",    :default => 1
    t.boolean  "active",               :default => true
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
  end

  add_index "people", ["confirmation_token"], :name => "index_people_on_confirmation_token", :unique => true

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

  create_table "share_types", :force => true do |t|
    t.integer "listing_id"
    t.string  "name"
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

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "testimonials", :force => true do |t|
    t.float    "grade"
    t.text     "text"
    t.string   "author_id"
    t.integer  "participation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "receiver_id"
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

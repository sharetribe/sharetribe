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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121220133808) do

  create_table "auth_tokens", :force => true do |t|
    t.string   "token"
    t.string   "person_id"
    t.datetime "expires_at"
    t.integer  "times_used"
    t.datetime "last_use_attempt"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "auth_tokens", ["token"], :name => "index_auth_tokens_on_token", :unique => true

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
    t.integer  "community_id"
  end

  create_table "comments", :force => true do |t|
    t.string   "author_id"
    t.integer  "listing_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["listing_id"], :name => "index_comments_on_listing_id"

  create_table "communities", :force => true do |t|
    t.string   "name"
    t.string   "domain"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "settings"
    t.string   "consent"
    t.boolean  "email_admins_about_new_members",            :default => false
    t.boolean  "use_fb_like",                               :default => false
    t.boolean  "real_name_required",                        :default => true
    t.boolean  "feedback_to_admin",                         :default => false
    t.boolean  "automatic_newsletters",                     :default => true
    t.boolean  "join_with_invite_only",                     :default => false
    t.boolean  "use_captcha",                               :default => true
    t.boolean  "email_confirmation",                        :default => false
    t.text     "allowed_emails"
    t.boolean  "users_can_invite_new_users",                :default => false
    t.boolean  "select_whether_name_is_shown_to_everybody", :default => false
    t.boolean  "news_enabled",                              :default => true
    t.boolean  "private",                                   :default => false
    t.string   "label"
    t.boolean  "all_users_can_add_news",                    :default => true
    t.boolean  "show_date_in_listings_list",                :default => false
    t.boolean  "custom_frontpage_sidebar",                  :default => false
    t.boolean  "event_feed_enabled",                        :default => true
    t.string   "slogan"
    t.text     "description"
    t.string   "category",                                  :default => "other"
    t.integer  "members_count",                             :default => 0
    t.boolean  "polls_enabled",                             :default => false
    t.string   "plan"
    t.integer  "user_limit"
    t.float    "monthly_price_in_euros"
  end

  create_table "communities_listings", :id => false, :force => true do |t|
    t.integer "community_id"
    t.integer "listing_id"
  end

  add_index "communities_listings", ["listing_id", "community_id"], :name => "communities_listings"

  create_table "community_memberships", :force => true do |t|
    t.string   "person_id"
    t.integer  "community_id"
    t.boolean  "admin",               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "consent"
    t.integer  "invitation_id"
    t.datetime "last_page_load_date"
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
    t.string   "status",     :default => "pending"
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
    t.string   "queue"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "devices", :force => true do |t|
    t.string   "person_id"
    t.string   "device_type"
    t.string   "device_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emails", :force => true do |t|
    t.string   "person_id"
    t.string   "address"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "confirmation_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emails", ["address"], :name => "index_emails_on_address", :unique => true

  create_table "event_feed_events", :force => true do |t|
    t.string   "person1_id"
    t.string   "person2_id"
    t.string   "community_id"
    t.integer  "eventable_id"
    t.string   "eventable_type"
    t.string   "category"
    t.boolean  "members_only",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "inviter_id"
    t.text     "message"
    t.string   "email"
  end

  create_table "item_reservations", :force => true do |t|
    t.integer  "item_id"
    t.integer  "reservation_id"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listing_followers", :id => false, :force => true do |t|
    t.string  "person_id"
    t.integer "listing_id"
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

  add_index "listing_images", ["listing_id"], :name => "index_listing_images_on_listing_id"

  create_table "listings", :force => true do |t|
    t.string   "author_id"
    t.string   "category"
    t.string   "title"
    t.integer  "times_viewed",  :default => 0
    t.string   "language"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_modified"
    t.string   "visibility",    :default => "this_community"
    t.string   "listing_type"
    t.text     "description"
    t.string   "origin"
    t.string   "destination"
    t.datetime "valid_until"
    t.boolean  "delta",         :default => true,             :null => false
    t.boolean  "open",          :default => true
    t.string   "share_type"
    t.string   "privacy",       :default => "private"
  end

  add_index "listings", ["listing_type"], :name => "index_listings_on_listing_type"
  add_index "listings", ["open"], :name => "index_listings_on_open"
  add_index "listings", ["visibility"], :name => "index_listings_on_visibility"

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
    t.integer  "community_id"
  end

  create_table "messages", :force => true do |t|
    t.string   "sender_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conversation_id"
  end

  create_table "news_items", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "community_id"
    t.string   "author_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", :force => true do |t|
    t.string   "receiver_id"
    t.string   "type"
    t.boolean  "is_read",         :default => false
    t.integer  "badge_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "testimonial_id"
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.string   "description"
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
    t.string   "id",                                 :limit => 22,                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_admin",                                         :default => 0
    t.string   "locale",                                           :default => "fi"
    t.text     "preferences"
    t.integer  "active_days_count",                                :default => 0
    t.datetime "last_page_load_date"
    t.integer  "test_group_number",                                :default => 1
    t.boolean  "active",                                           :default => true
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "show_real_name_to_other_users",                    :default => true
    t.string   "username"
    t.string   "email"
    t.string   "encrypted_password",                               :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                    :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "given_name"
    t.string   "family_name"
    t.string   "phone_number"
    t.text     "description"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "facebook_id"
    t.string   "authentication_token"
    t.datetime "community_updates_last_sent_at"
    t.integer  "min_days_between_community_updates",               :default => 1
  end

  add_index "people", ["confirmation_token"], :name => "index_people_on_confirmation_token", :unique => true
  add_index "people", ["email"], :name => "index_people_on_email", :unique => true
  add_index "people", ["facebook_id"], :name => "index_people_on_facebook_id", :unique => true
  add_index "people", ["reset_password_token"], :name => "index_people_on_reset_password_token", :unique => true
  add_index "people", ["username"], :name => "index_people_on_username", :unique => true

  create_table "poll_answers", :force => true do |t|
    t.integer  "poll_id"
    t.integer  "poll_option_id"
    t.string   "answerer_id"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "poll_options", :force => true do |t|
    t.string   "label"
    t.integer  "poll_id"
    t.float    "percentage", :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "polls", :force => true do |t|
    t.string   "title"
    t.string   "author_id"
    t.boolean  "active",       :default => true
    t.string   "community_id"
    t.datetime "closed_at"
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

  create_table "share_types", :force => true do |t|
    t.integer "listing_id"
    t.string  "name"
  end

  add_index "share_types", ["listing_id"], :name => "index_share_types_on_listing_id"

  create_table "statistics", :force => true do |t|
    t.integer  "community_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "users_count"
    t.float    "two_week_content_activation_percentage"
    t.float    "four_week_transaction_activation_percentage"
    t.float    "mau_g1"
    t.float    "wau_g1"
    t.float    "dau_g1"
    t.float    "mau_g2"
    t.float    "wau_g2"
    t.float    "dau_g2"
    t.float    "mau_g3"
    t.float    "wau_g3"
    t.float    "dau_g3"
    t.float    "invitations_sent_per_user"
    t.float    "invitations_accepted_per_user"
    t.float    "revenue_per_mau_g1"
    t.text     "extra_data"
    t.integer  "mau_g1_count"
    t.integer  "wau_g1_count"
    t.integer  "listings_count"
    t.integer  "new_listings_last_week"
    t.integer  "new_listings_last_month"
    t.integer  "conversations_count"
    t.integer  "new_conversations_last_week"
    t.integer  "new_conversations_last_month"
    t.integer  "messages_count"
    t.integer  "new_messages_last_week"
    t.integer  "new_messages_last_month"
    t.integer  "transactions_count"
    t.integer  "new_transactions_last_week"
    t.integer  "new_transactions_last_month"
    t.integer  "new_users_last_week"
    t.integer  "new_users_last_month"
    t.float    "user_count_weekly_growth"
    t.float    "wau_weekly_growth"
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

end

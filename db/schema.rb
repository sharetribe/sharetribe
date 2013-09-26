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

ActiveRecord::Schema.define(:version => 20130926070322) do

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

  add_index "badges", ["person_id"], :name => "index_badges_on_person_id"

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

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.string   "icon"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "categories", ["name"], :name => "index_categories_on_name"
  add_index "categories", ["parent_id"], :name => "index_categories_on_parent_id"

  create_table "category_translations", :force => true do |t|
    t.integer  "category_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
  end

  add_index "category_translations", ["category_id", "locale"], :name => "category_id_with_locale"
  add_index "category_translations", ["category_id"], :name => "index_category_translations_on_category_id"

  create_table "comments", :force => true do |t|
    t.string   "author_id"
    t.integer  "listing_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "community_id"
  end

  add_index "comments", ["listing_id"], :name => "index_comments_on_listing_id"

  create_table "communities", :force => true do |t|
    t.string   "name"
    t.string   "domain"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "settings"
    t.string   "consent"
    t.boolean  "email_admins_about_new_members", :default => false
    t.boolean  "use_fb_like",                    :default => false
    t.boolean  "real_name_required",             :default => true
    t.boolean  "feedback_to_admin",              :default => false
    t.boolean  "automatic_newsletters",          :default => true
    t.boolean  "join_with_invite_only",          :default => false
    t.boolean  "use_captcha",                    :default => true
    t.boolean  "email_confirmation",             :default => false
    t.text     "allowed_emails"
    t.boolean  "users_can_invite_new_users",     :default => false
    t.boolean  "news_enabled",                   :default => true
    t.boolean  "private",                        :default => false
    t.string   "label"
    t.boolean  "all_users_can_add_news",         :default => true
    t.boolean  "show_date_in_listings_list",     :default => false
    t.boolean  "custom_frontpage_sidebar",       :default => false
    t.boolean  "event_feed_enabled",             :default => true
    t.string   "slogan"
    t.text     "description"
    t.string   "category",                       :default => "other"
    t.integer  "members_count",                  :default => 0
    t.boolean  "polls_enabled",                  :default => false
    t.string   "plan"
    t.integer  "user_limit"
    t.float    "monthly_price_in_euros"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "cover_photo_file_name"
    t.string   "cover_photo_content_type"
    t.integer  "cover_photo_file_size"
    t.datetime "cover_photo_updated_at"
    t.string   "custom_color1"
    t.string   "custom_color2"
    t.string   "stylesheet_url"
    t.string   "service_logo_style",             :default => "full-logo"
    t.boolean  "payments_in_use",                :default => false
    t.text     "available_currencies"
    t.boolean  "facebook_connect_enabled",       :default => true
    t.integer  "vat"
    t.integer  "commission_percentage"
    t.boolean  "only_public_listings",           :default => true
    t.string   "custom_email_from_address"
    t.integer  "minimum_price_cents"
    t.boolean  "badges_in_use",                  :default => false
    t.boolean  "testimonials_in_use",            :default => true
    t.boolean  "hide_expiration_date",           :default => false
    t.string   "facebook_connect_id"
    t.string   "facebook_connect_secret"
    t.string   "google_analytics_key"
    t.string   "favicon_url"
    t.string   "name_display_type",              :default => "first_name_with_initial"
    t.string   "twitter_handle"
  end

  add_index "communities", ["domain"], :name => "index_communities_on_domain"

  create_table "communities_listings", :id => false, :force => true do |t|
    t.integer "community_id"
    t.integer "listing_id"
  end

  add_index "communities_listings", ["community_id"], :name => "index_communities_listings_on_community_id"
  add_index "communities_listings", ["listing_id", "community_id"], :name => "communities_listings"

  create_table "communities_payment_gateways", :id => false, :force => true do |t|
    t.integer "community_id"
    t.integer "payment_gateway_id"
  end

  add_index "communities_payment_gateways", ["community_id"], :name => "index_communities_payment_gateways_on_community_id"

  create_table "community_categories", :force => true do |t|
    t.integer  "community_id"
    t.integer  "category_id"
    t.integer  "share_type_id"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.boolean  "price",                      :default => false
    t.string   "price_quantity_placeholder"
    t.boolean  "payment",                    :default => false
    t.integer  "sort_priority",              :default => 0
  end

  add_index "community_categories", ["community_id", "category_id"], :name => "community_categories"

  create_table "community_customizations", :force => true do |t|
    t.integer  "community_id"
    t.string   "locale"
    t.string   "slogan"
    t.text     "description"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.text     "blank_slate"
    t.text     "welcome_email_content"
    t.text     "how_to_use"
    t.text     "custom_head_script"
    t.text     "about_page_content"
  end

  add_index "community_customizations", ["community_id"], :name => "index_community_customizations_on_community_id"

  create_table "community_memberships", :force => true do |t|
    t.string   "person_id"
    t.integer  "community_id"
    t.boolean  "admin",               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "consent"
    t.integer  "invitation_id"
    t.datetime "last_page_load_date"
    t.string   "status",              :default => "accepted", :null => false
  end

  add_index "community_memberships", ["community_id"], :name => "index_community_memberships_on_community_id"
  add_index "community_memberships", ["person_id", "community_id"], :name => "memberships"

  create_table "contact_requests", :force => true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country"
    t.string   "plan_type"
    t.string   "marketplace_type"
  end

  create_table "conversations", :force => true do |t|
    t.string   "title"
    t.integer  "listing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",          :default => "pending"
    t.datetime "last_message_at"
    t.integer  "community_id"
  end

  create_table "country_managers", :force => true do |t|
    t.string   "given_name"
    t.string   "family_name"
    t.string   "email"
    t.string   "country"
    t.string   "locale"
    t.text     "email_signature"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
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
  add_index "emails", ["person_id"], :name => "index_emails_on_person_id"

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

  add_index "event_feed_events", ["community_id"], :name => "index_event_feed_events_on_community_id"

  create_table "feedbacks", :force => true do |t|
    t.text     "content"
    t.string   "author_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_handled",   :default => 0
    t.string   "email"
    t.integer  "community_id"
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

  add_index "invitations", ["code"], :name => "index_invitations_on_code"
  add_index "invitations", ["inviter_id"], :name => "index_invitations_on_inviter_id"

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

  add_index "listing_followers", ["listing_id"], :name => "index_listing_followers_on_listing_id"
  add_index "listing_followers", ["person_id"], :name => "index_listing_followers_on_person_id"

  create_table "listing_images", :force => true do |t|
    t.integer  "listing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "image_processing"
  end

  add_index "listing_images", ["listing_id"], :name => "index_listing_images_on_listing_id"

  create_table "listings", :force => true do |t|
    t.string   "author_id"
    t.string   "category_old"
    t.string   "title"
    t.integer  "times_viewed",     :default => 0
    t.string   "language"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_modified"
    t.string   "visibility",       :default => "this_community"
    t.string   "listing_type_old"
    t.text     "description"
    t.string   "origin"
    t.string   "destination"
    t.datetime "valid_until"
    t.boolean  "delta",            :default => true,             :null => false
    t.boolean  "open",             :default => true
    t.string   "share_type_old"
    t.string   "privacy",          :default => "private"
    t.integer  "comments_count",   :default => 0
    t.string   "subcategory_old"
    t.integer  "category_id"
    t.integer  "share_type_id"
    t.integer  "organization_id"
    t.integer  "price_cents"
    t.string   "currency"
    t.string   "quantity"
  end

  add_index "listings", ["category_id"], :name => "index_listings_on_category_id"
  add_index "listings", ["listing_type_old"], :name => "index_listings_on_listing_type"
  add_index "listings", ["open"], :name => "index_listings_on_open"
  add_index "listings", ["share_type_id"], :name => "index_listings_on_share_type_id"
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

  add_index "locations", ["community_id"], :name => "index_locations_on_community_id"
  add_index "locations", ["listing_id"], :name => "index_locations_on_listing_id"
  add_index "locations", ["person_id"], :name => "index_locations_on_person_id"

  create_table "mercury_images", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "messages", :force => true do |t|
    t.string   "sender_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conversation_id"
    t.string   "action"
  end

  add_index "messages", ["conversation_id"], :name => "index_messages_on_conversation_id"

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

  add_index "notifications", ["receiver_id"], :name => "index_notifications_on_receiver_id"

  create_table "organization_memberships", :force => true do |t|
    t.string   "person_id"
    t.integer  "organization_id"
    t.boolean  "admin",           :default => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "organization_memberships", ["person_id"], :name => "index_organization_memberships_on_person_id"

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "company_id"
    t.string   "merchant_id"
    t.string   "merchant_key"
    t.string   "allowed_emails"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
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

  add_index "participations", ["conversation_id"], :name => "index_participations_on_conversation_id"
  add_index "participations", ["person_id"], :name => "index_participations_on_person_id"

  create_table "payment_gateways", :force => true do |t|
    t.string   "type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "payment_rows", :force => true do |t|
    t.integer  "payment_id"
    t.integer  "vat"
    t.integer  "sum_cents"
    t.string   "currency"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "title"
  end

  add_index "payment_rows", ["payment_id"], :name => "index_payment_rows_on_payment_id"

  create_table "payments", :force => true do |t|
    t.string   "payer_id"
    t.string   "recipient_id"
    t.string   "organization_id"
    t.integer  "conversation_id"
    t.string   "status"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "community_id"
  end

  add_index "payments", ["conversation_id"], :name => "index_payments_on_conversation_id"
  add_index "payments", ["payer_id"], :name => "index_payments_on_payer_id"

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
    t.string   "mangopay_id"
    t.string   "bank_account_owner_name"
    t.string   "bank_account_owner_address"
    t.string   "iban"
    t.string   "bic"
    t.string   "mangopay_beneficiary_id"
  end

  add_index "people", ["confirmation_token"], :name => "index_people_on_confirmation_token", :unique => true
  add_index "people", ["email"], :name => "index_people_on_email", :unique => true
  add_index "people", ["facebook_id"], :name => "index_people_on_facebook_id", :unique => true
  add_index "people", ["id"], :name => "index_people_on_id"
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

  create_table "share_type_translations", :force => true do |t|
    t.integer  "share_type_id"
    t.string   "locale"
    t.string   "name"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.string   "description"
    t.string   "transaction_button_text"
  end

  add_index "share_type_translations", ["share_type_id", "locale"], :name => "share_type_id_with_locale"
  add_index "share_type_translations", ["share_type_id"], :name => "index_share_type_translations_on_share_type_id"

  create_table "share_types", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.string   "icon"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "transaction_type"
  end

  add_index "share_types", ["name"], :name => "index_share_types_on_name"
  add_index "share_types", ["parent_id"], :name => "index_share_types_on_parent_id"

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

  add_index "statistics", ["community_id"], :name => "index_statistics_on_community_id"

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

  add_index "testimonials", ["receiver_id"], :name => "index_testimonials_on_receiver_id"

end

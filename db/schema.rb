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

ActiveRecord::Schema.define(:version => 20150121130521) do

  create_table "auth_tokens", :force => true do |t|
    t.string   "token"
    t.string   "token_type",       :default => "unsubscribe"
    t.string   "person_id"
    t.datetime "expires_at"
    t.integer  "usages_left"
    t.datetime "last_use_attempt"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "auth_tokens", ["token"], :name => "index_auth_tokens_on_token", :unique => true

  create_table "billing_agreements", :force => true do |t|
    t.integer  "paypal_account_id",    :null => false
    t.string   "billing_agreement_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.string   "paypal_username_to",   :null => false
    t.string   "request_token",        :null => false
  end

  create_table "bookings", :force => true do |t|
    t.integer  "transaction_id"
    t.date     "start_on"
    t.date     "end_on"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "braintree_accounts", :force => true do |t|
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "person_id"
    t.string   "email"
    t.string   "phone"
    t.string   "address_street_address"
    t.string   "address_postal_code"
    t.string   "address_locality"
    t.string   "address_region"
    t.date     "date_of_birth"
    t.string   "routing_number"
    t.string   "hidden_account_number"
    t.string   "status"
    t.integer  "community_id"
  end

  create_table "categories", :force => true do |t|
    t.integer  "parent_id"
    t.string   "icon"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "community_id"
    t.integer  "sort_priority"
    t.string   "url"
  end

  add_index "categories", ["parent_id"], :name => "index_categories_on_parent_id"
  add_index "categories", ["url"], :name => "index_categories_on_url"

  create_table "category_custom_fields", :force => true do |t|
    t.integer  "category_id"
    t.integer  "custom_field_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "category_transaction_types", :force => true do |t|
    t.integer  "category_id"
    t.integer  "transaction_type_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "category_transaction_types", ["category_id"], :name => "index_category_transaction_types_on_category_id"
  add_index "category_transaction_types", ["transaction_type_id"], :name => "index_category_transaction_types_on_transaction_type_id"

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

  create_table "checkout_accounts", :force => true do |t|
    t.string   "company_id_or_personal_id"
    t.string   "merchant_id",               :null => false
    t.string   "merchant_key",              :null => false
    t.string   "person_id",                 :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

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
    t.boolean  "transaction_agreement_in_use",               :default => false
    t.boolean  "email_admins_about_new_members",             :default => false
    t.boolean  "use_fb_like",                                :default => false
    t.boolean  "real_name_required",                         :default => true
    t.boolean  "feedback_to_admin",                          :default => true
    t.boolean  "automatic_newsletters",                      :default => true
    t.boolean  "join_with_invite_only",                      :default => false
    t.boolean  "use_captcha",                                :default => false
    t.text     "allowed_emails"
    t.boolean  "users_can_invite_new_users",                 :default => true
    t.boolean  "private",                                    :default => false
    t.string   "label"
    t.boolean  "show_date_in_listings_list",                 :default => false
    t.boolean  "all_users_can_add_news",                     :default => true
    t.boolean  "custom_frontpage_sidebar",                   :default => false
    t.boolean  "event_feed_enabled",                         :default => true
    t.string   "slogan"
    t.text     "description"
    t.string   "category",                                   :default => "other"
    t.string   "country"
    t.integer  "members_count",                              :default => 0
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
    t.string   "small_cover_photo_file_name"
    t.string   "small_cover_photo_content_type"
    t.integer  "small_cover_photo_file_size"
    t.datetime "small_cover_photo_updated_at"
    t.string   "custom_color1"
    t.string   "custom_color2"
    t.string   "stylesheet_url"
    t.boolean  "stylesheet_needs_recompile",                 :default => false
    t.string   "service_logo_style",                         :default => "full-logo"
    t.text     "available_currencies"
    t.boolean  "facebook_connect_enabled",                   :default => true
    t.boolean  "only_public_listings",                       :default => true
    t.string   "custom_email_from_address"
    t.integer  "vat"
    t.integer  "commission_from_seller"
    t.integer  "minimum_price_cents"
    t.boolean  "testimonials_in_use",                        :default => true
    t.boolean  "hide_expiration_date",                       :default => false
    t.string   "facebook_connect_id"
    t.string   "facebook_connect_secret"
    t.string   "google_analytics_key"
    t.string   "name_display_type",                          :default => "first_name_with_initial"
    t.string   "twitter_handle"
    t.boolean  "use_community_location_as_default",          :default => false
    t.string   "domain_alias"
    t.string   "preproduction_stylesheet_url"
    t.boolean  "show_category_in_listing_list",              :default => false
    t.string   "default_browse_view",                        :default => "grid"
    t.string   "wide_logo_file_name"
    t.string   "wide_logo_content_type"
    t.integer  "wide_logo_file_size"
    t.datetime "wide_logo_updated_at"
    t.boolean  "only_organizations"
    t.boolean  "listing_comments_in_use",                    :default => false
    t.boolean  "show_listing_publishing_date",               :default => false
    t.boolean  "require_verification_to_post_listings",      :default => false
    t.boolean  "show_price_filter",                          :default => false
    t.integer  "price_filter_min",                           :default => 0
    t.integer  "price_filter_max",                           :default => 100000
    t.integer  "automatic_confirmation_after_days",          :default => 14
    t.string   "favicon_file_name"
    t.string   "favicon_content_type"
    t.integer  "favicon_file_size"
    t.datetime "favicon_updated_at"
    t.integer  "default_min_days_between_community_updates", :default => 7
    t.boolean  "listing_location_required",                  :default => false
    t.text     "custom_head_script"
    t.boolean  "follow_in_use",                              :default => true,                      :null => false
    t.boolean  "logo_processing"
    t.boolean  "wide_logo_processing"
    t.boolean  "cover_photo_processing"
    t.boolean  "small_cover_photo_processing"
    t.boolean  "favicon_processing"
  end

  add_index "communities", ["domain"], :name => "index_communities_on_domain"

  create_table "communities_listings", :id => false, :force => true do |t|
    t.integer "community_id"
    t.integer "listing_id"
  end

  add_index "communities_listings", ["community_id"], :name => "index_communities_listings_on_community_id"
  add_index "communities_listings", ["listing_id", "community_id"], :name => "communities_listings"

  create_table "community_customizations", :force => true do |t|
    t.integer  "community_id"
    t.string   "locale"
    t.string   "name"
    t.string   "slogan"
    t.text     "description"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.text     "blank_slate"
    t.text     "welcome_email_content"
    t.text     "how_to_use_page_content"
    t.text     "about_page_content"
    t.text     "terms_page_content",                         :limit => 16777215
    t.text     "privacy_page_content"
    t.string   "storefront_label"
    t.text     "signup_info_content"
    t.text     "private_community_homepage_content"
    t.text     "verification_to_post_listings_info_content"
    t.string   "search_placeholder"
    t.string   "transaction_agreement_label"
    t.text     "transaction_agreement_content",              :limit => 16777215
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
    t.boolean  "can_post_listings",   :default => false
  end

  add_index "community_memberships", ["community_id"], :name => "index_community_memberships_on_community_id"
  add_index "community_memberships", ["person_id", "community_id"], :name => "memberships"

  create_table "community_plans", :force => true do |t|
    t.integer  "community_id",                :null => false
    t.integer  "plan_level",   :default => 0, :null => false
    t.datetime "expires_at"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

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
    t.datetime "last_message_at"
    t.integer  "community_id"
  end

  add_index "conversations", ["community_id"], :name => "index_conversations_on_community_id"
  add_index "conversations", ["last_message_at"], :name => "index_conversations_on_last_message_at"
  add_index "conversations", ["listing_id"], :name => "index_conversations_on_listing_id"

  create_table "custom_field_names", :force => true do |t|
    t.string   "value"
    t.string   "locale"
    t.string   "custom_field_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "custom_field_names", ["custom_field_id", "locale"], :name => "locale_index"
  add_index "custom_field_names", ["custom_field_id"], :name => "index_custom_field_names_on_custom_field_id"

  create_table "custom_field_option_selections", :force => true do |t|
    t.integer  "custom_field_value_id"
    t.integer  "custom_field_option_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  add_index "custom_field_option_selections", ["custom_field_value_id"], :name => "index_selected_options_on_custom_field_value_id"

  create_table "custom_field_option_titles", :force => true do |t|
    t.string   "value"
    t.string   "locale"
    t.integer  "custom_field_option_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  add_index "custom_field_option_titles", ["custom_field_option_id", "locale"], :name => "locale_index"
  add_index "custom_field_option_titles", ["custom_field_option_id"], :name => "index_custom_field_option_titles_on_custom_field_option_id"

  create_table "custom_field_options", :force => true do |t|
    t.integer  "custom_field_id"
    t.integer  "sort_priority"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "custom_field_options", ["custom_field_id"], :name => "index_custom_field_options_on_custom_field_id"

  create_table "custom_field_values", :force => true do |t|
    t.integer  "custom_field_id"
    t.integer  "listing_id"
    t.text     "text_value"
    t.float    "numeric_value"
    t.datetime "date_value"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "type"
    t.boolean  "delta",           :default => true, :null => false
  end

  add_index "custom_field_values", ["listing_id"], :name => "index_custom_field_values_on_listing_id"

  create_table "custom_fields", :force => true do |t|
    t.string   "type"
    t.integer  "sort_priority"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "community_id"
    t.boolean  "required",       :default => true
    t.float    "min"
    t.float    "max"
    t.boolean  "allow_decimals", :default => false
  end

  add_index "custom_fields", ["community_id"], :name => "index_custom_fields_on_community_id"

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

  create_table "emails", :force => true do |t|
    t.string   "person_id"
    t.string   "address"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "confirmation_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "send_notifications"
  end

  add_index "emails", ["address"], :name => "index_emails_on_address", :unique => true
  add_index "emails", ["person_id"], :name => "index_emails_on_person_id"

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

  create_table "follower_relationships", :force => true do |t|
    t.string   "person_id",   :null => false
    t.string   "follower_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "follower_relationships", ["follower_id"], :name => "index_follower_relationships_on_follower_id"
  add_index "follower_relationships", ["person_id", "follower_id"], :name => "index_follower_relationships_on_person_id_and_follower_id", :unique => true
  add_index "follower_relationships", ["person_id"], :name => "index_follower_relationships_on_person_id"

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
    t.boolean  "image_downloaded",   :default => false
    t.integer  "width"
    t.integer  "height"
    t.string   "author_id"
  end

  add_index "listing_images", ["listing_id"], :name => "index_listing_images_on_listing_id"

  create_table "listings", :force => true do |t|
    t.string   "author_id"
    t.string   "category_old"
    t.string   "title"
    t.integer  "times_viewed",        :default => 0
    t.string   "language"
    t.datetime "created_at"
    t.datetime "updates_email_at"
    t.datetime "updated_at"
    t.datetime "last_modified"
    t.datetime "sort_date"
    t.string   "visibility",          :default => "this_community"
    t.string   "listing_type_old"
    t.text     "description"
    t.string   "origin"
    t.string   "destination"
    t.datetime "valid_until"
    t.boolean  "delta",               :default => true,             :null => false
    t.boolean  "open",                :default => true
    t.string   "share_type_old"
    t.string   "privacy",             :default => "private"
    t.integer  "comments_count",      :default => 0
    t.string   "subcategory_old"
    t.integer  "old_category_id"
    t.integer  "category_id"
    t.integer  "share_type_id"
    t.integer  "transaction_type_id"
    t.integer  "organization_id"
    t.integer  "price_cents"
    t.string   "currency"
    t.string   "quantity"
    t.boolean  "deleted",             :default => false
  end

  add_index "listings", ["listing_type_old"], :name => "index_listings_on_listing_type"
  add_index "listings", ["old_category_id"], :name => "index_listings_on_category_id"
  add_index "listings", ["open"], :name => "index_listings_on_open"
  add_index "listings", ["share_type_id"], :name => "index_listings_on_share_type_id"
  add_index "listings", ["transaction_type_id"], :name => "index_listings_on_transaction_type_id"
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

  create_table "menu_link_translations", :force => true do |t|
    t.integer  "menu_link_id"
    t.string   "locale"
    t.string   "url"
    t.string   "title"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "menu_links", :force => true do |t|
    t.integer  "community_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "sort_priority", :default => 0
  end

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
  end

  add_index "messages", ["conversation_id"], :name => "index_messages_on_conversation_id"

  create_table "order_permissions", :force => true do |t|
    t.integer  "paypal_account_id",  :null => false
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "request_token",      :null => false
    t.string   "paypal_username_to", :null => false
    t.string   "scope"
    t.string   "verification_code"
  end

  create_table "participations", :force => true do |t|
    t.string   "person_id"
    t.integer  "conversation_id"
    t.boolean  "is_read",          :default => false
    t.boolean  "is_starter",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_sent_at"
    t.datetime "last_received_at"
    t.boolean  "feedback_skipped", :default => false
  end

  add_index "participations", ["conversation_id"], :name => "index_participations_on_conversation_id"
  add_index "participations", ["person_id"], :name => "index_participations_on_person_id"

  create_table "payment_gateways", :force => true do |t|
    t.integer  "community_id"
    t.string   "type"
    t.string   "braintree_environment"
    t.string   "braintree_merchant_id"
    t.string   "braintree_master_merchant_id"
    t.string   "braintree_public_key"
    t.string   "braintree_private_key"
    t.text     "braintree_client_side_encryption_key"
    t.string   "checkout_environment"
    t.string   "checkout_user_id"
    t.string   "checkout_password"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
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

  create_table "payment_settings", :force => true do |t|
    t.boolean  "active",                                :null => false
    t.integer  "community_id",                          :null => false
    t.string   "payment_gateway",         :limit => 64
    t.string   "payment_process",         :limit => 64
    t.integer  "commission_from_seller"
    t.integer  "minimum_price_cents"
    t.integer  "confirmation_after_days",               :null => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  add_index "payment_settings", ["community_id"], :name => "index_payment_settings_on_community_id"

  create_table "payments", :force => true do |t|
    t.string   "payer_id"
    t.string   "recipient_id"
    t.string   "organization_id"
    t.integer  "transaction_id"
    t.string   "status"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.integer  "community_id"
    t.integer  "payment_gateway_id"
    t.integer  "sum_cents"
    t.string   "currency"
    t.string   "type",                     :default => "CheckoutPayment"
    t.string   "braintree_transaction_id"
  end

  add_index "payments", ["payer_id"], :name => "index_payments_on_payer_id"
  add_index "payments", ["transaction_id"], :name => "index_payments_on_conversation_id"

  create_table "paypal_accounts", :force => true do |t|
    t.string   "person_id"
    t.integer  "community_id"
    t.string   "email"
    t.string   "payer_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.boolean  "active"
  end

  add_index "paypal_accounts", ["community_id"], :name => "index_paypal_accounts_on_community_id"
  add_index "paypal_accounts", ["payer_id"], :name => "index_paypal_accounts_on_payer_id"
  add_index "paypal_accounts", ["person_id"], :name => "index_paypal_accounts_on_person_id"

  create_table "paypal_ipn_messages", :force => true do |t|
    t.text     "body"
    t.string   "status",     :limit => 64
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "paypal_payments", :force => true do |t|
    t.integer  "community_id",                                                        :null => false
    t.integer  "transaction_id",                                                      :null => false
    t.string   "payer_id",                   :limit => 64,                            :null => false
    t.string   "receiver_id",                :limit => 64,                            :null => false
    t.string   "order_id",                   :limit => 64,                            :null => false
    t.datetime "order_date",                                                          :null => false
    t.string   "currency",                   :limit => 8,                             :null => false
    t.integer  "order_total_cents",                                                   :null => false
    t.string   "authorization_id",           :limit => 64
    t.datetime "authorization_date"
    t.datetime "authorization_expires_date"
    t.integer  "authorization_total_cents"
    t.string   "payment_id",                 :limit => 64
    t.datetime "payment_date"
    t.integer  "payment_total_cents"
    t.integer  "fee_total_cents"
    t.string   "payment_status",             :limit => 64,                            :null => false
    t.string   "pending_reason",             :limit => 64
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.string   "commission_payment_id",      :limit => 64
    t.datetime "commission_payment_date"
    t.string   "commission_status",          :limit => 64, :default => "not_charged", :null => false
    t.string   "commission_pending_reason",  :limit => 64
    t.integer  "commission_total_cents"
    t.integer  "commission_fee_total_cents"
  end

  add_index "paypal_payments", ["authorization_id"], :name => "index_paypal_payments_on_authorization_id", :unique => true
  add_index "paypal_payments", ["community_id"], :name => "index_paypal_payments_on_community_id"
  add_index "paypal_payments", ["order_id"], :name => "index_paypal_payments_on_order_id", :unique => true
  add_index "paypal_payments", ["transaction_id"], :name => "index_paypal_payments_on_transaction_id", :unique => true

  create_table "paypal_process_tokens", :force => true do |t|
    t.string   "process_token",  :limit => 64,                    :null => false
    t.integer  "community_id",                                    :null => false
    t.integer  "transaction_id",                                  :null => false
    t.boolean  "op_completed",                 :default => false, :null => false
    t.string   "op_name",        :limit => 64,                    :null => false
    t.text     "op_input"
    t.text     "op_output"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "paypal_process_tokens", ["process_token"], :name => "index_paypal_process_tokens_on_process_token", :unique => true
  add_index "paypal_process_tokens", ["transaction_id", "community_id", "op_name"], :name => "index_paypal_process_tokens_on_transaction", :unique => true

  create_table "paypal_refunds", :force => true do |t|
    t.integer  "paypal_payment_id"
    t.string   "currency",            :limit => 8
    t.integer  "payment_total_cents"
    t.integer  "fee_total_cents"
    t.string   "refunding_id",        :limit => 64
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "paypal_refunds", ["refunding_id"], :name => "index_paypal_refunds_on_refunding_id", :unique => true

  create_table "paypal_tokens", :force => true do |t|
    t.integer  "community_id",                       :null => false
    t.string   "token",                :limit => 64
    t.integer  "transaction_id"
    t.string   "merchant_id",                        :null => false
    t.datetime "created_at"
    t.string   "item_name"
    t.integer  "item_quantity"
    t.integer  "item_price_cents"
    t.string   "currency",             :limit => 8
    t.string   "express_checkout_url"
  end

  add_index "paypal_tokens", ["community_id"], :name => "index_paypal_tokens_on_community_id"
  add_index "paypal_tokens", ["token"], :name => "index_paypal_tokens_on_token", :unique => true
  add_index "paypal_tokens", ["transaction_id"], :name => "index_paypal_tokens_on_transaction_id"

  create_table "people", :id => false, :force => true do |t|
    t.string   "id",                                 :limit => 22,                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_admin",                                         :default => 0
    t.string   "locale",                                           :default => "fi"
    t.text     "preferences"
    t.integer  "active_days_count",                                :default => 0
    t.datetime "last_page_load_date"
    t.integer  "test_group_number",                                :default => 1
    t.boolean  "active",                                           :default => true
    t.string   "username"
    t.string   "email"
    t.string   "encrypted_password",                               :default => "",    :null => false
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
    t.boolean  "is_organization"
    t.string   "organization_name"
    t.boolean  "deleted",                                          :default => false
  end

  add_index "people", ["email"], :name => "index_people_on_email", :unique => true
  add_index "people", ["facebook_id"], :name => "index_people_on_facebook_id", :unique => true
  add_index "people", ["id"], :name => "index_people_on_id"
  add_index "people", ["reset_password_token"], :name => "index_people_on_reset_password_token", :unique => true
  add_index "people", ["username"], :name => "index_people_on_username", :unique => true

  create_table "prospect_emails", :force => true do |t|
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "testimonials", :force => true do |t|
    t.float    "grade"
    t.text     "text"
    t.string   "author_id"
    t.integer  "participation_id"
    t.integer  "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "receiver_id"
  end

  add_index "testimonials", ["author_id"], :name => "index_testimonials_on_author_id"
  add_index "testimonials", ["receiver_id"], :name => "index_testimonials_on_receiver_id"
  add_index "testimonials", ["transaction_id"], :name => "index_testimonials_on_transaction_id"

  create_table "transaction_transitions", :force => true do |t|
    t.string   "to_state"
    t.text     "metadata"
    t.integer  "sort_key",       :default => 0
    t.integer  "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transaction_transitions", ["sort_key", "transaction_id"], :name => "index_transaction_transitions_on_sort_key_and_conversation_id", :unique => true
  add_index "transaction_transitions", ["transaction_id"], :name => "index_transaction_transitions_on_conversation_id"

  create_table "transaction_type_translations", :force => true do |t|
    t.integer  "transaction_type_id"
    t.string   "locale"
    t.string   "name"
    t.string   "action_button_label"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "transaction_type_translations", ["transaction_type_id", "locale"], :name => "locale_index"
  add_index "transaction_type_translations", ["transaction_type_id"], :name => "index_transaction_type_translations_on_transaction_type_id"

  create_table "transaction_types", :force => true do |t|
    t.string   "type"
    t.integer  "community_id"
    t.integer  "sort_priority"
    t.boolean  "price_field"
    t.boolean  "preauthorize_payment",       :default => false
    t.string   "price_quantity_placeholder"
    t.string   "price_per"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "url"
  end

  add_index "transaction_types", ["community_id"], :name => "index_transaction_types_on_community_id"
  add_index "transaction_types", ["url"], :name => "index_transaction_types_on_url"

  create_table "transactions", :force => true do |t|
    t.string   "starter_id",                                                          :null => false
    t.integer  "listing_id",                                                          :null => false
    t.integer  "conversation_id"
    t.integer  "automatic_confirmation_after_days"
    t.integer  "community_id",                                                        :null => false
    t.datetime "created_at",                                                          :null => false
    t.datetime "updated_at",                                                          :null => false
    t.boolean  "starter_skipped_feedback",                        :default => false
    t.boolean  "author_skipped_feedback",                         :default => false
    t.datetime "last_transition_at"
    t.string   "current_state"
    t.integer  "commission_from_seller"
    t.integer  "minimum_commission_cents",                        :default => 0
    t.string   "minimum_commission_currency"
    t.string   "payment_gateway",                                 :default => "none", :null => false
    t.integer  "listing_quantity",                                :default => 1
    t.string   "payment_process",                   :limit => 31, :default => "none"
  end

  add_index "transactions", ["community_id"], :name => "index_transactions_on_community_id"
  add_index "transactions", ["conversation_id"], :name => "index_transactions_on_conversation_id"
  add_index "transactions", ["last_transition_at"], :name => "index_transactions_on_last_transition_at"
  add_index "transactions", ["listing_id"], :name => "index_transactions_on_listing_id"

end

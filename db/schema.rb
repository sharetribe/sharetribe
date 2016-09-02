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

ActiveRecord::Schema.define(version: 20160902103712) do

  create_table "auth_tokens", force: :cascade do |t|
    t.string   "token",            limit: 255
    t.string   "token_type",       limit: 255, default: "unsubscribe"
    t.string   "person_id",        limit: 255
    t.datetime "expires_at"
    t.integer  "usages_left",      limit: 4
    t.datetime "last_use_attempt"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  add_index "auth_tokens", ["token"], name: "index_auth_tokens_on_token", unique: true, using: :btree

  create_table "billing_agreements", force: :cascade do |t|
    t.integer  "paypal_account_id",    limit: 4,   null: false
    t.string   "billing_agreement_id", limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "paypal_username_to",   limit: 255, null: false
    t.string   "request_token",        limit: 255, null: false
  end

  add_index "billing_agreements", ["paypal_account_id"], name: "index_billing_agreements_on_paypal_account_id", using: :btree

  create_table "bookings", force: :cascade do |t|
    t.integer  "transaction_id", limit: 4
    t.date     "start_on"
    t.date     "end_on"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "bookings", ["transaction_id"], name: "index_bookings_on_transaction_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.integer  "parent_id",     limit: 4
    t.string   "icon",          limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "community_id",  limit: 4
    t.integer  "sort_priority", limit: 4
    t.string   "url",           limit: 255
  end

  add_index "categories", ["community_id"], name: "index_categories_on_community_id", using: :btree
  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree
  add_index "categories", ["url"], name: "index_categories_on_url", using: :btree

  create_table "category_custom_fields", force: :cascade do |t|
    t.integer  "category_id",     limit: 4
    t.integer  "custom_field_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "category_listing_shapes", id: false, force: :cascade do |t|
    t.integer "category_id",      limit: 4, null: false
    t.integer "listing_shape_id", limit: 4, null: false
  end

  add_index "category_listing_shapes", ["category_id"], name: "index_category_listing_shapes_on_category_id", using: :btree
  add_index "category_listing_shapes", ["listing_shape_id", "category_id"], name: "unique_listing_shape_category_joins", unique: true, using: :btree

  create_table "category_translations", force: :cascade do |t|
    t.integer  "category_id", limit: 4
    t.string   "locale",      limit: 255
    t.string   "name",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "description", limit: 255
  end

  add_index "category_translations", ["category_id", "locale"], name: "category_id_with_locale", using: :btree
  add_index "category_translations", ["category_id"], name: "index_category_translations_on_category_id", using: :btree

  create_table "checkout_accounts", force: :cascade do |t|
    t.string   "company_id_or_personal_id", limit: 255
    t.string   "merchant_id",               limit: 255, null: false
    t.string   "merchant_key",              limit: 255, null: false
    t.string   "person_id",                 limit: 255, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "comments", force: :cascade do |t|
    t.string   "author_id",    limit: 255
    t.integer  "listing_id",   limit: 4
    t.text     "content",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "community_id", limit: 4
  end

  add_index "comments", ["listing_id"], name: "index_comments_on_listing_id", using: :btree

  create_table "communities", force: :cascade do |t|
    t.string   "ident",                                      limit: 255
    t.string   "domain",                                     limit: 255
    t.boolean  "use_domain",                                                  default: false,                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "settings",                                   limit: 65535
    t.string   "consent",                                    limit: 255
    t.boolean  "transaction_agreement_in_use",                                default: false
    t.boolean  "email_admins_about_new_members",                              default: false
    t.boolean  "use_fb_like",                                                 default: false
    t.boolean  "real_name_required",                                          default: true
    t.boolean  "automatic_newsletters",                                       default: true
    t.boolean  "join_with_invite_only",                                       default: false
    t.text     "allowed_emails",                             limit: 16777215
    t.boolean  "users_can_invite_new_users",                                  default: true
    t.boolean  "private",                                                     default: false
    t.string   "label",                                      limit: 255
    t.boolean  "show_date_in_listings_list",                                  default: false
    t.boolean  "all_users_can_add_news",                                      default: true
    t.boolean  "custom_frontpage_sidebar",                                    default: false
    t.boolean  "event_feed_enabled",                                          default: true
    t.string   "slogan",                                     limit: 255
    t.text     "description",                                limit: 65535
    t.string   "country",                                    limit: 255
    t.integer  "members_count",                              limit: 4,        default: 0
    t.integer  "user_limit",                                 limit: 4
    t.float    "monthly_price_in_euros",                     limit: 24
    t.string   "logo_file_name",                             limit: 255
    t.string   "logo_content_type",                          limit: 255
    t.integer  "logo_file_size",                             limit: 4
    t.datetime "logo_updated_at"
    t.string   "cover_photo_file_name",                      limit: 255
    t.string   "cover_photo_content_type",                   limit: 255
    t.integer  "cover_photo_file_size",                      limit: 4
    t.datetime "cover_photo_updated_at"
    t.string   "small_cover_photo_file_name",                limit: 255
    t.string   "small_cover_photo_content_type",             limit: 255
    t.integer  "small_cover_photo_file_size",                limit: 4
    t.datetime "small_cover_photo_updated_at"
    t.string   "custom_color1",                              limit: 255
    t.string   "custom_color2",                              limit: 255
    t.string   "stylesheet_url",                             limit: 255
    t.boolean  "stylesheet_needs_recompile",                                  default: false
    t.string   "service_logo_style",                         limit: 255,      default: "full-logo"
    t.text     "available_currencies",                       limit: 65535
    t.boolean  "facebook_connect_enabled",                                    default: true
    t.integer  "minimum_price_cents",                        limit: 4
    t.boolean  "hide_expiration_date",                                        default: false
    t.string   "facebook_connect_id",                        limit: 255
    t.string   "facebook_connect_secret",                    limit: 255
    t.string   "google_analytics_key",                       limit: 255
    t.string   "google_maps_key",                            limit: 64
    t.string   "name_display_type",                          limit: 255,      default: "first_name_with_initial"
    t.string   "twitter_handle",                             limit: 255
    t.boolean  "use_community_location_as_default",                           default: false
    t.string   "preproduction_stylesheet_url",               limit: 255
    t.boolean  "show_category_in_listing_list",                               default: false
    t.string   "default_browse_view",                        limit: 255,      default: "grid"
    t.string   "wide_logo_file_name",                        limit: 255
    t.string   "wide_logo_content_type",                     limit: 255
    t.integer  "wide_logo_file_size",                        limit: 4
    t.datetime "wide_logo_updated_at"
    t.boolean  "listing_comments_in_use",                                     default: false
    t.boolean  "show_listing_publishing_date",                                default: false
    t.boolean  "require_verification_to_post_listings",                       default: false
    t.boolean  "show_price_filter",                                           default: false
    t.integer  "price_filter_min",                           limit: 4,        default: 0
    t.integer  "price_filter_max",                           limit: 4,        default: 100000
    t.integer  "automatic_confirmation_after_days",          limit: 4,        default: 14
    t.string   "favicon_file_name",                          limit: 255
    t.string   "favicon_content_type",                       limit: 255
    t.integer  "favicon_file_size",                          limit: 4
    t.datetime "favicon_updated_at"
    t.integer  "default_min_days_between_community_updates", limit: 4,        default: 7
    t.boolean  "listing_location_required",                                   default: false
    t.text     "custom_head_script",                         limit: 65535
    t.boolean  "follow_in_use",                                               default: true,                      null: false
    t.boolean  "logo_processing"
    t.boolean  "wide_logo_processing"
    t.boolean  "cover_photo_processing"
    t.boolean  "small_cover_photo_processing"
    t.boolean  "favicon_processing"
    t.string   "dv_test_file_name",                          limit: 64
    t.string   "dv_test_file",                               limit: 64
    t.boolean  "deleted"
  end

  add_index "communities", ["domain"], name: "index_communities_on_domain", using: :btree
  add_index "communities", ["ident"], name: "index_communities_on_ident", using: :btree

  create_table "community_customizations", force: :cascade do |t|
    t.integer  "community_id",                               limit: 4
    t.string   "locale",                                     limit: 255
    t.string   "name",                                       limit: 255
    t.string   "slogan",                                     limit: 255
    t.text     "description",                                limit: 65535
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.text     "blank_slate",                                limit: 65535
    t.text     "welcome_email_content",                      limit: 65535
    t.text     "how_to_use_page_content",                    limit: 16777215
    t.text     "about_page_content",                         limit: 16777215
    t.text     "terms_page_content",                         limit: 16777215
    t.text     "privacy_page_content",                       limit: 16777215
    t.string   "storefront_label",                           limit: 255
    t.text     "signup_info_content",                        limit: 65535
    t.text     "private_community_homepage_content",         limit: 16777215
    t.text     "verification_to_post_listings_info_content", limit: 16777215
    t.string   "search_placeholder",                         limit: 255
    t.string   "transaction_agreement_label",                limit: 255
    t.text     "transaction_agreement_content",              limit: 16777215
  end

  add_index "community_customizations", ["community_id"], name: "index_community_customizations_on_community_id", using: :btree

  create_table "community_memberships", force: :cascade do |t|
    t.string   "person_id",           limit: 255,                      null: false
    t.integer  "community_id",        limit: 4,                        null: false
    t.boolean  "admin",                           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "consent",             limit: 255
    t.integer  "invitation_id",       limit: 4
    t.datetime "last_page_load_date"
    t.string   "status",              limit: 255, default: "accepted", null: false
    t.boolean  "can_post_listings",               default: false
  end

  add_index "community_memberships", ["community_id"], name: "index_community_memberships_on_community_id", using: :btree
  add_index "community_memberships", ["person_id"], name: "index_community_memberships_on_person_id", unique: true, using: :btree

  create_table "community_translations", force: :cascade do |t|
    t.integer  "community_id",    limit: 4,     null: false
    t.string   "locale",          limit: 16,    null: false
    t.string   "translation_key", limit: 255,   null: false
    t.text     "translation",     limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "community_translations", ["community_id"], name: "index_community_translations_on_community_id", using: :btree

  create_table "contact_requests", force: :cascade do |t|
    t.string   "email",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "country",          limit: 255
    t.string   "plan_type",        limit: 255
    t.string   "marketplace_type", limit: 255
  end

  create_table "conversations", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.integer  "listing_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_message_at"
    t.integer  "community_id",    limit: 4
  end

  add_index "conversations", ["community_id"], name: "index_conversations_on_community_id", using: :btree
  add_index "conversations", ["last_message_at"], name: "index_conversations_on_last_message_at", using: :btree
  add_index "conversations", ["listing_id"], name: "index_conversations_on_listing_id", using: :btree

  create_table "custom_field_names", force: :cascade do |t|
    t.string   "value",           limit: 255
    t.string   "locale",          limit: 255
    t.string   "custom_field_id", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "custom_field_names", ["custom_field_id", "locale"], name: "locale_index", using: :btree
  add_index "custom_field_names", ["custom_field_id"], name: "index_custom_field_names_on_custom_field_id", using: :btree

  create_table "custom_field_option_selections", force: :cascade do |t|
    t.integer  "custom_field_value_id",  limit: 4
    t.integer  "custom_field_option_id", limit: 4
    t.integer  "listing_id",             limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "custom_field_option_selections", ["custom_field_option_id"], name: "index_custom_field_option_selections_on_custom_field_option_id", using: :btree
  add_index "custom_field_option_selections", ["custom_field_value_id"], name: "index_selected_options_on_custom_field_value_id", using: :btree

  create_table "custom_field_option_titles", force: :cascade do |t|
    t.string   "value",                  limit: 255
    t.string   "locale",                 limit: 255
    t.integer  "custom_field_option_id", limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "custom_field_option_titles", ["custom_field_option_id", "locale"], name: "locale_index", using: :btree
  add_index "custom_field_option_titles", ["custom_field_option_id"], name: "index_custom_field_option_titles_on_custom_field_option_id", using: :btree

  create_table "custom_field_options", force: :cascade do |t|
    t.integer  "custom_field_id", limit: 4
    t.integer  "sort_priority",   limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "custom_field_options", ["custom_field_id"], name: "index_custom_field_options_on_custom_field_id", using: :btree

  create_table "custom_field_values", force: :cascade do |t|
    t.integer  "custom_field_id", limit: 4
    t.integer  "listing_id",      limit: 4
    t.text     "text_value",      limit: 65535
    t.float    "numeric_value",   limit: 24
    t.datetime "date_value"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "type",            limit: 255
    t.boolean  "delta",                         default: true, null: false
  end

  add_index "custom_field_values", ["listing_id"], name: "index_custom_field_values_on_listing_id", using: :btree
  add_index "custom_field_values", ["type"], name: "index_custom_field_values_on_type", using: :btree

  create_table "custom_fields", force: :cascade do |t|
    t.string   "type",           limit: 255
    t.integer  "sort_priority",  limit: 4
    t.boolean  "search_filter",              default: true,  null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "community_id",   limit: 4
    t.boolean  "required",                   default: true
    t.float    "min",            limit: 24
    t.float    "max",            limit: 24
    t.boolean  "allow_decimals",             default: false
  end

  add_index "custom_fields", ["community_id"], name: "index_custom_fields_on_community_id", using: :btree
  add_index "custom_fields", ["search_filter"], name: "index_custom_fields_on_search_filter", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "queue",      limit: 255
  end

  add_index "delayed_jobs", ["attempts", "run_at", "priority"], name: "index_delayed_jobs_on_attempts_and_run_at_and_priority", using: :btree
  add_index "delayed_jobs", ["locked_at", "created_at"], name: "index_delayed_jobs_on_locked_created", using: :btree
  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "emails", force: :cascade do |t|
    t.string   "person_id",            limit: 255
    t.integer  "community_id",         limit: 4,   null: false
    t.string   "address",              limit: 255, null: false
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "confirmation_token",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "send_notifications"
  end

  add_index "emails", ["address", "community_id"], name: "index_emails_on_address_and_community_id", unique: true, using: :btree
  add_index "emails", ["address"], name: "index_emails_on_address", using: :btree
  add_index "emails", ["community_id"], name: "index_emails_on_community_id", using: :btree
  add_index "emails", ["person_id"], name: "index_emails_on_person_id", using: :btree

  create_table "feature_flags", force: :cascade do |t|
    t.integer  "community_id", limit: 4,                  null: false
    t.string   "person_id",    limit: 255
    t.string   "feature",      limit: 255,                null: false
    t.boolean  "enabled",                  default: true, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "feature_flags", ["community_id", "person_id"], name: "index_feature_flags_on_community_id_and_person_id", using: :btree

  create_table "feedbacks", force: :cascade do |t|
    t.text     "content",      limit: 65535
    t.string   "author_id",    limit: 255
    t.string   "url",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_handled",   limit: 4,     default: 0
    t.string   "email",        limit: 255
    t.integer  "community_id", limit: 4
  end

  create_table "follower_relationships", force: :cascade do |t|
    t.string   "person_id",   limit: 255, null: false
    t.string   "follower_id", limit: 255, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "follower_relationships", ["follower_id"], name: "index_follower_relationships_on_follower_id", using: :btree
  add_index "follower_relationships", ["person_id", "follower_id"], name: "index_follower_relationships_on_person_id_and_follower_id", unique: true, using: :btree
  add_index "follower_relationships", ["person_id"], name: "index_follower_relationships_on_person_id", using: :btree

  create_table "invitations", force: :cascade do |t|
    t.string   "code",         limit: 255
    t.integer  "community_id", limit: 4
    t.integer  "usages_left",  limit: 4
    t.datetime "valid_until"
    t.string   "information",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "inviter_id",   limit: 255
    t.text     "message",      limit: 65535
    t.string   "email",        limit: 255
  end

  add_index "invitations", ["code"], name: "index_invitations_on_code", using: :btree
  add_index "invitations", ["inviter_id"], name: "index_invitations_on_inviter_id", using: :btree

  create_table "landing_page_versions", force: :cascade do |t|
    t.integer  "community_id", limit: 4,        null: false
    t.integer  "version",      limit: 4,        null: false
    t.datetime "released"
    t.text     "content",      limit: 16777215, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "landing_page_versions", ["community_id", "version"], name: "index_landing_page_versions_on_community_id_and_version", unique: true, using: :btree

  create_table "landing_pages", force: :cascade do |t|
    t.integer  "community_id",     limit: 4,                 null: false
    t.boolean  "enabled",                    default: false, null: false
    t.integer  "released_version", limit: 4
    t.datetime "updated_at"
  end

  add_index "landing_pages", ["community_id"], name: "index_landing_pages_on_community_id", unique: true, using: :btree

  create_table "listing_followers", id: false, force: :cascade do |t|
    t.string  "person_id",  limit: 255
    t.integer "listing_id", limit: 4
  end

  add_index "listing_followers", ["listing_id"], name: "index_listing_followers_on_listing_id", using: :btree
  add_index "listing_followers", ["person_id"], name: "index_listing_followers_on_person_id", using: :btree

  create_table "listing_images", force: :cascade do |t|
    t.integer  "listing_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.boolean  "image_processing"
    t.boolean  "image_downloaded",               default: false
    t.string   "error",              limit: 255
    t.integer  "width",              limit: 4
    t.integer  "height",             limit: 4
    t.string   "author_id",          limit: 255
  end

  add_index "listing_images", ["listing_id"], name: "index_listing_images_on_listing_id", using: :btree

  create_table "listing_shapes", force: :cascade do |t|
    t.integer  "community_id",           limit: 4,                   null: false
    t.integer  "transaction_process_id", limit: 4,                   null: false
    t.boolean  "price_enabled",                                      null: false
    t.boolean  "shipping_enabled",                                   null: false
    t.string   "name",                   limit: 255,                 null: false
    t.string   "name_tr_key",            limit: 255,                 null: false
    t.string   "action_button_tr_key",   limit: 255,                 null: false
    t.integer  "sort_priority",          limit: 4,   default: 0,     null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "deleted",                            default: false
  end

  add_index "listing_shapes", ["community_id", "deleted", "sort_priority"], name: "multicol_index", using: :btree
  add_index "listing_shapes", ["community_id"], name: "index_listing_shapes_on_community_id", using: :btree
  add_index "listing_shapes", ["name"], name: "index_listing_shapes_on_name", using: :btree

  create_table "listing_units", force: :cascade do |t|
    t.string   "unit_type",         limit: 32, null: false
    t.string   "quantity_selector", limit: 32, null: false
    t.string   "kind",              limit: 32, null: false
    t.string   "name_tr_key",       limit: 64
    t.string   "selector_tr_key",   limit: 64
    t.integer  "listing_shape_id",  limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "listing_units", ["listing_shape_id"], name: "index_listing_units_on_listing_shape_id", using: :btree

  create_table "listings", force: :cascade do |t|
    t.integer  "community_id",                    limit: 4,                         null: false
    t.string   "author_id",                       limit: 255
    t.string   "category_old",                    limit: 255
    t.string   "title",                           limit: 255
    t.integer  "times_viewed",                    limit: 4,     default: 0
    t.string   "language",                        limit: 255
    t.datetime "created_at"
    t.datetime "updates_email_at"
    t.datetime "updated_at"
    t.datetime "last_modified"
    t.datetime "sort_date"
    t.string   "listing_type_old",                limit: 255
    t.text     "description",                     limit: 65535
    t.string   "origin",                          limit: 255
    t.string   "destination",                     limit: 255
    t.datetime "valid_until"
    t.boolean  "delta",                                         default: true,      null: false
    t.boolean  "open",                                          default: true
    t.string   "share_type_old",                  limit: 255
    t.string   "privacy",                         limit: 255,   default: "private"
    t.integer  "comments_count",                  limit: 4,     default: 0
    t.string   "subcategory_old",                 limit: 255
    t.integer  "old_category_id",                 limit: 4
    t.integer  "category_id",                     limit: 4
    t.integer  "share_type_id",                   limit: 4
    t.integer  "listing_shape_id",                limit: 4
    t.integer  "transaction_process_id",          limit: 4
    t.string   "shape_name_tr_key",               limit: 255
    t.string   "action_button_tr_key",            limit: 255
    t.integer  "price_cents",                     limit: 4
    t.string   "currency",                        limit: 255
    t.string   "quantity",                        limit: 255
    t.string   "unit_type",                       limit: 32
    t.string   "quantity_selector",               limit: 32
    t.string   "unit_tr_key",                     limit: 64
    t.string   "unit_selector_tr_key",            limit: 64
    t.boolean  "deleted",                                       default: false
    t.boolean  "require_shipping_address",                      default: false
    t.boolean  "pickup_enabled",                                default: false
    t.integer  "shipping_price_cents",            limit: 4
    t.integer  "shipping_price_additional_cents", limit: 4
  end

  add_index "listings", ["category_id"], name: "index_listings_on_new_category_id", using: :btree
  add_index "listings", ["community_id", "author_id"], name: "person_listings", using: :btree
  add_index "listings", ["community_id", "open", "sort_date", "deleted"], name: "homepage_query", using: :btree
  add_index "listings", ["community_id", "open", "updates_email_at"], name: "updates_email_listings", using: :btree
  add_index "listings", ["community_id", "open", "valid_until", "sort_date", "deleted"], name: "homepage_query_valid_until", using: :btree
  add_index "listings", ["community_id"], name: "index_listings_on_community_id", using: :btree
  add_index "listings", ["listing_shape_id"], name: "index_listings_on_listing_shape_id", using: :btree
  add_index "listings", ["old_category_id"], name: "index_listings_on_category_id", using: :btree
  add_index "listings", ["open"], name: "index_listings_on_open", using: :btree

  create_table "locations", force: :cascade do |t|
    t.float    "latitude",       limit: 24
    t.float    "longitude",      limit: 24
    t.string   "address",        limit: 255
    t.string   "google_address", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "listing_id",     limit: 4
    t.string   "person_id",      limit: 255
    t.string   "location_type",  limit: 255
    t.integer  "community_id",   limit: 4
  end

  add_index "locations", ["community_id"], name: "index_locations_on_community_id", using: :btree
  add_index "locations", ["listing_id"], name: "index_locations_on_listing_id", using: :btree
  add_index "locations", ["person_id"], name: "index_locations_on_person_id", using: :btree

  create_table "marketplace_configurations", force: :cascade do |t|
    t.integer  "community_id",          limit: 4,                       null: false
    t.string   "main_search",           limit: 255, default: "keyword", null: false
    t.string   "distance_unit",         limit: 255, default: "metric",  null: false
    t.integer  "limit_priority_links",  limit: 4
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.boolean  "limit_search_distance",             default: true,      null: false
  end

  add_index "marketplace_configurations", ["community_id"], name: "index_marketplace_configurations_on_community_id", using: :btree

  create_table "marketplace_plans", force: :cascade do |t|
    t.integer  "community_id", limit: 4,     null: false
    t.string   "status",       limit: 22
    t.text     "features",     limit: 65535
    t.integer  "member_limit", limit: 4
    t.datetime "expires_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "marketplace_plans", ["community_id"], name: "index_marketplace_plans_on_community_id", using: :btree
  add_index "marketplace_plans", ["created_at"], name: "index_marketplace_plans_on_created_at", using: :btree

  create_table "marketplace_sender_emails", force: :cascade do |t|
    t.integer  "community_id",              limit: 4,   null: false
    t.string   "name",                      limit: 255
    t.string   "email",                     limit: 255, null: false
    t.string   "verification_status",       limit: 32,  null: false
    t.datetime "verification_requested_at"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "marketplace_sender_emails", ["community_id"], name: "index_marketplace_sender_emails_on_community_id", using: :btree

  create_table "marketplace_setup_steps", force: :cascade do |t|
    t.integer "community_id",           limit: 4,                 null: false
    t.boolean "slogan_and_description",           default: false, null: false
    t.boolean "cover_photo",                      default: false, null: false
    t.boolean "filter",                           default: false, null: false
    t.boolean "paypal",                           default: false, null: false
    t.boolean "listing",                          default: false, null: false
    t.boolean "invitation",                       default: false, null: false
  end

  add_index "marketplace_setup_steps", ["community_id"], name: "index_marketplace_setup_steps_on_community_id", unique: true, using: :btree

  create_table "marketplace_trials", force: :cascade do |t|
    t.integer  "community_id", limit: 4, null: false
    t.datetime "expires_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "marketplace_trials", ["community_id"], name: "index_marketplace_trials_on_community_id", using: :btree
  add_index "marketplace_trials", ["created_at"], name: "index_marketplace_trials_on_created_at", using: :btree

  create_table "menu_link_translations", force: :cascade do |t|
    t.integer  "menu_link_id", limit: 4
    t.string   "locale",       limit: 255
    t.string   "url",          limit: 255
    t.string   "title",        limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "menu_link_translations", ["menu_link_id"], name: "index_menu_link_translations_on_menu_link_id", using: :btree

  create_table "menu_links", force: :cascade do |t|
    t.integer  "community_id",  limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "sort_priority", limit: 4, default: 0
  end

  add_index "menu_links", ["community_id", "sort_priority"], name: "index_menu_links_on_community_and_sort", using: :btree

  create_table "mercury_images", force: :cascade do |t|
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string   "sender_id",       limit: 255
    t.text     "content",         limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "conversation_id", limit: 4
  end

  add_index "messages", ["conversation_id"], name: "index_messages_on_conversation_id", using: :btree

  create_table "order_permissions", force: :cascade do |t|
    t.integer  "paypal_account_id",   limit: 4,   null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "request_token",       limit: 255
    t.string   "paypal_username_to",  limit: 255, null: false
    t.string   "scope",               limit: 255
    t.string   "verification_code",   limit: 255
    t.string   "onboarding_id",       limit: 36
    t.boolean  "permissions_granted"
  end

  add_index "order_permissions", ["paypal_account_id"], name: "index_order_permissions_on_paypal_account_id", using: :btree

  create_table "participations", force: :cascade do |t|
    t.string   "person_id",        limit: 255
    t.integer  "conversation_id",  limit: 4
    t.boolean  "is_read",                      default: false
    t.boolean  "is_starter",                   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_sent_at"
    t.datetime "last_received_at"
    t.boolean  "feedback_skipped",             default: false
  end

  add_index "participations", ["conversation_id"], name: "index_participations_on_conversation_id", using: :btree
  add_index "participations", ["person_id"], name: "index_participations_on_person_id", using: :btree

  create_table "payment_settings", force: :cascade do |t|
    t.boolean  "active",                                   null: false
    t.integer  "community_id",                  limit: 4,  null: false
    t.string   "payment_gateway",               limit: 64
    t.string   "payment_process",               limit: 64
    t.integer  "commission_from_seller",        limit: 4
    t.integer  "minimum_price_cents",           limit: 4
    t.integer  "minimum_transaction_fee_cents", limit: 4
    t.integer  "confirmation_after_days",       limit: 4,  null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "payment_settings", ["community_id"], name: "index_payment_settings_on_community_id", using: :btree

  create_table "paypal_accounts", force: :cascade do |t|
    t.string   "person_id",    limit: 255
    t.integer  "community_id", limit: 4
    t.string   "email",        limit: 255
    t.string   "payer_id",     limit: 255
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.boolean  "active",                   default: false
  end

  add_index "paypal_accounts", ["community_id"], name: "index_paypal_accounts_on_community_id", using: :btree
  add_index "paypal_accounts", ["payer_id"], name: "index_paypal_accounts_on_payer_id", using: :btree
  add_index "paypal_accounts", ["person_id"], name: "index_paypal_accounts_on_person_id", using: :btree

  create_table "paypal_ipn_messages", force: :cascade do |t|
    t.text     "body",       limit: 65535
    t.string   "status",     limit: 64
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "paypal_payments", force: :cascade do |t|
    t.integer  "community_id",               limit: 4,                           null: false
    t.integer  "transaction_id",             limit: 4,                           null: false
    t.string   "payer_id",                   limit: 64,                          null: false
    t.string   "receiver_id",                limit: 64,                          null: false
    t.string   "merchant_id",                limit: 255,                         null: false
    t.string   "order_id",                   limit: 64
    t.datetime "order_date"
    t.string   "currency",                   limit: 8,                           null: false
    t.integer  "order_total_cents",          limit: 4
    t.string   "authorization_id",           limit: 64
    t.datetime "authorization_date"
    t.datetime "authorization_expires_date"
    t.integer  "authorization_total_cents",  limit: 4
    t.string   "payment_id",                 limit: 64
    t.datetime "payment_date"
    t.integer  "payment_total_cents",        limit: 4
    t.integer  "fee_total_cents",            limit: 4
    t.string   "payment_status",             limit: 64,                          null: false
    t.string   "pending_reason",             limit: 64
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.string   "commission_payment_id",      limit: 64
    t.datetime "commission_payment_date"
    t.string   "commission_status",          limit: 64,  default: "not_charged", null: false
    t.string   "commission_pending_reason",  limit: 64
    t.integer  "commission_total_cents",     limit: 4
    t.integer  "commission_fee_total_cents", limit: 4
  end

  add_index "paypal_payments", ["authorization_id"], name: "index_paypal_payments_on_authorization_id", unique: true, using: :btree
  add_index "paypal_payments", ["community_id"], name: "index_paypal_payments_on_community_id", using: :btree
  add_index "paypal_payments", ["order_id"], name: "index_paypal_payments_on_order_id", unique: true, using: :btree
  add_index "paypal_payments", ["transaction_id"], name: "index_paypal_payments_on_transaction_id", unique: true, using: :btree

  create_table "paypal_process_tokens", force: :cascade do |t|
    t.string   "process_token",  limit: 64,                    null: false
    t.integer  "community_id",   limit: 4,                     null: false
    t.integer  "transaction_id", limit: 4,                     null: false
    t.boolean  "op_completed",                 default: false, null: false
    t.string   "op_name",        limit: 64,                    null: false
    t.text     "op_input",       limit: 65535
    t.text     "op_output",      limit: 65535
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "paypal_process_tokens", ["process_token"], name: "index_paypal_process_tokens_on_process_token", unique: true, using: :btree
  add_index "paypal_process_tokens", ["transaction_id", "community_id", "op_name"], name: "index_paypal_process_tokens_on_transaction", unique: true, using: :btree

  create_table "paypal_refunds", force: :cascade do |t|
    t.integer  "paypal_payment_id",   limit: 4
    t.string   "currency",            limit: 8
    t.integer  "payment_total_cents", limit: 4
    t.integer  "fee_total_cents",     limit: 4
    t.string   "refunding_id",        limit: 64
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "paypal_refunds", ["refunding_id"], name: "index_paypal_refunds_on_refunding_id", unique: true, using: :btree

  create_table "paypal_tokens", force: :cascade do |t|
    t.integer  "community_id",         limit: 4,   null: false
    t.string   "token",                limit: 64
    t.integer  "transaction_id",       limit: 4
    t.string   "payment_action",       limit: 32
    t.string   "merchant_id",          limit: 255, null: false
    t.string   "receiver_id",          limit: 255, null: false
    t.datetime "created_at"
    t.string   "item_name",            limit: 255
    t.integer  "item_quantity",        limit: 4
    t.integer  "item_price_cents",     limit: 4
    t.string   "currency",             limit: 8
    t.string   "express_checkout_url", limit: 255
    t.integer  "shipping_total_cents", limit: 4
  end

  add_index "paypal_tokens", ["community_id"], name: "index_paypal_tokens_on_community_id", using: :btree
  add_index "paypal_tokens", ["token"], name: "index_paypal_tokens_on_token", unique: true, using: :btree
  add_index "paypal_tokens", ["transaction_id"], name: "index_paypal_tokens_on_transaction_id", using: :btree

  create_table "people", id: false, force: :cascade do |t|
    t.string   "id",                                 limit: 22,                    null: false
    t.integer  "community_id",                       limit: 4,                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_admin",                           limit: 4,     default: 0
    t.string   "locale",                             limit: 255,   default: "fi"
    t.text     "preferences",                        limit: 65535
    t.integer  "active_days_count",                  limit: 4,     default: 0
    t.datetime "last_page_load_date"
    t.integer  "test_group_number",                  limit: 4,     default: 1
    t.string   "username",                           limit: 255,                   null: false
    t.string   "email",                              limit: 255
    t.string   "encrypted_password",                 limit: 255,   default: "",    null: false
    t.string   "legacy_encrypted_password",          limit: 255
    t.string   "reset_password_token",               limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      limit: 4,     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",                 limit: 255
    t.string   "last_sign_in_ip",                    limit: 255
    t.string   "password_salt",                      limit: 255
    t.string   "given_name",                         limit: 255
    t.string   "family_name",                        limit: 255
    t.string   "phone_number",                       limit: 255
    t.text     "description",                        limit: 65535
    t.string   "image_file_name",                    limit: 255
    t.string   "image_content_type",                 limit: 255
    t.integer  "image_file_size",                    limit: 4
    t.datetime "image_updated_at"
    t.boolean  "image_processing"
    t.string   "facebook_id",                        limit: 255
    t.string   "authentication_token",               limit: 255
    t.datetime "community_updates_last_sent_at"
    t.integer  "min_days_between_community_updates", limit: 4,     default: 1
    t.boolean  "deleted",                                          default: false
    t.string   "cloned_from",                        limit: 22
  end

  add_index "people", ["authentication_token"], name: "index_people_on_authentication_token", using: :btree
  add_index "people", ["community_id"], name: "index_people_on_community_id", using: :btree
  add_index "people", ["email"], name: "index_people_on_email", unique: true, using: :btree
  add_index "people", ["facebook_id", "community_id"], name: "index_people_on_facebook_id_and_community_id", unique: true, using: :btree
  add_index "people", ["facebook_id"], name: "index_people_on_facebook_id", using: :btree
  add_index "people", ["id"], name: "index_people_on_id", using: :btree
  add_index "people", ["reset_password_token"], name: "index_people_on_reset_password_token", unique: true, using: :btree
  add_index "people", ["username", "community_id"], name: "index_people_on_username_and_community_id", unique: true, using: :btree
  add_index "people", ["username"], name: "index_people_on_username", using: :btree

  create_table "prospect_emails", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "shipping_addresses", force: :cascade do |t|
    t.integer  "transaction_id",    limit: 4,   null: false
    t.string   "status",            limit: 255
    t.string   "name",              limit: 255
    t.string   "phone",             limit: 255
    t.string   "postal_code",       limit: 255
    t.string   "city",              limit: 255
    t.string   "country",           limit: 255
    t.string   "state_or_province", limit: 255
    t.string   "street1",           limit: 255
    t.string   "street2",           limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "country_code",      limit: 8
  end

  create_table "testimonials", force: :cascade do |t|
    t.float    "grade",            limit: 24
    t.text     "text",             limit: 65535
    t.string   "author_id",        limit: 255
    t.integer  "participation_id", limit: 4
    t.integer  "transaction_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "receiver_id",      limit: 255
  end

  add_index "testimonials", ["author_id"], name: "index_testimonials_on_author_id", using: :btree
  add_index "testimonials", ["receiver_id"], name: "index_testimonials_on_receiver_id", using: :btree
  add_index "testimonials", ["transaction_id"], name: "index_testimonials_on_transaction_id", using: :btree

  create_table "transaction_processes", force: :cascade do |t|
    t.integer  "community_id",     limit: 4
    t.string   "process",          limit: 32, null: false
    t.boolean  "author_is_seller"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "transaction_processes", ["community_id"], name: "index_transaction_process_on_community_id", using: :btree

  create_table "transaction_transitions", force: :cascade do |t|
    t.string   "to_state",       limit: 255
    t.text     "metadata",       limit: 65535
    t.integer  "sort_key",       limit: 4,     default: 0
    t.integer  "transaction_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transaction_transitions", ["sort_key", "transaction_id"], name: "index_transaction_transitions_on_sort_key_and_conversation_id", unique: true, using: :btree
  add_index "transaction_transitions", ["transaction_id"], name: "index_transaction_transitions_on_conversation_id", using: :btree

  create_table "transactions", force: :cascade do |t|
    t.string   "starter_id",                        limit: 255,                  null: false
    t.integer  "listing_id",                        limit: 4,                    null: false
    t.integer  "conversation_id",                   limit: 4
    t.integer  "automatic_confirmation_after_days", limit: 4,                    null: false
    t.integer  "community_id",                      limit: 4,                    null: false
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.boolean  "starter_skipped_feedback",                      default: false
    t.boolean  "author_skipped_feedback",                       default: false
    t.datetime "last_transition_at"
    t.string   "current_state",                     limit: 255
    t.integer  "commission_from_seller",            limit: 4
    t.integer  "minimum_commission_cents",          limit: 4,   default: 0
    t.string   "minimum_commission_currency",       limit: 255
    t.string   "payment_gateway",                   limit: 255, default: "none", null: false
    t.integer  "listing_quantity",                  limit: 4,   default: 1
    t.string   "listing_author_id",                 limit: 255
    t.string   "listing_title",                     limit: 255
    t.string   "unit_type",                         limit: 32
    t.string   "old_unit_type",                     limit: 32
    t.integer  "unit_price_cents",                  limit: 4
    t.string   "unit_price_currency",               limit: 8
    t.string   "unit_tr_key",                       limit: 64
    t.string   "unit_selector_tr_key",              limit: 64
    t.string   "payment_process",                   limit: 31,  default: "none"
    t.string   "delivery_method",                   limit: 31,  default: "none"
    t.integer  "shipping_price_cents",              limit: 4
    t.boolean  "deleted",                                       default: false
  end

  add_index "transactions", ["community_id", "deleted"], name: "transactions_on_cid_and_deleted", using: :btree
  add_index "transactions", ["community_id"], name: "index_transactions_on_community_id", using: :btree
  add_index "transactions", ["conversation_id"], name: "index_transactions_on_conversation_id", using: :btree
  add_index "transactions", ["deleted"], name: "index_transactions_on_deleted", using: :btree
  add_index "transactions", ["last_transition_at"], name: "index_transactions_on_last_transition_at", using: :btree
  add_index "transactions", ["listing_id"], name: "index_transactions_on_listing_id", using: :btree

end

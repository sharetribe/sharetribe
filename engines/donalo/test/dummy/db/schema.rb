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

ActiveRecord::Schema.define(version: 2020_04_29_193332) do

  create_table "active_sessions", id: :binary, limit: 16, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "person_id", limit: 22, null: false
    t.integer "community_id", null: false
    t.datetime "refreshed_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_active_sessions_on_community_id"
    t.index ["person_id"], name: "index_active_sessions_on_person_id"
    t.index ["refreshed_at"], name: "index_active_sessions_on_refreshed_at"
  end

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "auth_tokens", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "token"
    t.string "token_type", default: "unsubscribe"
    t.string "person_id"
    t.datetime "expires_at"
    t.integer "usages_left"
    t.datetime "last_use_attempt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_on_person_id"
    t.index ["token"], name: "index_auth_tokens_on_token", unique: true
  end

  create_table "billing_agreements", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "paypal_account_id", null: false
    t.string "billing_agreement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "paypal_username_to", null: false
    t.string "request_token", null: false
    t.index ["paypal_account_id"], name: "index_billing_agreements_on_paypal_account_id"
  end

  create_table "bookings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "transaction_id"
    t.date "start_on"
    t.date "end_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean "per_hour", default: false
    t.index ["end_time"], name: "index_bookings_on_end_time"
    t.index ["per_hour"], name: "index_bookings_on_per_hour"
    t.index ["start_time"], name: "index_bookings_on_start_time"
    t.index ["transaction_id"], name: "index_bookings_on_transaction_id"
  end

  create_table "categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "parent_id"
    t.string "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "community_id"
    t.integer "sort_priority"
    t.string "url"
    t.index ["community_id"], name: "index_categories_on_community_id"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["url"], name: "index_categories_on_url"
  end

  create_table "category_custom_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "category_id"
    t.integer "custom_field_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id", "custom_field_id"], name: "index_category_custom_fields_on_category_id_and_custom_field_id"
    t.index ["custom_field_id"], name: "index_category_custom_fields_on_custom_field_id"
  end

  create_table "category_listing_shapes", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "listing_shape_id", null: false
    t.index ["category_id"], name: "index_category_listing_shapes_on_category_id"
    t.index ["listing_shape_id", "category_id"], name: "unique_listing_shape_category_joins", unique: true
  end

  create_table "category_translations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "category_id"
    t.string "locale"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.index ["category_id", "locale"], name: "category_id_with_locale"
    t.index ["category_id"], name: "index_category_translations_on_category_id"
  end

  create_table "checkout_accounts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "company_id_or_personal_id"
    t.string "merchant_id", null: false
    t.string "merchant_key", null: false
    t.string "person_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "author_id"
    t.integer "listing_id"
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "community_id"
    t.index ["listing_id"], name: "index_comments_on_listing_id"
  end

  create_table "communities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.binary "uuid", limit: 16, null: false
    t.string "ident"
    t.string "domain"
    t.boolean "use_domain", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "settings"
    t.string "consent"
    t.boolean "transaction_agreement_in_use", default: false
    t.boolean "email_admins_about_new_members", default: false
    t.boolean "use_fb_like", default: false
    t.boolean "real_name_required", default: true
    t.boolean "automatic_newsletters", default: true
    t.boolean "join_with_invite_only", default: false
    t.text "allowed_emails", limit: 16777215
    t.boolean "users_can_invite_new_users", default: true
    t.boolean "private", default: false
    t.string "label"
    t.boolean "show_date_in_listings_list", default: false
    t.boolean "all_users_can_add_news", default: true
    t.boolean "custom_frontpage_sidebar", default: false
    t.boolean "event_feed_enabled", default: true
    t.string "slogan"
    t.text "description"
    t.string "country"
    t.integer "members_count", default: 0
    t.integer "user_limit"
    t.float "monthly_price_in_euros"
    t.string "logo_file_name"
    t.string "logo_content_type"
    t.integer "logo_file_size"
    t.datetime "logo_updated_at"
    t.string "cover_photo_file_name"
    t.string "cover_photo_content_type"
    t.integer "cover_photo_file_size"
    t.datetime "cover_photo_updated_at"
    t.string "small_cover_photo_file_name"
    t.string "small_cover_photo_content_type"
    t.integer "small_cover_photo_file_size"
    t.datetime "small_cover_photo_updated_at"
    t.string "custom_color1"
    t.string "custom_color2"
    t.string "slogan_color", limit: 6
    t.string "description_color", limit: 6
    t.string "stylesheet_url"
    t.boolean "stylesheet_needs_recompile", default: false
    t.string "service_logo_style", default: "full-logo"
    t.string "currency", limit: 3, null: false
    t.boolean "facebook_connect_enabled", default: true
    t.integer "minimum_price_cents"
    t.boolean "hide_expiration_date", default: true
    t.string "facebook_connect_id"
    t.string "facebook_connect_secret"
    t.string "google_analytics_key"
    t.string "google_maps_key", limit: 64
    t.string "name_display_type", default: "first_name_with_initial"
    t.string "twitter_handle"
    t.boolean "use_community_location_as_default", default: false
    t.string "preproduction_stylesheet_url"
    t.boolean "show_category_in_listing_list", default: false
    t.string "default_browse_view", default: "grid"
    t.string "wide_logo_file_name"
    t.string "wide_logo_content_type"
    t.integer "wide_logo_file_size"
    t.datetime "wide_logo_updated_at"
    t.boolean "listing_comments_in_use", default: false
    t.boolean "show_listing_publishing_date", default: false
    t.boolean "require_verification_to_post_listings", default: false
    t.boolean "show_price_filter", default: false
    t.integer "price_filter_min", default: 0
    t.integer "price_filter_max", default: 100000
    t.integer "automatic_confirmation_after_days", default: 14
    t.string "favicon_file_name"
    t.string "favicon_content_type"
    t.integer "favicon_file_size"
    t.datetime "favicon_updated_at"
    t.integer "default_min_days_between_community_updates", default: 7
    t.boolean "listing_location_required", default: false
    t.text "custom_head_script"
    t.boolean "follow_in_use", default: true, null: false
    t.boolean "logo_processing"
    t.boolean "wide_logo_processing"
    t.boolean "cover_photo_processing"
    t.boolean "small_cover_photo_processing"
    t.boolean "favicon_processing"
    t.boolean "deleted"
    t.boolean "end_user_analytics", default: true
    t.boolean "show_slogan", default: true
    t.boolean "show_description", default: true
    t.integer "hsts_max_age"
    t.integer "footer_theme", default: 0
    t.text "footer_copyright"
    t.boolean "footer_enabled", default: false
    t.string "logo_link"
    t.boolean "google_connect_enabled"
    t.string "google_connect_id"
    t.string "google_connect_secret"
    t.boolean "linkedin_connect_enabled"
    t.string "linkedin_connect_id"
    t.string "linkedin_connect_secret"
    t.boolean "pre_approved_listings", default: false
    t.boolean "allow_free_conversations", default: true
    t.boolean "email_admins_about_new_transactions", default: false
    t.boolean "show_location", default: true
    t.index ["domain"], name: "index_communities_on_domain"
    t.index ["ident"], name: "index_communities_on_ident"
    t.index ["uuid"], name: "index_communities_on_uuid", unique: true
  end

  create_table "community_customizations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id"
    t.string "locale"
    t.string "name"
    t.string "slogan"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "blank_slate"
    t.text "welcome_email_content"
    t.text "how_to_use_page_content", limit: 16777215
    t.text "about_page_content", limit: 16777215
    t.text "terms_page_content", limit: 16777215
    t.text "privacy_page_content", limit: 16777215
    t.text "signup_info_content"
    t.text "private_community_homepage_content", limit: 16777215
    t.text "verification_to_post_listings_info_content", limit: 16777215
    t.string "search_placeholder"
    t.string "transaction_agreement_label"
    t.text "transaction_agreement_content", limit: 16777215
    t.string "social_media_title"
    t.text "social_media_description"
    t.string "meta_title"
    t.text "meta_description"
    t.string "search_meta_title"
    t.text "search_meta_description"
    t.string "listing_meta_title"
    t.text "listing_meta_description"
    t.string "category_meta_title"
    t.text "category_meta_description"
    t.string "profile_meta_title"
    t.text "profile_meta_description"
    t.index ["community_id"], name: "index_community_customizations_on_community_id"
  end

  create_table "community_memberships", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "person_id", null: false
    t.integer "community_id", null: false
    t.boolean "admin", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "consent"
    t.integer "invitation_id"
    t.datetime "last_page_load_date"
    t.string "status", default: "accepted", null: false
    t.boolean "can_post_listings", default: false
    t.index ["community_id", "person_id", "status"], name: "community_person_status"
    t.index ["community_id"], name: "index_community_memberships_on_community_id"
    t.index ["person_id"], name: "index_community_memberships_on_person_id", unique: true
  end

  create_table "community_social_logos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "community_id"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.boolean "image_processing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_community_social_logos_on_community_id"
  end

  create_table "community_translations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id", null: false
    t.string "locale", limit: 16, null: false
    t.string "translation_key", null: false
    t.text "translation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_community_translations_on_community_id"
  end

  create_table "contact_requests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "country"
    t.string "plan_type"
    t.string "marketplace_type"
  end

  create_table "conversations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.integer "listing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_message_at"
    t.integer "community_id"
    t.string "starting_page"
    t.index ["community_id"], name: "index_conversations_on_community_id"
    t.index ["last_message_at"], name: "index_conversations_on_last_message_at"
    t.index ["listing_id"], name: "index_conversations_on_listing_id"
    t.index ["starting_page"], name: "index_conversations_on_starting_page"
  end

  create_table "custom_field_names", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "value"
    t.string "locale"
    t.string "custom_field_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_field_id", "locale"], name: "locale_index"
    t.index ["custom_field_id"], name: "index_custom_field_names_on_custom_field_id"
  end

  create_table "custom_field_option_selections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "custom_field_value_id"
    t.integer "custom_field_option_id"
    t.integer "listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_field_option_id"], name: "index_custom_field_option_selections_on_custom_field_option_id"
    t.index ["custom_field_value_id"], name: "index_selected_options_on_custom_field_value_id"
  end

  create_table "custom_field_option_titles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "value"
    t.string "locale"
    t.integer "custom_field_option_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_field_option_id", "locale"], name: "locale_index"
    t.index ["custom_field_option_id"], name: "index_custom_field_option_titles_on_custom_field_option_id"
  end

  create_table "custom_field_options", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "custom_field_id"
    t.integer "sort_priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["custom_field_id"], name: "index_custom_field_options_on_custom_field_id"
  end

  create_table "custom_field_values", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "custom_field_id"
    t.integer "listing_id"
    t.text "text_value"
    t.float "numeric_value"
    t.datetime "date_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.boolean "delta", default: true, null: false
    t.string "person_id"
    t.index ["listing_id"], name: "index_custom_field_values_on_listing_id"
    t.index ["person_id"], name: "index_custom_field_values_on_person_id"
    t.index ["type"], name: "index_custom_field_values_on_type"
  end

  create_table "custom_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "type"
    t.integer "sort_priority"
    t.boolean "search_filter", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "community_id"
    t.boolean "required", default: true
    t.float "min"
    t.float "max"
    t.boolean "allow_decimals", default: false
    t.integer "entity_type", default: 0
    t.boolean "public", default: false
    t.integer "assignment", default: 0
    t.index ["community_id"], name: "index_custom_fields_on_community_id"
    t.index ["search_filter"], name: "index_custom_fields_on_search_filter"
  end

  create_table "delayed_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "queue"
    t.index ["attempts", "run_at", "priority"], name: "index_delayed_jobs_on_attempts_and_run_at_and_priority"
    t.index ["locked_at", "created_at"], name: "index_delayed_jobs_on_locked_created"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "donalo_stock_stocks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "listing_id"
    t.integer "amount", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_donalo_stock_stocks_on_listing_id"
  end

  create_table "emails", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "person_id"
    t.integer "community_id", null: false
    t.string "address", null: false
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "send_notifications"
    t.index ["address", "community_id"], name: "index_emails_on_address_and_community_id", unique: true
    t.index ["address"], name: "index_emails_on_address"
    t.index ["community_id"], name: "index_emails_on_community_id"
    t.index ["confirmation_token"], name: "index_emails_on_confirmation_token"
    t.index ["person_id"], name: "index_emails_on_person_id"
  end

  create_table "export_task_results", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "status"
    t.string "token"
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feature_flags", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id", null: false
    t.string "person_id"
    t.string "feature", null: false
    t.boolean "enabled", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id", "person_id"], name: "index_feature_flags_on_community_id_and_person_id"
  end

  create_table "feedbacks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "content"
    t.string "author_id"
    t.string "url", limit: 2048
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "is_handled", default: 0
    t.string "email"
    t.integer "community_id"
  end

  create_table "follower_relationships", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "person_id", null: false
    t.string "follower_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["follower_id"], name: "index_follower_relationships_on_follower_id"
    t.index ["person_id", "follower_id"], name: "index_follower_relationships_on_person_id_and_follower_id", unique: true
    t.index ["person_id"], name: "index_follower_relationships_on_person_id"
  end

  create_table "invitation_unsubscribes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_invitation_unsubscribes_on_community_id"
    t.index ["email"], name: "index_invitation_unsubscribes_on_email"
  end

  create_table "invitations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "code"
    t.integer "community_id"
    t.integer "usages_left"
    t.datetime "valid_until"
    t.string "information"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "inviter_id"
    t.text "message"
    t.string "email"
    t.boolean "deleted", default: false
    t.index ["code"], name: "index_invitations_on_code"
    t.index ["inviter_id"], name: "index_invitations_on_inviter_id"
  end

  create_table "landing_page_versions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id", null: false
    t.integer "version", null: false
    t.datetime "released"
    t.text "content", limit: 16777215, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["community_id", "version"], name: "index_landing_page_versions_on_community_id_and_version", unique: true
  end

  create_table "landing_pages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id", null: false
    t.boolean "enabled", default: false, null: false
    t.integer "released_version"
    t.datetime "updated_at"
    t.index ["community_id"], name: "index_landing_pages_on_community_id", unique: true
  end

  create_table "listing_followers", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "person_id"
    t.integer "listing_id"
    t.index ["listing_id"], name: "index_listing_followers_on_listing_id"
    t.index ["person_id"], name: "index_listing_followers_on_person_id"
  end

  create_table "listing_images", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "listing_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.boolean "image_processing"
    t.boolean "image_downloaded", default: false
    t.string "error"
    t.integer "width"
    t.integer "height"
    t.string "author_id"
    t.integer "position", default: 0
    t.string "email_image_file_name"
    t.string "email_image_content_type"
    t.integer "email_image_file_size"
    t.datetime "email_image_updated_at"
    t.string "email_hash"
    t.index ["listing_id"], name: "index_listing_images_on_listing_id"
  end

  create_table "listing_shapes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id", null: false
    t.integer "transaction_process_id", null: false
    t.boolean "price_enabled", null: false
    t.boolean "shipping_enabled", null: false
    t.string "availability", limit: 32, default: "none"
    t.string "name", null: false
    t.string "name_tr_key", null: false
    t.string "action_button_tr_key", null: false
    t.integer "sort_priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false
    t.index ["community_id", "deleted", "sort_priority"], name: "multicol_index"
    t.index ["community_id"], name: "index_listing_shapes_on_community_id"
    t.index ["name"], name: "index_listing_shapes_on_name"
  end

  create_table "listing_units", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "unit_type", limit: 32, null: false
    t.string "quantity_selector", limit: 32, null: false
    t.string "kind", limit: 32, null: false
    t.string "name_tr_key", limit: 64
    t.string "selector_tr_key", limit: 64
    t.integer "listing_shape_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_shape_id"], name: "index_listing_units_on_listing_shape_id"
  end

  create_table "listing_working_time_slots", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "listing_id"
    t.integer "week_day"
    t.string "from"
    t.string "till"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_listing_working_time_slots_on_listing_id"
  end

  create_table "listings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.binary "uuid", limit: 16, null: false
    t.integer "community_id", null: false
    t.string "author_id"
    t.string "category_old"
    t.string "title"
    t.integer "times_viewed", default: 0
    t.string "language"
    t.datetime "created_at"
    t.datetime "updates_email_at"
    t.datetime "updated_at"
    t.datetime "last_modified"
    t.datetime "sort_date"
    t.string "listing_type_old"
    t.text "description"
    t.string "origin"
    t.string "destination"
    t.datetime "valid_until"
    t.boolean "delta", default: true, null: false
    t.boolean "open", default: true
    t.string "share_type_old"
    t.string "privacy", default: "private"
    t.integer "comments_count", default: 0
    t.string "subcategory_old"
    t.integer "old_category_id"
    t.integer "category_id"
    t.integer "share_type_id"
    t.integer "listing_shape_id"
    t.integer "transaction_process_id"
    t.string "shape_name_tr_key"
    t.string "action_button_tr_key"
    t.integer "price_cents"
    t.string "currency"
    t.string "quantity"
    t.string "unit_type", limit: 32
    t.string "quantity_selector", limit: 32
    t.string "unit_tr_key", limit: 64
    t.string "unit_selector_tr_key", limit: 64
    t.boolean "deleted", default: false
    t.boolean "require_shipping_address", default: false
    t.boolean "pickup_enabled", default: false
    t.integer "shipping_price_cents"
    t.integer "shipping_price_additional_cents"
    t.string "availability", limit: 32, default: "none"
    t.boolean "per_hour_ready", default: false
    t.string "state", default: "approved"
    t.integer "approval_count", default: 0
    t.index ["author_id", "deleted"], name: "index_on_author_id_and_deleted"
    t.index ["category_id"], name: "index_listings_on_new_category_id"
    t.index ["community_id", "author_id", "deleted"], name: "community_author_deleted"
    t.index ["community_id", "author_id"], name: "person_listings"
    t.index ["community_id", "open", "state", "deleted", "valid_until", "sort_date"], name: "listings_homepage_query"
    t.index ["community_id", "open", "state", "deleted", "valid_until", "updates_email_at", "created_at"], name: "listings_updates_email"
    t.index ["community_id"], name: "index_listings_on_community_id"
    t.index ["listing_shape_id"], name: "index_listings_on_listing_shape_id"
    t.index ["old_category_id"], name: "index_listings_on_category_id"
    t.index ["open"], name: "index_listings_on_open"
    t.index ["state"], name: "index_listings_on_state"
    t.index ["uuid"], name: "index_listings_on_uuid", unique: true
  end

  create_table "locations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.float "latitude"
    t.float "longitude"
    t.string "address"
    t.string "google_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "listing_id"
    t.string "person_id"
    t.string "location_type"
    t.integer "community_id"
    t.index ["community_id"], name: "index_locations_on_community_id"
    t.index ["listing_id"], name: "index_locations_on_listing_id"
    t.index ["person_id"], name: "index_locations_on_person_id"
  end

  create_table "marketplace_configurations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id", null: false
    t.string "main_search", default: "keyword", null: false
    t.string "distance_unit", default: "metric", null: false
    t.integer "limit_priority_links"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "limit_search_distance", default: true, null: false
    t.boolean "display_about_menu", default: true, null: false
    t.boolean "display_contact_menu", default: true, null: false
    t.boolean "display_invite_menu", default: true, null: false
    t.index ["community_id"], name: "index_marketplace_configurations_on_community_id"
  end

  create_table "marketplace_plans", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id", null: false
    t.string "status", limit: 22
    t.text "features"
    t.integer "member_limit"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_marketplace_plans_on_community_id"
    t.index ["created_at"], name: "index_marketplace_plans_on_created_at"
  end

  create_table "marketplace_sender_emails", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id", null: false
    t.string "name"
    t.string "email", null: false
    t.string "verification_status", limit: 32, null: false
    t.datetime "verification_requested_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_marketplace_sender_emails_on_community_id"
  end

  create_table "marketplace_setup_steps", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id", null: false
    t.boolean "slogan_and_description", default: false, null: false
    t.boolean "cover_photo", default: false, null: false
    t.boolean "filter", default: false, null: false
    t.boolean "paypal", default: false, null: false
    t.boolean "listing", default: false, null: false
    t.boolean "invitation", default: false, null: false
    t.boolean "stripe", default: false
    t.boolean "payment", default: false
    t.index ["community_id"], name: "index_marketplace_setup_steps_on_community_id", unique: true
  end

  create_table "marketplace_trials", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id", null: false
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_marketplace_trials_on_community_id"
    t.index ["created_at"], name: "index_marketplace_trials_on_created_at"
  end

  create_table "menu_link_translations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "menu_link_id"
    t.string "locale"
    t.string "url"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_link_id"], name: "index_menu_link_translations_on_menu_link_id"
  end

  create_table "menu_links", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_priority", default: 0
    t.integer "entity_type", default: 0
    t.index ["community_id", "sort_priority"], name: "index_menu_links_on_community_and_sort"
  end

  create_table "mercury_images", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "sender_id"
    t.text "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "conversation_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "order_permissions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "paypal_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "request_token"
    t.string "paypal_username_to", null: false
    t.string "scope"
    t.string "verification_code"
    t.string "onboarding_id", limit: 36
    t.boolean "permissions_granted"
    t.index ["paypal_account_id"], name: "index_order_permissions_on_paypal_account_id"
  end

  create_table "participations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "person_id"
    t.integer "conversation_id"
    t.boolean "is_read", default: false
    t.boolean "is_starter", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_sent_at"
    t.datetime "last_received_at"
    t.boolean "feedback_skipped", default: false
    t.index ["conversation_id"], name: "index_participations_on_conversation_id"
    t.index ["person_id"], name: "index_participations_on_person_id"
  end

  create_table "payment_settings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.boolean "active", null: false
    t.integer "community_id", null: false
    t.string "payment_gateway", limit: 64
    t.string "payment_process", limit: 64
    t.integer "commission_from_seller"
    t.integer "minimum_price_cents"
    t.string "minimum_price_currency", limit: 3
    t.integer "minimum_transaction_fee_cents"
    t.string "minimum_transaction_fee_currency", limit: 3
    t.integer "confirmation_after_days", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_client_id"
    t.string "api_private_key"
    t.string "api_publishable_key"
    t.boolean "api_verified"
    t.string "api_visible_private_key"
    t.string "api_country"
    t.integer "commission_from_buyer"
    t.integer "minimum_buyer_transaction_fee_cents"
    t.string "minimum_buyer_transaction_fee_currency", limit: 3
    t.boolean "key_encryption_padding", default: false
    t.index ["community_id"], name: "index_payment_settings_on_community_id"
  end

  create_table "paypal_accounts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "person_id"
    t.integer "community_id"
    t.string "email"
    t.string "payer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
    t.index ["community_id"], name: "index_paypal_accounts_on_community_id"
    t.index ["payer_id"], name: "index_paypal_accounts_on_payer_id"
    t.index ["person_id"], name: "index_paypal_accounts_on_person_id"
  end

  create_table "paypal_ipn_messages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "body"
    t.string "status", limit: 64
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "paypal_payments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id", null: false
    t.integer "transaction_id", null: false
    t.string "payer_id", limit: 64, null: false
    t.string "receiver_id", limit: 64, null: false
    t.string "merchant_id", null: false
    t.string "order_id", limit: 64
    t.datetime "order_date"
    t.string "currency", limit: 8, null: false
    t.integer "order_total_cents"
    t.string "authorization_id", limit: 64
    t.datetime "authorization_date"
    t.datetime "authorization_expires_date"
    t.integer "authorization_total_cents"
    t.string "payment_id", limit: 64
    t.datetime "payment_date"
    t.integer "payment_total_cents"
    t.integer "fee_total_cents"
    t.string "payment_status", limit: 64, null: false
    t.string "pending_reason", limit: 64
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "commission_payment_id", limit: 64
    t.datetime "commission_payment_date"
    t.string "commission_status", limit: 64, default: "not_charged", null: false
    t.string "commission_pending_reason", limit: 64
    t.integer "commission_total_cents"
    t.integer "commission_fee_total_cents"
    t.integer "commission_retry_count", default: 0
    t.index ["authorization_id"], name: "index_paypal_payments_on_authorization_id", unique: true
    t.index ["community_id"], name: "index_paypal_payments_on_community_id"
    t.index ["order_id"], name: "index_paypal_payments_on_order_id", unique: true
    t.index ["transaction_id"], name: "index_paypal_payments_on_transaction_id", unique: true
  end

  create_table "paypal_process_tokens", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "process_token", limit: 64, null: false
    t.integer "community_id", null: false
    t.integer "transaction_id", null: false
    t.boolean "op_completed", default: false, null: false
    t.string "op_name", limit: 64, null: false
    t.text "op_input"
    t.text "op_output"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["process_token"], name: "index_paypal_process_tokens_on_process_token", unique: true
    t.index ["transaction_id", "community_id", "op_name"], name: "index_paypal_process_tokens_on_transaction", unique: true
  end

  create_table "paypal_refunds", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "paypal_payment_id"
    t.string "currency", limit: 8
    t.integer "payment_total_cents"
    t.integer "fee_total_cents"
    t.string "refunding_id", limit: 64
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["refunding_id"], name: "index_paypal_refunds_on_refunding_id", unique: true
  end

  create_table "paypal_tokens", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id", null: false
    t.string "token", limit: 64
    t.integer "transaction_id"
    t.string "payment_action", limit: 32
    t.string "merchant_id", null: false
    t.string "receiver_id", null: false
    t.datetime "created_at"
    t.string "item_name"
    t.integer "item_quantity"
    t.integer "item_price_cents"
    t.string "currency", limit: 8
    t.string "express_checkout_url"
    t.integer "shipping_total_cents"
    t.index ["community_id"], name: "index_paypal_tokens_on_community_id"
    t.index ["token"], name: "index_paypal_tokens_on_token", unique: true
    t.index ["transaction_id"], name: "index_paypal_tokens_on_transaction_id"
  end

  create_table "people", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "id", limit: 22, null: false
    t.binary "uuid", limit: 16, null: false
    t.integer "community_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "is_admin", default: 0
    t.string "locale", default: "fi"
    t.text "preferences"
    t.integer "active_days_count", default: 0
    t.datetime "last_page_load_date"
    t.integer "test_group_number", default: 1
    t.string "username", null: false
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.string "legacy_encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "password_salt"
    t.string "given_name"
    t.string "family_name"
    t.string "display_name"
    t.string "phone_number"
    t.text "description"
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
    t.boolean "image_processing"
    t.string "facebook_id"
    t.string "authentication_token"
    t.datetime "community_updates_last_sent_at"
    t.integer "min_days_between_community_updates", default: 1
    t.boolean "deleted", default: false
    t.string "cloned_from", limit: 22
    t.string "google_oauth2_id"
    t.string "linkedin_id"
    t.index ["authentication_token"], name: "index_people_on_authentication_token"
    t.index ["community_id", "google_oauth2_id"], name: "index_people_on_community_id_and_google_oauth2_id"
    t.index ["community_id", "linkedin_id"], name: "index_people_on_community_id_and_linkedin_id"
    t.index ["community_id"], name: "index_people_on_community_id"
    t.index ["email"], name: "index_people_on_email", unique: true
    t.index ["facebook_id", "community_id"], name: "index_people_on_facebook_id_and_community_id", unique: true
    t.index ["facebook_id"], name: "index_people_on_facebook_id"
    t.index ["google_oauth2_id"], name: "index_people_on_google_oauth2_id"
    t.index ["id"], name: "index_people_on_id"
    t.index ["linkedin_id"], name: "index_people_on_linkedin_id"
    t.index ["reset_password_token"], name: "index_people_on_reset_password_token", unique: true
    t.index ["username", "community_id"], name: "index_people_on_username_and_community_id", unique: true
    t.index ["username"], name: "index_people_on_username"
    t.index ["uuid"], name: "index_people_on_uuid", unique: true
  end

  create_table "sessions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "shipping_addresses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "transaction_id", null: false
    t.string "status"
    t.string "name"
    t.string "phone"
    t.string "postal_code"
    t.string "city"
    t.string "country"
    t.string "state_or_province"
    t.string "street1"
    t.string "street2"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country_code", limit: 8
    t.index ["transaction_id"], name: "index_shipping_addresses_on_transaction_id"
  end

  create_table "social_links", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "community_id"
    t.integer "provider"
    t.string "url"
    t.integer "sort_priority", default: 0
    t.boolean "enabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_social_links_on_community_id"
  end

  create_table "stripe_accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "person_id"
    t.integer "community_id"
    t.string "stripe_seller_id"
    t.string "stripe_bank_id"
    t.string "stripe_customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_version"
    t.index ["api_version"], name: "index_stripe_accounts_on_api_version"
    t.index ["community_id"], name: "index_stripe_accounts_on_community_id"
    t.index ["person_id"], name: "index_stripe_accounts_on_person_id"
  end

  create_table "stripe_payments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id"
    t.integer "transaction_id"
    t.string "payer_id"
    t.string "receiver_id"
    t.string "status"
    t.integer "sum_cents"
    t.integer "commission_cents"
    t.string "currency"
    t.string "stripe_charge_id"
    t.string "stripe_transfer_id"
    t.integer "fee_cents"
    t.integer "real_fee_cents"
    t.integer "subtotal_cents"
    t.datetime "transfered_at"
    t.datetime "available_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "buyer_commission_cents", default: 0
    t.string "stripe_payment_intent_id"
    t.string "stripe_payment_intent_status"
    t.string "stripe_payment_intent_client_secret"
  end

  create_table "testimonials", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.float "grade"
    t.text "text"
    t.string "author_id"
    t.integer "participation_id"
    t.integer "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "receiver_id"
    t.boolean "blocked", default: false
    t.index ["author_id"], name: "index_testimonials_on_author_id"
    t.index ["receiver_id"], name: "index_testimonials_on_receiver_id"
    t.index ["transaction_id"], name: "index_testimonials_on_transaction_id"
  end

  create_table "transaction_process_tokens", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.binary "process_token", limit: 16
    t.integer "community_id", null: false
    t.integer "transaction_id", null: false
    t.boolean "op_completed", default: false, null: false
    t.string "op_name", limit: 64, null: false
    t.text "op_input"
    t.text "op_output"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["process_token"], name: "index_transaction_process_tokens_on_process_token", unique: true
    t.index ["transaction_id", "community_id", "op_name"], name: "index_paypal_process_tokens_on_transaction", unique: true
  end

  create_table "transaction_processes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "community_id"
    t.string "process", limit: 32, null: false
    t.boolean "author_is_seller"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["community_id"], name: "index_transaction_process_on_community_id"
  end

  create_table "transaction_transitions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "to_state"
    t.text "metadata"
    t.integer "sort_key", default: 0
    t.integer "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "most_recent"
    t.index ["sort_key", "transaction_id"], name: "index_transaction_transitions_on_sort_key_and_conversation_id", unique: true
    t.index ["transaction_id"], name: "index_transaction_transitions_on_conversation_id"
  end

  create_table "transactions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "starter_id", null: false
    t.binary "starter_uuid", limit: 16, null: false
    t.integer "listing_id", null: false
    t.binary "listing_uuid", limit: 16, null: false
    t.integer "conversation_id"
    t.integer "automatic_confirmation_after_days", null: false
    t.integer "community_id", null: false
    t.binary "community_uuid", limit: 16, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "starter_skipped_feedback", default: false
    t.boolean "author_skipped_feedback", default: false
    t.datetime "last_transition_at"
    t.string "current_state"
    t.integer "commission_from_seller"
    t.integer "minimum_commission_cents", default: 0
    t.string "minimum_commission_currency"
    t.string "payment_gateway", default: "none", null: false
    t.integer "listing_quantity", default: 1
    t.string "listing_author_id", null: false
    t.binary "listing_author_uuid", limit: 16, null: false
    t.string "listing_title"
    t.string "unit_type", limit: 32
    t.integer "unit_price_cents"
    t.string "unit_price_currency", limit: 8
    t.string "unit_tr_key", limit: 64
    t.string "unit_selector_tr_key", limit: 64
    t.string "payment_process", limit: 31, default: "none"
    t.string "delivery_method", limit: 31, default: "none"
    t.integer "shipping_price_cents"
    t.string "availability", limit: 32, default: "none"
    t.binary "booking_uuid", limit: 16
    t.boolean "deleted", default: false
    t.integer "commission_from_buyer"
    t.integer "minimum_buyer_fee_cents", default: 0
    t.string "minimum_buyer_fee_currency", limit: 3
    t.index ["community_id", "deleted"], name: "transactions_on_cid_and_deleted"
    t.index ["community_id", "starter_id", "current_state"], name: "community_starter_state"
    t.index ["community_id"], name: "index_transactions_on_community_id"
    t.index ["conversation_id"], name: "index_transactions_on_conversation_id"
    t.index ["deleted"], name: "index_transactions_on_deleted"
    t.index ["last_transition_at"], name: "index_transactions_on_last_transition_at"
    t.index ["listing_author_id"], name: "index_transactions_on_listing_author_id"
    t.index ["listing_id"], name: "index_transactions_on_listing_id"
    t.index ["starter_id"], name: "index_transactions_on_starter_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "donalo_stock_stocks", "listings"
end

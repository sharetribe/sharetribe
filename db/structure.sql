CREATE TABLE `auth_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `person_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `last_use_attempt` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_auth_tokens_on_token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `billing_agreements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `paypal_account_id` int(11) NOT NULL,
  `billing_agreement_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `paypal_username_to` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `request_token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_id` int(11) DEFAULT NULL,
  `start_on` date DEFAULT NULL,
  `end_on` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `braintree_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `person_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_street_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_postal_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_locality` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address_region` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `routing_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `hidden_account_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `icon` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `community_id` int(11) DEFAULT NULL,
  `sort_priority` int(11) DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_categories_on_parent_id` (`parent_id`),
  KEY `index_categories_on_url` (`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `category_custom_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) DEFAULT NULL,
  `custom_field_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `category_transaction_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) DEFAULT NULL,
  `transaction_type_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_category_transaction_types_on_category_id` (`category_id`),
  KEY `index_category_transaction_types_on_transaction_type_id` (`transaction_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `category_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) DEFAULT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_category_translations_on_category_id` (`category_id`),
  KEY `category_id_with_locale` (`category_id`,`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `checkout_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id_or_personal_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `merchant_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `merchant_key` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `person_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `listing_id` int(11) DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_comments_on_listing_id` (`listing_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `communities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `domain` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `settings` text COLLATE utf8_unicode_ci,
  `consent` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transaction_agreement_in_use` tinyint(1) DEFAULT '0',
  `email_admins_about_new_members` tinyint(1) DEFAULT '0',
  `use_fb_like` tinyint(1) DEFAULT '0',
  `real_name_required` tinyint(1) DEFAULT '1',
  `feedback_to_admin` tinyint(1) DEFAULT '0',
  `automatic_newsletters` tinyint(1) DEFAULT '1',
  `join_with_invite_only` tinyint(1) DEFAULT '0',
  `use_captcha` tinyint(1) DEFAULT '0',
  `allowed_emails` text COLLATE utf8_unicode_ci,
  `users_can_invite_new_users` tinyint(1) DEFAULT '1',
  `private` tinyint(1) DEFAULT '0',
  `label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `all_users_can_add_news` tinyint(1) DEFAULT '1',
  `show_date_in_listings_list` tinyint(1) DEFAULT '0',
  `custom_frontpage_sidebar` tinyint(1) DEFAULT '0',
  `event_feed_enabled` tinyint(1) DEFAULT '1',
  `slogan` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'other',
  `members_count` int(11) DEFAULT '0',
  `user_limit` int(11) DEFAULT NULL,
  `monthly_price_in_euros` float DEFAULT NULL,
  `logo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `logo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `logo_file_size` int(11) DEFAULT NULL,
  `logo_updated_at` datetime DEFAULT NULL,
  `cover_photo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cover_photo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cover_photo_file_size` int(11) DEFAULT NULL,
  `cover_photo_updated_at` datetime DEFAULT NULL,
  `small_cover_photo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `small_cover_photo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `small_cover_photo_file_size` int(11) DEFAULT NULL,
  `small_cover_photo_updated_at` datetime DEFAULT NULL,
  `custom_color1` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `custom_color2` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `stylesheet_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `stylesheet_needs_recompile` tinyint(1) DEFAULT '0',
  `service_logo_style` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'full-logo',
  `available_currencies` text COLLATE utf8_unicode_ci,
  `facebook_connect_enabled` tinyint(1) DEFAULT '1',
  `vat` int(11) DEFAULT NULL,
  `commission_from_seller` int(11) DEFAULT NULL,
  `only_public_listings` tinyint(1) DEFAULT '1',
  `custom_email_from_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `minimum_price_cents` int(11) DEFAULT NULL,
  `testimonials_in_use` tinyint(1) DEFAULT '1',
  `hide_expiration_date` tinyint(1) DEFAULT '0',
  `facebook_connect_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `facebook_connect_secret` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `google_analytics_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name_display_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'first_name_with_initial',
  `twitter_handle` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `use_community_location_as_default` tinyint(1) DEFAULT '0',
  `show_category_in_listing_list` tinyint(1) DEFAULT '0',
  `default_browse_view` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'grid',
  `wide_logo_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `wide_logo_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `wide_logo_file_size` int(11) DEFAULT NULL,
  `wide_logo_updated_at` datetime DEFAULT NULL,
  `domain_alias` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `preproduction_stylesheet_url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `only_organizations` tinyint(1) DEFAULT NULL,
  `logo_change_allowed` tinyint(1) DEFAULT NULL,
  `terms_change_allowed` tinyint(1) DEFAULT '0',
  `privacy_policy_change_allowed` tinyint(1) DEFAULT '0',
  `custom_fields_allowed` tinyint(1) DEFAULT '0',
  `listing_comments_in_use` tinyint(1) DEFAULT '0',
  `show_listing_publishing_date` tinyint(1) DEFAULT '0',
  `category_change_allowed` tinyint(1) DEFAULT '0',
  `require_verification_to_post_listings` tinyint(1) DEFAULT '0',
  `show_price_filter` tinyint(1) DEFAULT '0',
  `price_filter_min` int(11) DEFAULT '0',
  `price_filter_max` int(11) DEFAULT '100000',
  `automatic_confirmation_after_days` int(11) DEFAULT '14',
  `plan_level` int(11) DEFAULT '0',
  `favicon_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `favicon_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `favicon_file_size` int(11) DEFAULT NULL,
  `favicon_updated_at` datetime DEFAULT NULL,
  `default_min_days_between_community_updates` int(11) DEFAULT '7',
  `listing_location_required` tinyint(1) DEFAULT '0',
  `custom_head_script` text COLLATE utf8_unicode_ci,
  `follow_in_use` tinyint(1) NOT NULL DEFAULT '1',
  `paypal_enabled` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_communities_on_domain` (`domain`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `communities_listings` (
  `community_id` int(11) DEFAULT NULL,
  `listing_id` int(11) DEFAULT NULL,
  KEY `communities_listings` (`listing_id`,`community_id`),
  KEY `index_communities_listings_on_community_id` (`community_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `community_customizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) DEFAULT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `slogan` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `blank_slate` text COLLATE utf8_unicode_ci,
  `welcome_email_content` text COLLATE utf8_unicode_ci,
  `how_to_use_page_content` text COLLATE utf8_unicode_ci,
  `about_page_content` text COLLATE utf8_unicode_ci,
  `terms_page_content` mediumtext COLLATE utf8_unicode_ci,
  `privacy_page_content` text COLLATE utf8_unicode_ci,
  `storefront_label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `signup_info_content` text COLLATE utf8_unicode_ci,
  `private_community_homepage_content` text COLLATE utf8_unicode_ci,
  `verification_to_post_listings_info_content` text COLLATE utf8_unicode_ci,
  `search_placeholder` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transaction_agreement_label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transaction_agreement_content` mediumtext COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_community_customizations_on_community_id` (`community_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `community_memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  `admin` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `consent` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `invitation_id` int(11) DEFAULT NULL,
  `last_page_load_date` datetime DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'accepted',
  `can_post_listings` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `memberships` (`person_id`,`community_id`),
  KEY `index_community_memberships_on_community_id` (`community_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `contact_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `plan_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `marketplace_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `conversations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `listing_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_message_at` datetime DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_conversations_on_listing_id` (`listing_id`),
  KEY `index_conversations_on_community_id` (`community_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `country_managers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `given_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `family_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `country` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `subject_line` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email_content` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `custom_field_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `custom_field_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_custom_field_names_on_custom_field_id` (`custom_field_id`),
  KEY `locale_index` (`custom_field_id`,`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `custom_field_option_selections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `custom_field_value_id` int(11) DEFAULT NULL,
  `custom_field_option_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_selected_options_on_custom_field_value_id` (`custom_field_value_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `custom_field_option_titles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `custom_field_option_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_custom_field_option_titles_on_custom_field_option_id` (`custom_field_option_id`),
  KEY `locale_index` (`custom_field_option_id`,`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `custom_field_options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `custom_field_id` int(11) DEFAULT NULL,
  `sort_priority` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_custom_field_options_on_custom_field_id` (`custom_field_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `custom_field_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `custom_field_id` int(11) DEFAULT NULL,
  `listing_id` int(11) DEFAULT NULL,
  `text_value` text COLLATE utf8_unicode_ci,
  `numeric_value` float DEFAULT NULL,
  `date_value` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_custom_field_values_on_listing_id` (`listing_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `custom_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sort_priority` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `community_id` int(11) DEFAULT NULL,
  `required` tinyint(1) DEFAULT '1',
  `min` float DEFAULT NULL,
  `max` float DEFAULT NULL,
  `allow_decimals` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_custom_fields_on_community_id` (`community_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text COLLATE utf8_unicode_ci,
  `last_error` text COLLATE utf8_unicode_ci,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `queue` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `delayed_jobs_priority` (`priority`,`run_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `confirmation_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `send_notifications` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_emails_on_address` (`address`),
  KEY `index_emails_on_person_id` (`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `feedbacks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` text COLLATE utf8_unicode_ci,
  `author_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_handled` int(11) DEFAULT '0',
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `follower_relationships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `follower_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_follower_relationships_on_person_id_and_follower_id` (`person_id`,`follower_id`),
  KEY `index_follower_relationships_on_person_id` (`person_id`),
  KEY `index_follower_relationships_on_follower_id` (`follower_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `invitations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  `usages_left` int(11) DEFAULT NULL,
  `valid_until` datetime DEFAULT NULL,
  `information` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `inviter_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_invitations_on_inviter_id` (`inviter_id`),
  KEY `index_invitations_on_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `listing_followers` (
  `person_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `listing_id` int(11) DEFAULT NULL,
  KEY `index_listing_followers_on_listing_id` (`listing_id`),
  KEY `index_listing_followers_on_person_id` (`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `listing_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `listing_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `image_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  `image_processing` tinyint(1) DEFAULT NULL,
  `image_downloaded` tinyint(1) DEFAULT '0',
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `author_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_listing_images_on_listing_id` (`listing_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `listings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category_old` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `times_viewed` int(11) DEFAULT '0',
  `language` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updates_email_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_modified` datetime DEFAULT NULL,
  `sort_date` datetime DEFAULT NULL,
  `visibility` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'this_community',
  `listing_type_old` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `origin` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `destination` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `valid_until` datetime DEFAULT NULL,
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  `open` tinyint(1) DEFAULT '1',
  `share_type_old` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `privacy` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'private',
  `comments_count` int(11) DEFAULT '0',
  `subcategory_old` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `old_category_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `share_type_id` int(11) DEFAULT NULL,
  `transaction_type_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `price_cents` int(11) DEFAULT NULL,
  `currency` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `quantity` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_listings_on_listing_type` (`listing_type_old`),
  KEY `index_listings_on_open` (`open`),
  KEY `index_listings_on_visibility` (`visibility`),
  KEY `index_listings_on_category_id` (`old_category_id`),
  KEY `index_listings_on_share_type_id` (`share_type_id`),
  KEY `index_listings_on_transaction_type_id` (`transaction_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `google_address` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `listing_id` int(11) DEFAULT NULL,
  `person_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `location_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_locations_on_person_id` (`person_id`),
  KEY `index_locations_on_listing_id` (`listing_id`),
  KEY `index_locations_on_community_id` (`community_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `menu_link_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_link_id` int(11) DEFAULT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `menu_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sort_priority` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mercury_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `image_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `conversation_id` int(11) DEFAULT NULL,
  `action` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_messages_on_conversation_id` (`conversation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `order_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `paypal_account_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `request_token` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `paypal_username_to` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `scope` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `verification_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `participations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `conversation_id` int(11) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `is_starter` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_sent_at` datetime DEFAULT NULL,
  `last_received_at` datetime DEFAULT NULL,
  `feedback_skipped` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_participations_on_person_id` (`person_id`),
  KEY `index_participations_on_conversation_id` (`conversation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `payment_gateways` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `braintree_environment` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `braintree_merchant_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `braintree_master_merchant_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `braintree_public_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `braintree_private_key` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `braintree_client_side_encryption_key` text COLLATE utf8_unicode_ci,
  `checkout_environment` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `checkout_user_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `checkout_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `gateway_commission_percentage` int(11) DEFAULT NULL,
  `gateway_commission_fixed_cents` int(11) DEFAULT NULL,
  `gateway_commission_fixed_currency` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `payment_rows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `payment_id` int(11) DEFAULT NULL,
  `vat` int(11) DEFAULT NULL,
  `sum_cents` int(11) DEFAULT NULL,
  `currency` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_payment_rows_on_payment_id` (`payment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `payer_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `recipient_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `organization_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `transaction_id` int(11) DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `community_id` int(11) DEFAULT NULL,
  `payment_gateway_id` int(11) DEFAULT NULL,
  `sum_cents` int(11) DEFAULT NULL,
  `currency` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'CheckoutPayment',
  `braintree_transaction_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_payments_on_payer_id` (`payer_id`),
  KEY `index_payments_on_conversation_id` (`transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `paypal_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `payer_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `people` (
  `id` varchar(22) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_admin` int(11) DEFAULT '0',
  `locale` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'fi',
  `preferences` text COLLATE utf8_unicode_ci,
  `active_days_count` int(11) DEFAULT '0',
  `last_page_load_date` datetime DEFAULT NULL,
  `test_group_number` int(11) DEFAULT '1',
  `active` tinyint(1) DEFAULT '1',
  `username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `encrypted_password` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password_salt` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `given_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `family_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone_number` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `image_file_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_content_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  `facebook_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `authentication_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `community_updates_last_sent_at` datetime DEFAULT NULL,
  `min_days_between_community_updates` int(11) DEFAULT '1',
  `is_organization` tinyint(1) DEFAULT NULL,
  `organization_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  UNIQUE KEY `index_people_on_email` (`email`),
  UNIQUE KEY `index_people_on_facebook_id` (`facebook_id`),
  UNIQUE KEY `index_people_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_people_on_username` (`username`),
  KEY `index_people_on_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `data` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `statistics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `users_count` int(11) DEFAULT NULL,
  `two_week_content_activation_percentage` float DEFAULT NULL,
  `four_week_transaction_activation_percentage` float DEFAULT NULL,
  `mau_g1` float DEFAULT NULL,
  `wau_g1` float DEFAULT NULL,
  `dau_g1` float DEFAULT NULL,
  `mau_g2` float DEFAULT NULL,
  `wau_g2` float DEFAULT NULL,
  `dau_g2` float DEFAULT NULL,
  `mau_g3` float DEFAULT NULL,
  `wau_g3` float DEFAULT NULL,
  `dau_g3` float DEFAULT NULL,
  `invitations_sent_per_user` float DEFAULT NULL,
  `invitations_accepted_per_user` float DEFAULT NULL,
  `revenue_per_mau_g1` float DEFAULT NULL,
  `extra_data` text COLLATE utf8_unicode_ci,
  `mau_g1_count` int(11) DEFAULT NULL,
  `wau_g1_count` int(11) DEFAULT NULL,
  `listings_count` int(11) DEFAULT NULL,
  `new_listings_last_week` int(11) DEFAULT NULL,
  `new_listings_last_month` int(11) DEFAULT NULL,
  `conversations_count` int(11) DEFAULT NULL,
  `new_conversations_last_week` int(11) DEFAULT NULL,
  `new_conversations_last_month` int(11) DEFAULT NULL,
  `messages_count` int(11) DEFAULT NULL,
  `new_messages_last_week` int(11) DEFAULT NULL,
  `new_messages_last_month` int(11) DEFAULT NULL,
  `transactions_count` int(11) DEFAULT NULL,
  `new_transactions_last_week` int(11) DEFAULT NULL,
  `new_transactions_last_month` int(11) DEFAULT NULL,
  `new_users_last_week` int(11) DEFAULT NULL,
  `new_users_last_month` int(11) DEFAULT NULL,
  `user_count_weekly_growth` float DEFAULT NULL,
  `wau_weekly_growth` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_statistics_on_community_id` (`community_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `testimonials` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `grade` float DEFAULT NULL,
  `text` text COLLATE utf8_unicode_ci,
  `author_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `participation_id` int(11) DEFAULT NULL,
  `transaction_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `receiver_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_testimonials_on_receiver_id` (`receiver_id`),
  KEY `index_testimonials_on_transaction_id` (`transaction_id`),
  KEY `index_testimonials_on_author_id` (`author_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `transaction_transitions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `to_state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `metadata` text COLLATE utf8_unicode_ci,
  `sort_key` int(11) DEFAULT '0',
  `transaction_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_transaction_transitions_on_sort_key_and_conversation_id` (`sort_key`,`transaction_id`),
  KEY `index_transaction_transitions_on_conversation_id` (`transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `transaction_type_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_type_id` int(11) DEFAULT NULL,
  `locale` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `action_button_label` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_transaction_type_translations_on_transaction_type_id` (`transaction_type_id`),
  KEY `locale_index` (`transaction_type_id`,`locale`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `transaction_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  `sort_priority` int(11) DEFAULT NULL,
  `price_field` tinyint(1) DEFAULT NULL,
  `preauthorize_payment` tinyint(1) DEFAULT '0',
  `price_quantity_placeholder` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `price_per` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `url` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_transaction_types_on_community_id` (`community_id`),
  KEY `index_transaction_types_on_url` (`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `starter_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `listing_id` int(11) NOT NULL,
  `conversation_id` int(11) DEFAULT NULL,
  `automatic_confirmation_after_days` int(11) DEFAULT NULL,
  `community_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `starter_skipped_feedback` tinyint(1) DEFAULT '0',
  `author_skipped_feedback` tinyint(1) DEFAULT '0',
  `last_activity_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_transactions_on_listing_id` (`listing_id`),
  KEY `index_transactions_on_conversation_id` (`conversation_id`),
  KEY `index_transactions_on_community_id` (`community_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20080806070738');

INSERT INTO schema_migrations (version) VALUES ('20080807071903');

INSERT INTO schema_migrations (version) VALUES ('20080807080513');

INSERT INTO schema_migrations (version) VALUES ('20080808095031');

INSERT INTO schema_migrations (version) VALUES ('20080815075550');

INSERT INTO schema_migrations (version) VALUES ('20080818091109');

INSERT INTO schema_migrations (version) VALUES ('20080818092139');

INSERT INTO schema_migrations (version) VALUES ('20080821103835');

INSERT INTO schema_migrations (version) VALUES ('20080825064927');

INSERT INTO schema_migrations (version) VALUES ('20080825114546');

INSERT INTO schema_migrations (version) VALUES ('20080828104013');

INSERT INTO schema_migrations (version) VALUES ('20080828104239');

INSERT INTO schema_migrations (version) VALUES ('20080919122825');

INSERT INTO schema_migrations (version) VALUES ('20080925100643');

INSERT INTO schema_migrations (version) VALUES ('20080925100743');

INSERT INTO schema_migrations (version) VALUES ('20080925103547');

INSERT INTO schema_migrations (version) VALUES ('20080925103759');

INSERT INTO schema_migrations (version) VALUES ('20080925112423');

INSERT INTO schema_migrations (version) VALUES ('20080925114309');

INSERT INTO schema_migrations (version) VALUES ('20080929102121');

INSERT INTO schema_migrations (version) VALUES ('20081008115110');

INSERT INTO schema_migrations (version) VALUES ('20081009160751');

INSERT INTO schema_migrations (version) VALUES ('20081010114150');

INSERT INTO schema_migrations (version) VALUES ('20081024154431');

INSERT INTO schema_migrations (version) VALUES ('20081024182346');

INSERT INTO schema_migrations (version) VALUES ('20081024183444');

INSERT INTO schema_migrations (version) VALUES ('20081103092143');

INSERT INTO schema_migrations (version) VALUES ('20081104070403');

INSERT INTO schema_migrations (version) VALUES ('20081118145857');

INSERT INTO schema_migrations (version) VALUES ('20081121084337');

INSERT INTO schema_migrations (version) VALUES ('20081202140109');

INSERT INTO schema_migrations (version) VALUES ('20081205142238');

INSERT INTO schema_migrations (version) VALUES ('20081215145238');

INSERT INTO schema_migrations (version) VALUES ('20081216060503');

INSERT INTO schema_migrations (version) VALUES ('20090119114525');

INSERT INTO schema_migrations (version) VALUES ('20090218112317');

INSERT INTO schema_migrations (version) VALUES ('20090219094209');

INSERT INTO schema_migrations (version) VALUES ('20090225073742');

INSERT INTO schema_migrations (version) VALUES ('20090323121824');

INSERT INTO schema_migrations (version) VALUES ('20090330064443');

INSERT INTO schema_migrations (version) VALUES ('20090330070210');

INSERT INTO schema_migrations (version) VALUES ('20090330072036');

INSERT INTO schema_migrations (version) VALUES ('20090401181848');

INSERT INTO schema_migrations (version) VALUES ('20090401184511');

INSERT INTO schema_migrations (version) VALUES ('20090401185039');

INSERT INTO schema_migrations (version) VALUES ('20090402144456');

INSERT INTO schema_migrations (version) VALUES ('20090403093157');

INSERT INTO schema_migrations (version) VALUES ('20090406081353');

INSERT INTO schema_migrations (version) VALUES ('20090414142556');

INSERT INTO schema_migrations (version) VALUES ('20090415085812');

INSERT INTO schema_migrations (version) VALUES ('20090415130553');

INSERT INTO schema_migrations (version) VALUES ('20090415131023');

INSERT INTO schema_migrations (version) VALUES ('20090424093506');

INSERT INTO schema_migrations (version) VALUES ('20090424100145');

INSERT INTO schema_migrations (version) VALUES ('20090618112730');

INSERT INTO schema_migrations (version) VALUES ('20090629113838');

INSERT INTO schema_migrations (version) VALUES ('20090629131727');

INSERT INTO schema_migrations (version) VALUES ('20090701065350');

INSERT INTO schema_migrations (version) VALUES ('20090701110931');

INSERT INTO schema_migrations (version) VALUES ('20090713130351');

INSERT INTO schema_migrations (version) VALUES ('20090729124418');

INSERT INTO schema_migrations (version) VALUES ('20090730093917');

INSERT INTO schema_migrations (version) VALUES ('20090730094216');

INSERT INTO schema_migrations (version) VALUES ('20090731134028');

INSERT INTO schema_migrations (version) VALUES ('20090821075949');

INSERT INTO schema_migrations (version) VALUES ('20090904120242');

INSERT INTO schema_migrations (version) VALUES ('20090907155717');

INSERT INTO schema_migrations (version) VALUES ('20091006112446');

INSERT INTO schema_migrations (version) VALUES ('20091028095545');

INSERT INTO schema_migrations (version) VALUES ('20091028131201');

INSERT INTO schema_migrations (version) VALUES ('20091109161516');

INSERT INTO schema_migrations (version) VALUES ('20100322132547');

INSERT INTO schema_migrations (version) VALUES ('20100505110646');

INSERT INTO schema_migrations (version) VALUES ('20100707105549');

INSERT INTO schema_migrations (version) VALUES ('20100721120037');

INSERT INTO schema_migrations (version) VALUES ('20100721123825');

INSERT INTO schema_migrations (version) VALUES ('20100721124444');

INSERT INTO schema_migrations (version) VALUES ('20100726071811');

INSERT INTO schema_migrations (version) VALUES ('20100727102551');

INSERT INTO schema_migrations (version) VALUES ('20100727103659');

INSERT INTO schema_migrations (version) VALUES ('20100729112458');

INSERT INTO schema_migrations (version) VALUES ('20100729124210');

INSERT INTO schema_migrations (version) VALUES ('20100729141955');

INSERT INTO schema_migrations (version) VALUES ('20100729142416');

INSERT INTO schema_migrations (version) VALUES ('20100730120601');

INSERT INTO schema_migrations (version) VALUES ('20100730132825');

INSERT INTO schema_migrations (version) VALUES ('20100809090550');

INSERT INTO schema_migrations (version) VALUES ('20100809120502');

INSERT INTO schema_migrations (version) VALUES ('20100813161213');

INSERT INTO schema_migrations (version) VALUES ('20100817115816');

INSERT INTO schema_migrations (version) VALUES ('20100818102743');

INSERT INTO schema_migrations (version) VALUES ('20100819114104');

INSERT INTO schema_migrations (version) VALUES ('20100820122449');

INSERT INTO schema_migrations (version) VALUES ('20100902135234');

INSERT INTO schema_migrations (version) VALUES ('20100902142325');

INSERT INTO schema_migrations (version) VALUES ('20100908112841');

INSERT INTO schema_migrations (version) VALUES ('20100909105810');

INSERT INTO schema_migrations (version) VALUES ('20100909114132');

INSERT INTO schema_migrations (version) VALUES ('20100920075651');

INSERT INTO schema_migrations (version) VALUES ('20100921155612');

INSERT INTO schema_migrations (version) VALUES ('20100922081110');

INSERT INTO schema_migrations (version) VALUES ('20100922102321');

INSERT INTO schema_migrations (version) VALUES ('20100922122740');

INSERT INTO schema_migrations (version) VALUES ('20100923074241');

INSERT INTO schema_migrations (version) VALUES ('20100927150547');

INSERT INTO schema_migrations (version) VALUES ('20101007131610');

INSERT INTO schema_migrations (version) VALUES ('20101007131827');

INSERT INTO schema_migrations (version) VALUES ('20101013115208');

INSERT INTO schema_migrations (version) VALUES ('20101013124056');

INSERT INTO schema_migrations (version) VALUES ('20101026082126');

INSERT INTO schema_migrations (version) VALUES ('20101027103753');

INSERT INTO schema_migrations (version) VALUES ('20101028151541');

INSERT INTO schema_migrations (version) VALUES ('20101103154108');

INSERT INTO schema_migrations (version) VALUES ('20101103161641');

INSERT INTO schema_migrations (version) VALUES ('20101103163019');

INSERT INTO schema_migrations (version) VALUES ('20101109131431');

INSERT INTO schema_migrations (version) VALUES ('20101116105410');

INSERT INTO schema_migrations (version) VALUES ('20101124104905');

INSERT INTO schema_migrations (version) VALUES ('20101125150638');

INSERT INTO schema_migrations (version) VALUES ('20101126093026');

INSERT INTO schema_migrations (version) VALUES ('20101201105920');

INSERT INTO schema_migrations (version) VALUES ('20101201133429');

INSERT INTO schema_migrations (version) VALUES ('20101203115308');

INSERT INTO schema_migrations (version) VALUES ('20101203115634');

INSERT INTO schema_migrations (version) VALUES ('20101213152125');

INSERT INTO schema_migrations (version) VALUES ('20101216150725');

INSERT INTO schema_migrations (version) VALUES ('20101216151447');

INSERT INTO schema_migrations (version) VALUES ('20101216152952');

INSERT INTO schema_migrations (version) VALUES ('20110308172759');

INSERT INTO schema_migrations (version) VALUES ('20110308192757');

INSERT INTO schema_migrations (version) VALUES ('20110321103604');

INSERT INTO schema_migrations (version) VALUES ('20110322141439');

INSERT INTO schema_migrations (version) VALUES ('20110322151957');

INSERT INTO schema_migrations (version) VALUES ('20110325120932');

INSERT INTO schema_migrations (version) VALUES ('20110412075940');

INSERT INTO schema_migrations (version) VALUES ('20110414105702');

INSERT INTO schema_migrations (version) VALUES ('20110414124938');

INSERT INTO schema_migrations (version) VALUES ('20110421075758');

INSERT INTO schema_migrations (version) VALUES ('20110428134543');

INSERT INTO schema_migrations (version) VALUES ('20110529110417');

INSERT INTO schema_migrations (version) VALUES ('20110629135331');

INSERT INTO schema_migrations (version) VALUES ('20110704123058');

INSERT INTO schema_migrations (version) VALUES ('20110704144650');

INSERT INTO schema_migrations (version) VALUES ('20110707163036');

INSERT INTO schema_migrations (version) VALUES ('20110728110124');

INSERT INTO schema_migrations (version) VALUES ('20110808110217');

INSERT INTO schema_migrations (version) VALUES ('20110808161514');

INSERT INTO schema_migrations (version) VALUES ('20110817123457');

INSERT INTO schema_migrations (version) VALUES ('20110819111416');

INSERT INTO schema_migrations (version) VALUES ('20110819123636');

INSERT INTO schema_migrations (version) VALUES ('20110909072646');

INSERT INTO schema_migrations (version) VALUES ('20110912061834');

INSERT INTO schema_migrations (version) VALUES ('20110912064526');

INSERT INTO schema_migrations (version) VALUES ('20110912065222');

INSERT INTO schema_migrations (version) VALUES ('20110913080622');

INSERT INTO schema_migrations (version) VALUES ('20110914080549');

INSERT INTO schema_migrations (version) VALUES ('20110914115824');

INSERT INTO schema_migrations (version) VALUES ('20110915084232');

INSERT INTO schema_migrations (version) VALUES ('20110915101535');

INSERT INTO schema_migrations (version) VALUES ('20111111140246');

INSERT INTO schema_migrations (version) VALUES ('20111111154416');

INSERT INTO schema_migrations (version) VALUES ('20111111162432');

INSERT INTO schema_migrations (version) VALUES ('20111114122125');

INSERT INTO schema_migrations (version) VALUES ('20111114122315');

INSERT INTO schema_migrations (version) VALUES ('20111116144337');

INSERT INTO schema_migrations (version) VALUES ('20111116164728');

INSERT INTO schema_migrations (version) VALUES ('20111116182825');

INSERT INTO schema_migrations (version) VALUES ('20111123071116');

INSERT INTO schema_migrations (version) VALUES ('20111123071850');

INSERT INTO schema_migrations (version) VALUES ('20111124174508');

INSERT INTO schema_migrations (version) VALUES ('20111210165312');

INSERT INTO schema_migrations (version) VALUES ('20111210165854');

INSERT INTO schema_migrations (version) VALUES ('20111210170231');

INSERT INTO schema_migrations (version) VALUES ('20111211175403');

INSERT INTO schema_migrations (version) VALUES ('20111228153911');

INSERT INTO schema_migrations (version) VALUES ('20120104224115');

INSERT INTO schema_migrations (version) VALUES ('20120105162140');

INSERT INTO schema_migrations (version) VALUES ('20120113091548');

INSERT INTO schema_migrations (version) VALUES ('20120121091558');

INSERT INTO schema_migrations (version) VALUES ('20120206052931');

INSERT INTO schema_migrations (version) VALUES ('20120208145336');

INSERT INTO schema_migrations (version) VALUES ('20120210171827');

INSERT INTO schema_migrations (version) VALUES ('20120303113202');

INSERT INTO schema_migrations (version) VALUES ('20120303125412');

INSERT INTO schema_migrations (version) VALUES ('20120303152837');

INSERT INTO schema_migrations (version) VALUES ('20120303172713');

INSERT INTO schema_migrations (version) VALUES ('20120510094327');

INSERT INTO schema_migrations (version) VALUES ('20120510175152');

INSERT INTO schema_migrations (version) VALUES ('20120514001557');

INSERT INTO schema_migrations (version) VALUES ('20120514050302');

INSERT INTO schema_migrations (version) VALUES ('20120516204538');

INSERT INTO schema_migrations (version) VALUES ('20120518203511');

INSERT INTO schema_migrations (version) VALUES ('20120522162329');

INSERT INTO schema_migrations (version) VALUES ('20120522183329');

INSERT INTO schema_migrations (version) VALUES ('20120526021050');

INSERT INTO schema_migrations (version) VALUES ('20120614052244');

INSERT INTO schema_migrations (version) VALUES ('20120625211426');

INSERT INTO schema_migrations (version) VALUES ('20120628121713');

INSERT INTO schema_migrations (version) VALUES ('20120704072606');

INSERT INTO schema_migrations (version) VALUES ('20120705135703');

INSERT INTO schema_migrations (version) VALUES ('20120705140109');

INSERT INTO schema_migrations (version) VALUES ('20120710084323');

INSERT INTO schema_migrations (version) VALUES ('20120711140918');

INSERT INTO schema_migrations (version) VALUES ('20120718031225');

INSERT INTO schema_migrations (version) VALUES ('20120730024756');

INSERT INTO schema_migrations (version) VALUES ('20120907010347');

INSERT INTO schema_migrations (version) VALUES ('20120907023525');

INSERT INTO schema_migrations (version) VALUES ('20120908052908');

INSERT INTO schema_migrations (version) VALUES ('20120909143322');

INSERT INTO schema_migrations (version) VALUES ('20120929084903');

INSERT INTO schema_migrations (version) VALUES ('20120929091629');

INSERT INTO schema_migrations (version) VALUES ('20121023050946');

INSERT INTO schema_migrations (version) VALUES ('20121105115053');

INSERT INTO schema_migrations (version) VALUES ('20121203142830');

INSERT INTO schema_migrations (version) VALUES ('20121212145626');

INSERT INTO schema_migrations (version) VALUES ('20121214083430');

INSERT INTO schema_migrations (version) VALUES ('20121218125831');

INSERT INTO schema_migrations (version) VALUES ('20121220133808');

INSERT INTO schema_migrations (version) VALUES ('20121229224803');

INSERT INTO schema_migrations (version) VALUES ('20130103081705');

INSERT INTO schema_migrations (version) VALUES ('20130103125240');

INSERT INTO schema_migrations (version) VALUES ('20130103145816');

INSERT INTO schema_migrations (version) VALUES ('20130104071929');

INSERT INTO schema_migrations (version) VALUES ('20130104122958');

INSERT INTO schema_migrations (version) VALUES ('20130105153450');

INSERT INTO schema_migrations (version) VALUES ('20130107095027');

INSERT INTO schema_migrations (version) VALUES ('20130110222425');

INSERT INTO schema_migrations (version) VALUES ('20130123163722');

INSERT INTO schema_migrations (version) VALUES ('20130123164653');

INSERT INTO schema_migrations (version) VALUES ('20130124150000');

INSERT INTO schema_migrations (version) VALUES ('20130208085827');

INSERT INTO schema_migrations (version) VALUES ('20130212104852');

INSERT INTO schema_migrations (version) VALUES ('20130213150133');

INSERT INTO schema_migrations (version) VALUES ('20130213160145');

INSERT INTO schema_migrations (version) VALUES ('20130217121320');

INSERT INTO schema_migrations (version) VALUES ('20130218070405');

INSERT INTO schema_migrations (version) VALUES ('20130305095824');

INSERT INTO schema_migrations (version) VALUES ('20130306172327');

INSERT INTO schema_migrations (version) VALUES ('20130309142322');

INSERT INTO schema_migrations (version) VALUES ('20130317162509');

INSERT INTO schema_migrations (version) VALUES ('20130318083721');

INSERT INTO schema_migrations (version) VALUES ('20130318084043');

INSERT INTO schema_migrations (version) VALUES ('20130318085152');

INSERT INTO schema_migrations (version) VALUES ('20130319162158');

INSERT INTO schema_migrations (version) VALUES ('20130319163113');

INSERT INTO schema_migrations (version) VALUES ('20130320093549');

INSERT INTO schema_migrations (version) VALUES ('20130322171458');

INSERT INTO schema_migrations (version) VALUES ('20130323143126');

INSERT INTO schema_migrations (version) VALUES ('20130325143038');

INSERT INTO schema_migrations (version) VALUES ('20130325153817');

INSERT INTO schema_migrations (version) VALUES ('20130325161150');

INSERT INTO schema_migrations (version) VALUES ('20130325165508');

INSERT INTO schema_migrations (version) VALUES ('20130325174608');

INSERT INTO schema_migrations (version) VALUES ('20130325181741');

INSERT INTO schema_migrations (version) VALUES ('20130326160252');

INSERT INTO schema_migrations (version) VALUES ('20130328124654');

INSERT INTO schema_migrations (version) VALUES ('20130328155825');

INSERT INTO schema_migrations (version) VALUES ('20130329080756');

INSERT INTO schema_migrations (version) VALUES ('20130329081612');

INSERT INTO schema_migrations (version) VALUES ('20130331095134');

INSERT INTO schema_migrations (version) VALUES ('20130331144047');

INSERT INTO schema_migrations (version) VALUES ('20130331200801');

INSERT INTO schema_migrations (version) VALUES ('20130405114540');

INSERT INTO schema_migrations (version) VALUES ('20130418172231');

INSERT INTO schema_migrations (version) VALUES ('20130418173835');

INSERT INTO schema_migrations (version) VALUES ('20130423173017');

INSERT INTO schema_migrations (version) VALUES ('20130424180017');

INSERT INTO schema_migrations (version) VALUES ('20130424183653');

INSERT INTO schema_migrations (version) VALUES ('20130425140120');

INSERT INTO schema_migrations (version) VALUES ('20130514214222');

INSERT INTO schema_migrations (version) VALUES ('20130517133311');

INSERT INTO schema_migrations (version) VALUES ('20130520092054');

INSERT INTO schema_migrations (version) VALUES ('20130520092357');

INSERT INTO schema_migrations (version) VALUES ('20130520103753');

INSERT INTO schema_migrations (version) VALUES ('20130520125924');

INSERT INTO schema_migrations (version) VALUES ('20130520140756');

INSERT INTO schema_migrations (version) VALUES ('20130520172713');

INSERT INTO schema_migrations (version) VALUES ('20130521122031');

INSERT INTO schema_migrations (version) VALUES ('20130521124342');

INSERT INTO schema_migrations (version) VALUES ('20130521171401');

INSERT INTO schema_migrations (version) VALUES ('20130521225614');

INSERT INTO schema_migrations (version) VALUES ('20130531072349');

INSERT INTO schema_migrations (version) VALUES ('20130605074725');

INSERT INTO schema_migrations (version) VALUES ('20130607165451');

INSERT INTO schema_migrations (version) VALUES ('20130710084408');

INSERT INTO schema_migrations (version) VALUES ('20130718104939');

INSERT INTO schema_migrations (version) VALUES ('20130719093816');

INSERT INTO schema_migrations (version) VALUES ('20130719113330');

INSERT INTO schema_migrations (version) VALUES ('20130724065048');

INSERT INTO schema_migrations (version) VALUES ('20130724070139');

INSERT INTO schema_migrations (version) VALUES ('20130729081847');

INSERT INTO schema_migrations (version) VALUES ('20130807083847');

INSERT INTO schema_migrations (version) VALUES ('20130815072527');

INSERT INTO schema_migrations (version) VALUES ('20130815073546');

INSERT INTO schema_migrations (version) VALUES ('20130815075659');

INSERT INTO schema_migrations (version) VALUES ('20130815101112');

INSERT INTO schema_migrations (version) VALUES ('20130823110113');

INSERT INTO schema_migrations (version) VALUES ('20130902140027');

INSERT INTO schema_migrations (version) VALUES ('20130910133213');

INSERT INTO schema_migrations (version) VALUES ('20130917094727');

INSERT INTO schema_migrations (version) VALUES ('20130920121927');

INSERT INTO schema_migrations (version) VALUES ('20130925071631');

INSERT INTO schema_migrations (version) VALUES ('20130925081815');

INSERT INTO schema_migrations (version) VALUES ('20130926070322');

INSERT INTO schema_migrations (version) VALUES ('20130926121237');

INSERT INTO schema_migrations (version) VALUES ('20130930080143');

INSERT INTO schema_migrations (version) VALUES ('20131024081428');

INSERT INTO schema_migrations (version) VALUES ('20131028110133');

INSERT INTO schema_migrations (version) VALUES ('20131028154626');

INSERT INTO schema_migrations (version) VALUES ('20131028183014');

INSERT INTO schema_migrations (version) VALUES ('20131030130320');

INSERT INTO schema_migrations (version) VALUES ('20131031072301');

INSERT INTO schema_migrations (version) VALUES ('20131031093809');

INSERT INTO schema_migrations (version) VALUES ('20131101183938');

INSERT INTO schema_migrations (version) VALUES ('20131104090808');

INSERT INTO schema_migrations (version) VALUES ('20131107124835');

INSERT INTO schema_migrations (version) VALUES ('20131107125413');

INSERT INTO schema_migrations (version) VALUES ('20131108091824');

INSERT INTO schema_migrations (version) VALUES ('20131108113632');

INSERT INTO schema_migrations (version) VALUES ('20131108113650');

INSERT INTO schema_migrations (version) VALUES ('20131111140902');

INSERT INTO schema_migrations (version) VALUES ('20131112115307');

INSERT INTO schema_migrations (version) VALUES ('20131112115308');

INSERT INTO schema_migrations (version) VALUES ('20131112115435');

INSERT INTO schema_migrations (version) VALUES ('20131114112955');

INSERT INTO schema_migrations (version) VALUES ('20131119085439');

INSERT INTO schema_migrations (version) VALUES ('20131119085625');

INSERT INTO schema_migrations (version) VALUES ('20131122175753');

INSERT INTO schema_migrations (version) VALUES ('20131126113141');

INSERT INTO schema_migrations (version) VALUES ('20131126131750');

INSERT INTO schema_migrations (version) VALUES ('20131126134024');

INSERT INTO schema_migrations (version) VALUES ('20131126184439');

INSERT INTO schema_migrations (version) VALUES ('20131128074254');

INSERT INTO schema_migrations (version) VALUES ('20131128074910');

INSERT INTO schema_migrations (version) VALUES ('20131128094614');

INSERT INTO schema_migrations (version) VALUES ('20131128094758');

INSERT INTO schema_migrations (version) VALUES ('20131128094839');

INSERT INTO schema_migrations (version) VALUES ('20131128103251');

INSERT INTO schema_migrations (version) VALUES ('20131128143205');

INSERT INTO schema_migrations (version) VALUES ('20131129095727');

INSERT INTO schema_migrations (version) VALUES ('20131202140547');

INSERT INTO schema_migrations (version) VALUES ('20131203072124');

INSERT INTO schema_migrations (version) VALUES ('20131204091623');

INSERT INTO schema_migrations (version) VALUES ('20131204103910');

INSERT INTO schema_migrations (version) VALUES ('20131206163837');

INSERT INTO schema_migrations (version) VALUES ('20131209073416');

INSERT INTO schema_migrations (version) VALUES ('20131209133946');

INSERT INTO schema_migrations (version) VALUES ('20131210155502');

INSERT INTO schema_migrations (version) VALUES ('20131212065037');

INSERT INTO schema_migrations (version) VALUES ('20131214142413');

INSERT INTO schema_migrations (version) VALUES ('20131214143004');

INSERT INTO schema_migrations (version) VALUES ('20131214143005');

INSERT INTO schema_migrations (version) VALUES ('20131220084742');

INSERT INTO schema_migrations (version) VALUES ('20131220104804');

INSERT INTO schema_migrations (version) VALUES ('20131220104805');

INSERT INTO schema_migrations (version) VALUES ('20131227080454');

INSERT INTO schema_migrations (version) VALUES ('20131227081256');

INSERT INTO schema_migrations (version) VALUES ('20140102125702');

INSERT INTO schema_migrations (version) VALUES ('20140102141643');

INSERT INTO schema_migrations (version) VALUES ('20140102144755');

INSERT INTO schema_migrations (version) VALUES ('20140102145633');

INSERT INTO schema_migrations (version) VALUES ('20140102150134');

INSERT INTO schema_migrations (version) VALUES ('20140102153949');

INSERT INTO schema_migrations (version) VALUES ('20140103084331');

INSERT INTO schema_migrations (version) VALUES ('20140103131350');

INSERT INTO schema_migrations (version) VALUES ('20140106114557');

INSERT INTO schema_migrations (version) VALUES ('20140109091819');

INSERT INTO schema_migrations (version) VALUES ('20140109093432');

INSERT INTO schema_migrations (version) VALUES ('20140109143257');

INSERT INTO schema_migrations (version) VALUES ('20140109190928');

INSERT INTO schema_migrations (version) VALUES ('20140116131654');

INSERT INTO schema_migrations (version) VALUES ('20140123141906');

INSERT INTO schema_migrations (version) VALUES ('20140124095930');

INSERT INTO schema_migrations (version) VALUES ('20140124141214');

INSERT INTO schema_migrations (version) VALUES ('20140128094422');

INSERT INTO schema_migrations (version) VALUES ('20140128094642');

INSERT INTO schema_migrations (version) VALUES ('20140128095047');

INSERT INTO schema_migrations (version) VALUES ('20140129081030');

INSERT INTO schema_migrations (version) VALUES ('20140204082210');

INSERT INTO schema_migrations (version) VALUES ('20140205092212');

INSERT INTO schema_migrations (version) VALUES ('20140205101011');

INSERT INTO schema_migrations (version) VALUES ('20140205121010');

INSERT INTO schema_migrations (version) VALUES ('20140206103152');

INSERT INTO schema_migrations (version) VALUES ('20140207133412');

INSERT INTO schema_migrations (version) VALUES ('20140219160247');

INSERT INTO schema_migrations (version) VALUES ('20140219162023');

INSERT INTO schema_migrations (version) VALUES ('20140222080916');

INSERT INTO schema_migrations (version) VALUES ('20140223190922');

INSERT INTO schema_migrations (version) VALUES ('20140223202734');

INSERT INTO schema_migrations (version) VALUES ('20140223210213');

INSERT INTO schema_migrations (version) VALUES ('20140224150322');

INSERT INTO schema_migrations (version) VALUES ('20140224151953');

INSERT INTO schema_migrations (version) VALUES ('20140225143012');

INSERT INTO schema_migrations (version) VALUES ('20140226074348');

INSERT INTO schema_migrations (version) VALUES ('20140226074445');

INSERT INTO schema_migrations (version) VALUES ('20140226074710');

INSERT INTO schema_migrations (version) VALUES ('20140226074751');

INSERT INTO schema_migrations (version) VALUES ('20140226121423');

INSERT INTO schema_migrations (version) VALUES ('20140227102627');

INSERT INTO schema_migrations (version) VALUES ('20140228164206');

INSERT INTO schema_migrations (version) VALUES ('20140228164428');

INSERT INTO schema_migrations (version) VALUES ('20140228165024');

INSERT INTO schema_migrations (version) VALUES ('20140301074143');

INSERT INTO schema_migrations (version) VALUES ('20140303131213');

INSERT INTO schema_migrations (version) VALUES ('20140304135448');

INSERT INTO schema_migrations (version) VALUES ('20140306083247');

INSERT INTO schema_migrations (version) VALUES ('20140312145533');

INSERT INTO schema_migrations (version) VALUES ('20140312150455');

INSERT INTO schema_migrations (version) VALUES ('20140314132659');

INSERT INTO schema_migrations (version) VALUES ('20140318131351');

INSERT INTO schema_migrations (version) VALUES ('20140319182117');

INSERT INTO schema_migrations (version) VALUES ('20140324073247');

INSERT INTO schema_migrations (version) VALUES ('20140328124957');

INSERT INTO schema_migrations (version) VALUES ('20140328133415');

INSERT INTO schema_migrations (version) VALUES ('20140402070713');

INSERT INTO schema_migrations (version) VALUES ('20140402070714');

INSERT INTO schema_migrations (version) VALUES ('20140411121926');

INSERT INTO schema_migrations (version) VALUES ('20140415092507');

INSERT INTO schema_migrations (version) VALUES ('20140415093234');

INSERT INTO schema_migrations (version) VALUES ('20140417084647');

INSERT INTO schema_migrations (version) VALUES ('20140417085905');

INSERT INTO schema_migrations (version) VALUES ('20140417162548');

INSERT INTO schema_migrations (version) VALUES ('20140417235732');

INSERT INTO schema_migrations (version) VALUES ('20140422120515');

INSERT INTO schema_migrations (version) VALUES ('20140425080207');

INSERT INTO schema_migrations (version) VALUES ('20140425080603');

INSERT INTO schema_migrations (version) VALUES ('20140425080731');

INSERT INTO schema_migrations (version) VALUES ('20140425081001');

INSERT INTO schema_migrations (version) VALUES ('20140425111235');

INSERT INTO schema_migrations (version) VALUES ('20140428132517');

INSERT INTO schema_migrations (version) VALUES ('20140428134415');

INSERT INTO schema_migrations (version) VALUES ('20140507104933');

INSERT INTO schema_migrations (version) VALUES ('20140507105154');

INSERT INTO schema_migrations (version) VALUES ('20140509115747');

INSERT INTO schema_migrations (version) VALUES ('20140512062911');

INSERT INTO schema_migrations (version) VALUES ('20140516095154');

INSERT INTO schema_migrations (version) VALUES ('20140519102507');

INSERT INTO schema_migrations (version) VALUES ('20140519123344');

INSERT INTO schema_migrations (version) VALUES ('20140519132638');

INSERT INTO schema_migrations (version) VALUES ('20140519164823');

INSERT INTO schema_migrations (version) VALUES ('20140523082452');

INSERT INTO schema_migrations (version) VALUES ('20140526064017');

INSERT INTO schema_migrations (version) VALUES ('20140530105841');

INSERT INTO schema_migrations (version) VALUES ('20140530115044');

INSERT INTO schema_migrations (version) VALUES ('20140530115433');

INSERT INTO schema_migrations (version) VALUES ('20140604075725');

INSERT INTO schema_migrations (version) VALUES ('20140604135743');

INSERT INTO schema_migrations (version) VALUES ('20140610115132');

INSERT INTO schema_migrations (version) VALUES ('20140610115217');

INSERT INTO schema_migrations (version) VALUES ('20140611094552');

INSERT INTO schema_migrations (version) VALUES ('20140611094703');

INSERT INTO schema_migrations (version) VALUES ('20140612084036');

INSERT INTO schema_migrations (version) VALUES ('20140613132734');

INSERT INTO schema_migrations (version) VALUES ('20140623112935');

INSERT INTO schema_migrations (version) VALUES ('20140701081453');

INSERT INTO schema_migrations (version) VALUES ('20140701135724');

INSERT INTO schema_migrations (version) VALUES ('20140701140655');

INSERT INTO schema_migrations (version) VALUES ('20140703074142');

INSERT INTO schema_migrations (version) VALUES ('20140703075424');

INSERT INTO schema_migrations (version) VALUES ('20140710125950');

INSERT INTO schema_migrations (version) VALUES ('20140710131146');

INSERT INTO schema_migrations (version) VALUES ('20140711094414');

INSERT INTO schema_migrations (version) VALUES ('20140724084559');

INSERT INTO schema_migrations (version) VALUES ('20140724093459');

INSERT INTO schema_migrations (version) VALUES ('20140724123125');

INSERT INTO schema_migrations (version) VALUES ('20140805102757');

INSERT INTO schema_migrations (version) VALUES ('20140811133602');

INSERT INTO schema_migrations (version) VALUES ('20140811133603');

INSERT INTO schema_migrations (version) VALUES ('20140811133605');

INSERT INTO schema_migrations (version) VALUES ('20140811133606');

INSERT INTO schema_migrations (version) VALUES ('20140811144528');

INSERT INTO schema_migrations (version) VALUES ('20140812065415');

INSERT INTO schema_migrations (version) VALUES ('20140815055023');

INSERT INTO schema_migrations (version) VALUES ('20140815085018');

INSERT INTO schema_migrations (version) VALUES ('20140819054528');

INSERT INTO schema_migrations (version) VALUES ('20140819134039');

INSERT INTO schema_migrations (version) VALUES ('20140819134055');

INSERT INTO schema_migrations (version) VALUES ('20140820132249');

INSERT INTO schema_migrations (version) VALUES ('20140829075839');

INSERT INTO schema_migrations (version) VALUES ('20140829113807');

INSERT INTO schema_migrations (version) VALUES ('20140901082541');

INSERT INTO schema_migrations (version) VALUES ('20140901130206');

INSERT INTO schema_migrations (version) VALUES ('20140902095905');

INSERT INTO schema_migrations (version) VALUES ('20140903111344');

INSERT INTO schema_migrations (version) VALUES ('20140903112203');

INSERT INTO schema_migrations (version) VALUES ('20140903120109');

INSERT INTO schema_migrations (version) VALUES ('20140909074331');

INSERT INTO schema_migrations (version) VALUES ('20140912084032');

INSERT INTO schema_migrations (version) VALUES ('20140912115758');

INSERT INTO schema_migrations (version) VALUES ('20140925093828');

INSERT INTO schema_migrations (version) VALUES ('20140925095608');

INSERT INTO schema_migrations (version) VALUES ('20140925111706');

INSERT INTO schema_migrations (version) VALUES ('20140925112419');

INSERT INTO schema_migrations (version) VALUES ('20140929090537');

INSERT INTO schema_migrations (version) VALUES ('20140929064120');

INSERT INTO schema_migrations (version) VALUES ('20140929064130');

INSERT INTO schema_migrations (version) VALUES ('20140929064140');

INSERT INTO schema_migrations (version) VALUES ('20140929064150');

INSERT INTO schema_migrations (version) VALUES ('20140929064160');

INSERT INTO schema_migrations (version) VALUES ('20140929064170');

INSERT INTO schema_migrations (version) VALUES ('20140929064180');

INSERT INTO schema_migrations (version) VALUES ('20140929064185');

INSERT INTO schema_migrations (version) VALUES ('20140929064190');

INSERT INTO schema_migrations (version) VALUES ('20140929064200');

INSERT INTO schema_migrations (version) VALUES ('20140930074731');
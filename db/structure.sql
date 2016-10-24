-- MySQL dump 10.13  Distrib 5.6.32, for osx10.10 (x86_64)
--
-- Host: 127.0.0.1    Database: sharetribe_development
-- ------------------------------------------------------
-- Server version	5.7.15-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `auth_tokens`
--

DROP TABLE IF EXISTS `auth_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `token` varchar(255) DEFAULT NULL,
  `token_type` varchar(255) DEFAULT 'unsubscribe',
  `person_id` varchar(255) DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `usages_left` int(11) DEFAULT NULL,
  `last_use_attempt` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_auth_tokens_on_token` (`token`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `billing_agreements`
--

DROP TABLE IF EXISTS `billing_agreements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `billing_agreements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `paypal_account_id` int(11) NOT NULL,
  `billing_agreement_id` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `paypal_username_to` varchar(255) NOT NULL,
  `request_token` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_billing_agreements_on_paypal_account_id` (`paypal_account_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bookings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_id` int(11) DEFAULT NULL,
  `start_on` date DEFAULT NULL,
  `end_on` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_bookings_on_transaction_id` (`transaction_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `community_id` int(11) DEFAULT NULL,
  `sort_priority` int(11) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_categories_on_community_id` (`community_id`) USING BTREE,
  KEY `index_categories_on_parent_id` (`parent_id`) USING BTREE,
  KEY `index_categories_on_url` (`url`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `category_custom_fields`
--

DROP TABLE IF EXISTS `category_custom_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category_custom_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) DEFAULT NULL,
  `custom_field_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_category_custom_fields_on_category_id_and_custom_field_id` (`category_id`,`custom_field_id`) USING BTREE,
  KEY `index_category_custom_fields_on_custom_field_id` (`custom_field_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `category_listing_shapes`
--

DROP TABLE IF EXISTS `category_listing_shapes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category_listing_shapes` (
  `category_id` int(11) NOT NULL,
  `listing_shape_id` int(11) NOT NULL,
  UNIQUE KEY `unique_listing_shape_category_joins` (`listing_shape_id`,`category_id`) USING BTREE,
  KEY `index_category_listing_shapes_on_category_id` (`category_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `category_translations`
--

DROP TABLE IF EXISTS `category_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `category_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category_id` int(11) DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `category_id_with_locale` (`category_id`,`locale`) USING BTREE,
  KEY `index_category_translations_on_category_id` (`category_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `checkout_accounts`
--

DROP TABLE IF EXISTS `checkout_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `checkout_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id_or_personal_id` varchar(255) DEFAULT NULL,
  `merchant_id` varchar(255) NOT NULL,
  `merchant_key` varchar(255) NOT NULL,
  `person_id` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author_id` varchar(255) DEFAULT NULL,
  `listing_id` int(11) DEFAULT NULL,
  `content` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_comments_on_listing_id` (`listing_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `communities`
--

DROP TABLE IF EXISTS `communities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `communities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` binary(16) NOT NULL,
  `ident` varchar(255) DEFAULT NULL,
  `domain` varchar(255) DEFAULT NULL,
  `use_domain` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `settings` text,
  `consent` varchar(255) DEFAULT NULL,
  `transaction_agreement_in_use` tinyint(1) DEFAULT '0',
  `email_admins_about_new_members` tinyint(1) DEFAULT '0',
  `use_fb_like` tinyint(1) DEFAULT '0',
  `real_name_required` tinyint(1) DEFAULT '1',
  `automatic_newsletters` tinyint(1) DEFAULT '1',
  `join_with_invite_only` tinyint(1) DEFAULT '0',
  `allowed_emails` mediumtext,
  `users_can_invite_new_users` tinyint(1) DEFAULT '1',
  `private` tinyint(1) DEFAULT '0',
  `label` varchar(255) DEFAULT NULL,
  `show_date_in_listings_list` tinyint(1) DEFAULT '0',
  `all_users_can_add_news` tinyint(1) DEFAULT '1',
  `custom_frontpage_sidebar` tinyint(1) DEFAULT '0',
  `event_feed_enabled` tinyint(1) DEFAULT '1',
  `slogan` varchar(255) DEFAULT NULL,
  `description` text,
  `country` varchar(255) DEFAULT NULL,
  `members_count` int(11) DEFAULT '0',
  `user_limit` int(11) DEFAULT NULL,
  `monthly_price_in_euros` float DEFAULT NULL,
  `logo_file_name` varchar(255) DEFAULT NULL,
  `logo_content_type` varchar(255) DEFAULT NULL,
  `logo_file_size` int(11) DEFAULT NULL,
  `logo_updated_at` datetime DEFAULT NULL,
  `cover_photo_file_name` varchar(255) DEFAULT NULL,
  `cover_photo_content_type` varchar(255) DEFAULT NULL,
  `cover_photo_file_size` int(11) DEFAULT NULL,
  `cover_photo_updated_at` datetime DEFAULT NULL,
  `small_cover_photo_file_name` varchar(255) DEFAULT NULL,
  `small_cover_photo_content_type` varchar(255) DEFAULT NULL,
  `small_cover_photo_file_size` int(11) DEFAULT NULL,
  `small_cover_photo_updated_at` datetime DEFAULT NULL,
  `custom_color1` varchar(255) DEFAULT NULL,
  `custom_color2` varchar(255) DEFAULT NULL,
  `stylesheet_url` varchar(255) DEFAULT NULL,
  `stylesheet_needs_recompile` tinyint(1) DEFAULT '0',
  `service_logo_style` varchar(255) DEFAULT 'full-logo',
  `available_currencies` text,
  `facebook_connect_enabled` tinyint(1) DEFAULT '1',
  `minimum_price_cents` int(11) DEFAULT NULL,
  `hide_expiration_date` tinyint(1) DEFAULT '0',
  `facebook_connect_id` varchar(255) DEFAULT NULL,
  `facebook_connect_secret` varchar(255) DEFAULT NULL,
  `google_analytics_key` varchar(255) DEFAULT NULL,
  `google_maps_key` varchar(64) DEFAULT NULL,
  `name_display_type` varchar(255) DEFAULT 'first_name_with_initial',
  `twitter_handle` varchar(255) DEFAULT NULL,
  `use_community_location_as_default` tinyint(1) DEFAULT '0',
  `preproduction_stylesheet_url` varchar(255) DEFAULT NULL,
  `show_category_in_listing_list` tinyint(1) DEFAULT '0',
  `default_browse_view` varchar(255) DEFAULT 'grid',
  `wide_logo_file_name` varchar(255) DEFAULT NULL,
  `wide_logo_content_type` varchar(255) DEFAULT NULL,
  `wide_logo_file_size` int(11) DEFAULT NULL,
  `wide_logo_updated_at` datetime DEFAULT NULL,
  `listing_comments_in_use` tinyint(1) DEFAULT '0',
  `show_listing_publishing_date` tinyint(1) DEFAULT '0',
  `require_verification_to_post_listings` tinyint(1) DEFAULT '0',
  `show_price_filter` tinyint(1) DEFAULT '0',
  `price_filter_min` int(11) DEFAULT '0',
  `price_filter_max` int(11) DEFAULT '100000',
  `automatic_confirmation_after_days` int(11) DEFAULT '14',
  `favicon_file_name` varchar(255) DEFAULT NULL,
  `favicon_content_type` varchar(255) DEFAULT NULL,
  `favicon_file_size` int(11) DEFAULT NULL,
  `favicon_updated_at` datetime DEFAULT NULL,
  `default_min_days_between_community_updates` int(11) DEFAULT '7',
  `listing_location_required` tinyint(1) DEFAULT '0',
  `custom_head_script` text,
  `follow_in_use` tinyint(1) NOT NULL DEFAULT '1',
  `logo_processing` tinyint(1) DEFAULT NULL,
  `wide_logo_processing` tinyint(1) DEFAULT NULL,
  `cover_photo_processing` tinyint(1) DEFAULT NULL,
  `small_cover_photo_processing` tinyint(1) DEFAULT NULL,
  `favicon_processing` tinyint(1) DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_communities_on_uuid` (`uuid`),
  KEY `index_communities_on_domain` (`domain`) USING BTREE,
  KEY `index_communities_on_ident` (`ident`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `community_customizations`
--

DROP TABLE IF EXISTS `community_customizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `community_customizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `slogan` varchar(255) DEFAULT NULL,
  `description` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `blank_slate` text,
  `welcome_email_content` text,
  `how_to_use_page_content` mediumtext,
  `about_page_content` mediumtext,
  `terms_page_content` mediumtext,
  `privacy_page_content` mediumtext,
  `storefront_label` varchar(255) DEFAULT NULL,
  `signup_info_content` text,
  `private_community_homepage_content` mediumtext,
  `verification_to_post_listings_info_content` mediumtext,
  `search_placeholder` varchar(255) DEFAULT NULL,
  `transaction_agreement_label` varchar(255) DEFAULT NULL,
  `transaction_agreement_content` mediumtext,
  PRIMARY KEY (`id`),
  KEY `index_community_customizations_on_community_id` (`community_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `community_memberships`
--

DROP TABLE IF EXISTS `community_memberships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `community_memberships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` varchar(255) NOT NULL,
  `community_id` int(11) NOT NULL,
  `admin` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `consent` varchar(255) DEFAULT NULL,
  `invitation_id` int(11) DEFAULT NULL,
  `last_page_load_date` datetime DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'accepted',
  `can_post_listings` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_community_memberships_on_person_id` (`person_id`) USING BTREE,
  KEY `index_community_memberships_on_community_id` (`community_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `community_translations`
--

DROP TABLE IF EXISTS `community_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `community_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) NOT NULL,
  `locale` varchar(16) NOT NULL,
  `translation_key` varchar(255) NOT NULL,
  `translation` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_community_translations_on_community_id` (`community_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contact_requests`
--

DROP TABLE IF EXISTS `contact_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `plan_type` varchar(255) DEFAULT NULL,
  `marketplace_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `conversations`
--

DROP TABLE IF EXISTS `conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `conversations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `listing_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_message_at` datetime DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_conversations_on_community_id` (`community_id`) USING BTREE,
  KEY `index_conversations_on_last_message_at` (`last_message_at`) USING BTREE,
  KEY `index_conversations_on_listing_id` (`listing_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `custom_field_names`
--

DROP TABLE IF EXISTS `custom_field_names`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_field_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` varchar(255) DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  `custom_field_id` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `locale_index` (`custom_field_id`,`locale`) USING BTREE,
  KEY `index_custom_field_names_on_custom_field_id` (`custom_field_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `custom_field_option_selections`
--

DROP TABLE IF EXISTS `custom_field_option_selections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_field_option_selections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `custom_field_value_id` int(11) DEFAULT NULL,
  `custom_field_option_id` int(11) DEFAULT NULL,
  `listing_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_custom_field_option_selections_on_custom_field_option_id` (`custom_field_option_id`) USING BTREE,
  KEY `index_selected_options_on_custom_field_value_id` (`custom_field_value_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `custom_field_option_titles`
--

DROP TABLE IF EXISTS `custom_field_option_titles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_field_option_titles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `value` varchar(255) DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  `custom_field_option_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `locale_index` (`custom_field_option_id`,`locale`) USING BTREE,
  KEY `index_custom_field_option_titles_on_custom_field_option_id` (`custom_field_option_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `custom_field_options`
--

DROP TABLE IF EXISTS `custom_field_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_field_options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `custom_field_id` int(11) DEFAULT NULL,
  `sort_priority` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_custom_field_options_on_custom_field_id` (`custom_field_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `custom_field_values`
--

DROP TABLE IF EXISTS `custom_field_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_field_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `custom_field_id` int(11) DEFAULT NULL,
  `listing_id` int(11) DEFAULT NULL,
  `text_value` text,
  `numeric_value` float DEFAULT NULL,
  `date_value` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `type` varchar(255) DEFAULT NULL,
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_custom_field_values_on_listing_id` (`listing_id`) USING BTREE,
  KEY `index_custom_field_values_on_type` (`type`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `custom_fields`
--

DROP TABLE IF EXISTS `custom_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL,
  `sort_priority` int(11) DEFAULT NULL,
  `search_filter` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `community_id` int(11) DEFAULT NULL,
  `required` tinyint(1) DEFAULT '1',
  `min` float DEFAULT NULL,
  `max` float DEFAULT NULL,
  `allow_decimals` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_custom_fields_on_community_id` (`community_id`) USING BTREE,
  KEY `index_custom_fields_on_search_filter` (`search_filter`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delayed_jobs`
--

DROP TABLE IF EXISTS `delayed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delayed_jobs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `priority` int(11) DEFAULT '0',
  `attempts` int(11) DEFAULT '0',
  `handler` text,
  `last_error` text,
  `run_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `failed_at` datetime DEFAULT NULL,
  `locked_by` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `queue` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_delayed_jobs_on_attempts_and_run_at_and_priority` (`attempts`,`run_at`,`priority`) USING BTREE,
  KEY `index_delayed_jobs_on_locked_created` (`locked_at`,`created_at`) USING BTREE,
  KEY `delayed_jobs_priority` (`priority`,`run_at`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `emails`
--

DROP TABLE IF EXISTS `emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` varchar(255) DEFAULT NULL,
  `community_id` int(11) NOT NULL,
  `address` varchar(255) NOT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `confirmation_token` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `send_notifications` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_emails_on_address_and_community_id` (`address`,`community_id`) USING BTREE,
  KEY `index_emails_on_person_id` (`person_id`) USING BTREE,
  KEY `index_emails_on_address` (`address`) USING BTREE,
  KEY `index_emails_on_community_id` (`community_id`) USING BTREE,
  KEY `index_emails_on_confirmation_token` (`confirmation_token`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `feature_flags`
--

DROP TABLE IF EXISTS `feature_flags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feature_flags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) NOT NULL,
  `person_id` varchar(255) DEFAULT NULL,
  `feature` varchar(255) NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_feature_flags_on_community_id_and_person_id` (`community_id`,`person_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `feedbacks`
--

DROP TABLE IF EXISTS `feedbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feedbacks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` text,
  `author_id` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_handled` int(11) DEFAULT '0',
  `email` varchar(255) DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `follower_relationships`
--

DROP TABLE IF EXISTS `follower_relationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `follower_relationships` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` varchar(255) NOT NULL,
  `follower_id` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_follower_relationships_on_person_id_and_follower_id` (`person_id`,`follower_id`) USING BTREE,
  KEY `index_follower_relationships_on_follower_id` (`follower_id`) USING BTREE,
  KEY `index_follower_relationships_on_person_id` (`person_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invitations`
--

DROP TABLE IF EXISTS `invitations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invitations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  `usages_left` int(11) DEFAULT NULL,
  `valid_until` datetime DEFAULT NULL,
  `information` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `inviter_id` varchar(255) DEFAULT NULL,
  `message` text,
  `email` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_invitations_on_code` (`code`) USING BTREE,
  KEY `index_invitations_on_inviter_id` (`inviter_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `landing_page_versions`
--

DROP TABLE IF EXISTS `landing_page_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `landing_page_versions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) NOT NULL,
  `version` int(11) NOT NULL,
  `released` datetime DEFAULT NULL,
  `content` mediumtext NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_landing_page_versions_on_community_id_and_version` (`community_id`,`version`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `landing_pages`
--

DROP TABLE IF EXISTS `landing_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `landing_pages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) NOT NULL,
  `enabled` tinyint(1) NOT NULL DEFAULT '0',
  `released_version` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_landing_pages_on_community_id` (`community_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `listing_followers`
--

DROP TABLE IF EXISTS `listing_followers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `listing_followers` (
  `person_id` varchar(255) DEFAULT NULL,
  `listing_id` int(11) DEFAULT NULL,
  KEY `index_listing_followers_on_listing_id` (`listing_id`) USING BTREE,
  KEY `index_listing_followers_on_person_id` (`person_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `listing_images`
--

DROP TABLE IF EXISTS `listing_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `listing_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `listing_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `image_file_name` varchar(255) DEFAULT NULL,
  `image_content_type` varchar(255) DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  `image_processing` tinyint(1) DEFAULT NULL,
  `image_downloaded` tinyint(1) DEFAULT '0',
  `error` varchar(255) DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `author_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_listing_images_on_listing_id` (`listing_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `listing_shapes`
--

DROP TABLE IF EXISTS `listing_shapes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `listing_shapes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) NOT NULL,
  `transaction_process_id` int(11) NOT NULL,
  `price_enabled` tinyint(1) NOT NULL,
  `shipping_enabled` tinyint(1) NOT NULL,
  `availability` varchar(32) DEFAULT 'none',
  `name` varchar(255) NOT NULL,
  `name_tr_key` varchar(255) NOT NULL,
  `action_button_tr_key` varchar(255) NOT NULL,
  `sort_priority` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deleted` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `multicol_index` (`community_id`,`deleted`,`sort_priority`) USING BTREE,
  KEY `index_listing_shapes_on_community_id` (`community_id`) USING BTREE,
  KEY `index_listing_shapes_on_name` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `listing_units`
--

DROP TABLE IF EXISTS `listing_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `listing_units` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unit_type` varchar(32) NOT NULL,
  `quantity_selector` varchar(32) NOT NULL,
  `kind` varchar(32) NOT NULL,
  `name_tr_key` varchar(64) DEFAULT NULL,
  `selector_tr_key` varchar(64) DEFAULT NULL,
  `listing_shape_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_listing_units_on_listing_shape_id` (`listing_shape_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `listings`
--

DROP TABLE IF EXISTS `listings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `listings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uuid` binary(16) NOT NULL,
  `community_id` int(11) NOT NULL,
  `author_id` varchar(255) DEFAULT NULL,
  `category_old` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `times_viewed` int(11) DEFAULT '0',
  `language` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updates_email_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_modified` datetime DEFAULT NULL,
  `sort_date` datetime DEFAULT NULL,
  `listing_type_old` varchar(255) DEFAULT NULL,
  `description` text,
  `origin` varchar(255) DEFAULT NULL,
  `destination` varchar(255) DEFAULT NULL,
  `valid_until` datetime DEFAULT NULL,
  `delta` tinyint(1) NOT NULL DEFAULT '1',
  `open` tinyint(1) DEFAULT '1',
  `share_type_old` varchar(255) DEFAULT NULL,
  `privacy` varchar(255) DEFAULT 'private',
  `comments_count` int(11) DEFAULT '0',
  `subcategory_old` varchar(255) DEFAULT NULL,
  `old_category_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `share_type_id` int(11) DEFAULT NULL,
  `listing_shape_id` int(11) DEFAULT NULL,
  `transaction_process_id` int(11) DEFAULT NULL,
  `shape_name_tr_key` varchar(255) DEFAULT NULL,
  `action_button_tr_key` varchar(255) DEFAULT NULL,
  `price_cents` int(11) DEFAULT NULL,
  `currency` varchar(255) DEFAULT NULL,
  `quantity` varchar(255) DEFAULT NULL,
  `unit_type` varchar(32) DEFAULT NULL,
  `quantity_selector` varchar(32) DEFAULT NULL,
  `unit_tr_key` varchar(64) DEFAULT NULL,
  `unit_selector_tr_key` varchar(64) DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT '0',
  `require_shipping_address` tinyint(1) DEFAULT '0',
  `pickup_enabled` tinyint(1) DEFAULT '0',
  `shipping_price_cents` int(11) DEFAULT NULL,
  `shipping_price_additional_cents` int(11) DEFAULT NULL,
  `availability` varchar(32) DEFAULT 'none',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_listings_on_uuid` (`uuid`),
  KEY `index_listings_on_new_category_id` (`category_id`) USING BTREE,
  KEY `person_listings` (`community_id`,`author_id`) USING BTREE,
  KEY `homepage_query` (`community_id`,`open`,`sort_date`,`deleted`) USING BTREE,
  KEY `updates_email_listings` (`community_id`,`open`,`updates_email_at`) USING BTREE,
  KEY `homepage_query_valid_until` (`community_id`,`open`,`valid_until`,`sort_date`,`deleted`) USING BTREE,
  KEY `index_listings_on_community_id` (`community_id`) USING BTREE,
  KEY `index_listings_on_listing_shape_id` (`listing_shape_id`) USING BTREE,
  KEY `index_listings_on_category_id` (`old_category_id`) USING BTREE,
  KEY `index_listings_on_open` (`open`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `google_address` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `listing_id` int(11) DEFAULT NULL,
  `person_id` varchar(255) DEFAULT NULL,
  `location_type` varchar(255) DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_locations_on_community_id` (`community_id`) USING BTREE,
  KEY `index_locations_on_listing_id` (`listing_id`) USING BTREE,
  KEY `index_locations_on_person_id` (`person_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marketplace_configurations`
--

DROP TABLE IF EXISTS `marketplace_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marketplace_configurations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) NOT NULL,
  `main_search` varchar(255) NOT NULL DEFAULT 'keyword',
  `distance_unit` varchar(255) NOT NULL DEFAULT 'metric',
  `limit_priority_links` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `limit_search_distance` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_marketplace_configurations_on_community_id` (`community_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marketplace_plans`
--

DROP TABLE IF EXISTS `marketplace_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marketplace_plans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) NOT NULL,
  `status` varchar(22) DEFAULT NULL,
  `features` text,
  `member_limit` int(11) DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_marketplace_plans_on_community_id` (`community_id`) USING BTREE,
  KEY `index_marketplace_plans_on_created_at` (`created_at`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marketplace_sender_emails`
--

DROP TABLE IF EXISTS `marketplace_sender_emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marketplace_sender_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `verification_status` varchar(32) NOT NULL,
  `verification_requested_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_marketplace_sender_emails_on_community_id` (`community_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marketplace_setup_steps`
--

DROP TABLE IF EXISTS `marketplace_setup_steps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marketplace_setup_steps` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) NOT NULL,
  `slogan_and_description` tinyint(1) NOT NULL DEFAULT '0',
  `cover_photo` tinyint(1) NOT NULL DEFAULT '0',
  `filter` tinyint(1) NOT NULL DEFAULT '0',
  `paypal` tinyint(1) NOT NULL DEFAULT '0',
  `listing` tinyint(1) NOT NULL DEFAULT '0',
  `invitation` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_marketplace_setup_steps_on_community_id` (`community_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `marketplace_trials`
--

DROP TABLE IF EXISTS `marketplace_trials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `marketplace_trials` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) NOT NULL,
  `expires_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_marketplace_trials_on_community_id` (`community_id`) USING BTREE,
  KEY `index_marketplace_trials_on_created_at` (`created_at`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `menu_link_translations`
--

DROP TABLE IF EXISTS `menu_link_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menu_link_translations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `menu_link_id` int(11) DEFAULT NULL,
  `locale` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_menu_link_translations_on_menu_link_id` (`menu_link_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `menu_links`
--

DROP TABLE IF EXISTS `menu_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menu_links` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `sort_priority` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_menu_links_on_community_and_sort` (`community_id`,`sort_priority`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mercury_images`
--

DROP TABLE IF EXISTS `mercury_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mercury_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `image_file_name` varchar(255) DEFAULT NULL,
  `image_content_type` varchar(255) DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` varchar(255) DEFAULT NULL,
  `content` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `conversation_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_messages_on_conversation_id` (`conversation_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_permissions`
--

DROP TABLE IF EXISTS `order_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `paypal_account_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `request_token` varchar(255) DEFAULT NULL,
  `paypal_username_to` varchar(255) NOT NULL,
  `scope` varchar(255) DEFAULT NULL,
  `verification_code` varchar(255) DEFAULT NULL,
  `onboarding_id` varchar(36) DEFAULT NULL,
  `permissions_granted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_order_permissions_on_paypal_account_id` (`paypal_account_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `participations`
--

DROP TABLE IF EXISTS `participations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `participations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` varchar(255) DEFAULT NULL,
  `conversation_id` int(11) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `is_starter` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_sent_at` datetime DEFAULT NULL,
  `last_received_at` datetime DEFAULT NULL,
  `feedback_skipped` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_participations_on_conversation_id` (`conversation_id`) USING BTREE,
  KEY `index_participations_on_person_id` (`person_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_settings`
--

DROP TABLE IF EXISTS `payment_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `active` tinyint(1) NOT NULL,
  `community_id` int(11) NOT NULL,
  `payment_gateway` varchar(64) DEFAULT NULL,
  `payment_process` varchar(64) DEFAULT NULL,
  `commission_from_seller` int(11) DEFAULT NULL,
  `minimum_price_cents` int(11) DEFAULT NULL,
  `minimum_transaction_fee_cents` int(11) DEFAULT NULL,
  `confirmation_after_days` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_payment_settings_on_community_id` (`community_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `paypal_accounts`
--

DROP TABLE IF EXISTS `paypal_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paypal_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` varchar(255) DEFAULT NULL,
  `community_id` int(11) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `payer_id` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `active` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_paypal_accounts_on_community_id` (`community_id`) USING BTREE,
  KEY `index_paypal_accounts_on_payer_id` (`payer_id`) USING BTREE,
  KEY `index_paypal_accounts_on_person_id` (`person_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `paypal_ipn_messages`
--

DROP TABLE IF EXISTS `paypal_ipn_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paypal_ipn_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `body` text,
  `status` varchar(64) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `paypal_payments`
--

DROP TABLE IF EXISTS `paypal_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paypal_payments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) NOT NULL,
  `transaction_id` int(11) NOT NULL,
  `payer_id` varchar(64) NOT NULL,
  `receiver_id` varchar(64) NOT NULL,
  `merchant_id` varchar(255) NOT NULL,
  `order_id` varchar(64) DEFAULT NULL,
  `order_date` datetime DEFAULT NULL,
  `currency` varchar(8) NOT NULL,
  `order_total_cents` int(11) DEFAULT NULL,
  `authorization_id` varchar(64) DEFAULT NULL,
  `authorization_date` datetime DEFAULT NULL,
  `authorization_expires_date` datetime DEFAULT NULL,
  `authorization_total_cents` int(11) DEFAULT NULL,
  `payment_id` varchar(64) DEFAULT NULL,
  `payment_date` datetime DEFAULT NULL,
  `payment_total_cents` int(11) DEFAULT NULL,
  `fee_total_cents` int(11) DEFAULT NULL,
  `payment_status` varchar(64) NOT NULL,
  `pending_reason` varchar(64) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `commission_payment_id` varchar(64) DEFAULT NULL,
  `commission_payment_date` datetime DEFAULT NULL,
  `commission_status` varchar(64) NOT NULL DEFAULT 'not_charged',
  `commission_pending_reason` varchar(64) DEFAULT NULL,
  `commission_total_cents` int(11) DEFAULT NULL,
  `commission_fee_total_cents` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_paypal_payments_on_transaction_id` (`transaction_id`) USING BTREE,
  UNIQUE KEY `index_paypal_payments_on_authorization_id` (`authorization_id`) USING BTREE,
  UNIQUE KEY `index_paypal_payments_on_order_id` (`order_id`) USING BTREE,
  KEY `index_paypal_payments_on_community_id` (`community_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `paypal_process_tokens`
--

DROP TABLE IF EXISTS `paypal_process_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paypal_process_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `process_token` varchar(64) NOT NULL,
  `community_id` int(11) NOT NULL,
  `transaction_id` int(11) NOT NULL,
  `op_completed` tinyint(1) NOT NULL DEFAULT '0',
  `op_name` varchar(64) NOT NULL,
  `op_input` text,
  `op_output` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_paypal_process_tokens_on_process_token` (`process_token`) USING BTREE,
  UNIQUE KEY `index_paypal_process_tokens_on_transaction` (`transaction_id`,`community_id`,`op_name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `paypal_refunds`
--

DROP TABLE IF EXISTS `paypal_refunds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paypal_refunds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `paypal_payment_id` int(11) DEFAULT NULL,
  `currency` varchar(8) DEFAULT NULL,
  `payment_total_cents` int(11) DEFAULT NULL,
  `fee_total_cents` int(11) DEFAULT NULL,
  `refunding_id` varchar(64) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_paypal_refunds_on_refunding_id` (`refunding_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `paypal_tokens`
--

DROP TABLE IF EXISTS `paypal_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `paypal_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) NOT NULL,
  `token` varchar(64) DEFAULT NULL,
  `transaction_id` int(11) DEFAULT NULL,
  `payment_action` varchar(32) DEFAULT NULL,
  `merchant_id` varchar(255) NOT NULL,
  `receiver_id` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `item_name` varchar(255) DEFAULT NULL,
  `item_quantity` int(11) DEFAULT NULL,
  `item_price_cents` int(11) DEFAULT NULL,
  `currency` varchar(8) DEFAULT NULL,
  `express_checkout_url` varchar(255) DEFAULT NULL,
  `shipping_total_cents` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_paypal_tokens_on_token` (`token`) USING BTREE,
  KEY `index_paypal_tokens_on_community_id` (`community_id`) USING BTREE,
  KEY `index_paypal_tokens_on_transaction_id` (`transaction_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `people`
--

DROP TABLE IF EXISTS `people`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `people` (
  `id` varchar(22) NOT NULL,
  `uuid` binary(16) NOT NULL,
  `community_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_admin` int(11) DEFAULT '0',
  `locale` varchar(255) DEFAULT 'fi',
  `preferences` text,
  `active_days_count` int(11) DEFAULT '0',
  `last_page_load_date` datetime DEFAULT NULL,
  `test_group_number` int(11) DEFAULT '1',
  `username` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `encrypted_password` varchar(255) NOT NULL DEFAULT '',
  `legacy_encrypted_password` varchar(255) DEFAULT NULL,
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `password_salt` varchar(255) DEFAULT NULL,
  `given_name` varchar(255) DEFAULT NULL,
  `family_name` varchar(255) DEFAULT NULL,
  `phone_number` varchar(255) DEFAULT NULL,
  `description` text,
  `image_file_name` varchar(255) DEFAULT NULL,
  `image_content_type` varchar(255) DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  `image_processing` tinyint(1) DEFAULT NULL,
  `facebook_id` varchar(255) DEFAULT NULL,
  `authentication_token` varchar(255) DEFAULT NULL,
  `community_updates_last_sent_at` datetime DEFAULT NULL,
  `min_days_between_community_updates` int(11) DEFAULT '1',
  `deleted` tinyint(1) DEFAULT '0',
  `cloned_from` varchar(22) DEFAULT NULL,
  UNIQUE KEY `index_people_on_username_and_community_id` (`username`,`community_id`) USING BTREE,
  UNIQUE KEY `index_people_on_uuid` (`uuid`),
  UNIQUE KEY `index_people_on_email` (`email`) USING BTREE,
  UNIQUE KEY `index_people_on_facebook_id_and_community_id` (`facebook_id`,`community_id`) USING BTREE,
  UNIQUE KEY `index_people_on_reset_password_token` (`reset_password_token`) USING BTREE,
  KEY `index_people_on_authentication_token` (`authentication_token`) USING BTREE,
  KEY `index_people_on_community_id` (`community_id`) USING BTREE,
  KEY `index_people_on_facebook_id` (`facebook_id`) USING BTREE,
  KEY `index_people_on_id` (`id`) USING BTREE,
  KEY `index_people_on_username` (`username`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `prospect_emails`
--

DROP TABLE IF EXISTS `prospect_emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `prospect_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) NOT NULL,
  `data` text,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`) USING BTREE,
  KEY `index_sessions_on_updated_at` (`updated_at`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shipping_addresses`
--

DROP TABLE IF EXISTS `shipping_addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shipping_addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `transaction_id` int(11) NOT NULL,
  `status` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `postal_code` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `state_or_province` varchar(255) DEFAULT NULL,
  `street1` varchar(255) DEFAULT NULL,
  `street2` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `country_code` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_shipping_addresses_on_transaction_id` (`transaction_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `testimonials`
--

DROP TABLE IF EXISTS `testimonials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `testimonials` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `grade` float DEFAULT NULL,
  `text` text,
  `author_id` varchar(255) DEFAULT NULL,
  `participation_id` int(11) DEFAULT NULL,
  `transaction_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `receiver_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_testimonials_on_author_id` (`author_id`) USING BTREE,
  KEY `index_testimonials_on_receiver_id` (`receiver_id`) USING BTREE,
  KEY `index_testimonials_on_transaction_id` (`transaction_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction_process_tokens`
--

DROP TABLE IF EXISTS `transaction_process_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transaction_process_tokens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `process_token` binary(16) DEFAULT NULL,
  `community_id` int(11) NOT NULL,
  `transaction_id` int(11) NOT NULL,
  `op_completed` tinyint(1) NOT NULL DEFAULT '0',
  `op_name` varchar(64) COLLATE utf8_unicode_ci NOT NULL,
  `op_input` text COLLATE utf8_unicode_ci,
  `op_output` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_paypal_process_tokens_on_transaction` (`transaction_id`,`community_id`,`op_name`),
  UNIQUE KEY `index_transaction_process_tokens_on_process_token` (`process_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction_processes`
--

DROP TABLE IF EXISTS `transaction_processes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transaction_processes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_id` int(11) DEFAULT NULL,
  `process` varchar(32) NOT NULL,
  `author_is_seller` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_transaction_process_on_community_id` (`community_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction_transitions`
--

DROP TABLE IF EXISTS `transaction_transitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transaction_transitions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `to_state` varchar(255) DEFAULT NULL,
  `metadata` text,
  `sort_key` int(11) DEFAULT '0',
  `transaction_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_transaction_transitions_on_sort_key_and_conversation_id` (`sort_key`,`transaction_id`) USING BTREE,
  KEY `index_transaction_transitions_on_conversation_id` (`transaction_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `starter_id` varchar(255) NOT NULL,
  `starter_uuid` binary(16) NOT NULL,
  `listing_id` int(11) NOT NULL,
  `listing_uuid` binary(16) NOT NULL,
  `conversation_id` int(11) DEFAULT NULL,
  `automatic_confirmation_after_days` int(11) NOT NULL,
  `community_id` int(11) NOT NULL,
  `community_uuid` binary(16) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `starter_skipped_feedback` tinyint(1) DEFAULT '0',
  `author_skipped_feedback` tinyint(1) DEFAULT '0',
  `last_transition_at` datetime DEFAULT NULL,
  `current_state` varchar(255) DEFAULT NULL,
  `commission_from_seller` int(11) DEFAULT NULL,
  `minimum_commission_cents` int(11) DEFAULT '0',
  `minimum_commission_currency` varchar(255) DEFAULT NULL,
  `payment_gateway` varchar(255) NOT NULL DEFAULT 'none',
  `listing_quantity` int(11) DEFAULT '1',
  `listing_author_id` varchar(255) NOT NULL,
  `listing_author_uuid` binary(16) NOT NULL,
  `listing_title` varchar(255) DEFAULT NULL,
  `unit_type` varchar(32) DEFAULT NULL,
  `unit_price_cents` int(11) DEFAULT NULL,
  `unit_price_currency` varchar(8) DEFAULT NULL,
  `unit_tr_key` varchar(64) DEFAULT NULL,
  `unit_selector_tr_key` varchar(64) DEFAULT NULL,
  `payment_process` varchar(31) DEFAULT 'none',
  `delivery_method` varchar(31) DEFAULT 'none',
  `shipping_price_cents` int(11) DEFAULT NULL,
  `availability` varchar(32) DEFAULT 'none',
  `booking_uuid` binary(16) DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_transactions_on_listing_id` (`listing_id`) USING BTREE,
  KEY `index_transactions_on_conversation_id` (`conversation_id`) USING BTREE,
  KEY `index_transactions_on_community_id` (`community_id`) USING BTREE,
  KEY `index_transactions_on_last_transition_at` (`last_transition_at`) USING BTREE,
  KEY `transactions_on_cid_and_deleted` (`community_id`,`deleted`) USING BTREE,
  KEY `index_transactions_on_deleted` (`deleted`) USING BTREE,
  KEY `index_transactions_on_starter_id` (`starter_id`) USING BTREE,
  KEY `index_transactions_on_listing_author_id` (`listing_author_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-10-19 15:53:24
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

INSERT INTO schema_migrations (version) VALUES ('20140930064120');

INSERT INTO schema_migrations (version) VALUES ('20140930064130');

INSERT INTO schema_migrations (version) VALUES ('20140930064140');

INSERT INTO schema_migrations (version) VALUES ('20140930064150');

INSERT INTO schema_migrations (version) VALUES ('20140930064160');

INSERT INTO schema_migrations (version) VALUES ('20140930064170');

INSERT INTO schema_migrations (version) VALUES ('20140930064180');

INSERT INTO schema_migrations (version) VALUES ('20140930064185');

INSERT INTO schema_migrations (version) VALUES ('20140930064190');

INSERT INTO schema_migrations (version) VALUES ('20140930064200');

INSERT INTO schema_migrations (version) VALUES ('20140930074731');

INSERT INTO schema_migrations (version) VALUES ('20140930083026');

INSERT INTO schema_migrations (version) VALUES ('20141001065955');

INSERT INTO schema_migrations (version) VALUES ('20141001070716');

INSERT INTO schema_migrations (version) VALUES ('20141001113744');

INSERT INTO schema_migrations (version) VALUES ('20141003113756');

INSERT INTO schema_migrations (version) VALUES ('20141006100239');

INSERT INTO schema_migrations (version) VALUES ('20141006114330');

INSERT INTO schema_migrations (version) VALUES ('20141007144442');

INSERT INTO schema_migrations (version) VALUES ('20141009083833');

INSERT INTO schema_migrations (version) VALUES ('20141015062240');

INSERT INTO schema_migrations (version) VALUES ('20141015071419');

INSERT INTO schema_migrations (version) VALUES ('20141015080454');

INSERT INTO schema_migrations (version) VALUES ('20141015135248');

INSERT INTO schema_migrations (version) VALUES ('20141015135601');

INSERT INTO schema_migrations (version) VALUES ('20141015150328');

INSERT INTO schema_migrations (version) VALUES ('20141017080930');

INSERT INTO schema_migrations (version) VALUES ('20141020113323');

INSERT INTO schema_migrations (version) VALUES ('20141020225349');

INSERT INTO schema_migrations (version) VALUES ('20141022084419');

INSERT INTO schema_migrations (version) VALUES ('20141022190428');

INSERT INTO schema_migrations (version) VALUES ('20141023120743');

INSERT INTO schema_migrations (version) VALUES ('20141023141235');

INSERT INTO schema_migrations (version) VALUES ('20141023150700');

INSERT INTO schema_migrations (version) VALUES ('20141028080346');

INSERT INTO schema_migrations (version) VALUES ('20141028104522');

INSERT INTO schema_migrations (version) VALUES ('20141028104537');

INSERT INTO schema_migrations (version) VALUES ('20141029090632');

INSERT INTO schema_migrations (version) VALUES ('20141029121848');

INSERT INTO schema_migrations (version) VALUES ('20141029121945');

INSERT INTO schema_migrations (version) VALUES ('20141030140809');

INSERT INTO schema_migrations (version) VALUES ('20141102192640');

INSERT INTO schema_migrations (version) VALUES ('20141104213501');

INSERT INTO schema_migrations (version) VALUES ('20141111183125');

INSERT INTO schema_migrations (version) VALUES ('20141112131736');

INSERT INTO schema_migrations (version) VALUES ('20141113204444');

INSERT INTO schema_migrations (version) VALUES ('20141117165348');

INSERT INTO schema_migrations (version) VALUES ('20141203095726');

INSERT INTO schema_migrations (version) VALUES ('20141204084648');

INSERT INTO schema_migrations (version) VALUES ('20141205094929');

INSERT INTO schema_migrations (version) VALUES ('20141216132850');

INSERT INTO schema_migrations (version) VALUES ('20141216132851');

INSERT INTO schema_migrations (version) VALUES ('20141217152335');

INSERT INTO schema_migrations (version) VALUES ('20141218082446');

INSERT INTO schema_migrations (version) VALUES ('20141219205556');

INSERT INTO schema_migrations (version) VALUES ('20141222130455');

INSERT INTO schema_migrations (version) VALUES ('20150103143459');

INSERT INTO schema_migrations (version) VALUES ('20150107155205');

INSERT INTO schema_migrations (version) VALUES ('20150116125629');

INSERT INTO schema_migrations (version) VALUES ('20150121124432');

INSERT INTO schema_migrations (version) VALUES ('20150121130521');

INSERT INTO schema_migrations (version) VALUES ('20150128113129');

INSERT INTO schema_migrations (version) VALUES ('20150202112254');

INSERT INTO schema_migrations (version) VALUES ('20150204124735');

INSERT INTO schema_migrations (version) VALUES ('20150204124802');

INSERT INTO schema_migrations (version) VALUES ('20150205155400');

INSERT INTO schema_migrations (version) VALUES ('20150205155519');

INSERT INTO schema_migrations (version) VALUES ('20150206125017');

INSERT INTO schema_migrations (version) VALUES ('20150206151234');

INSERT INTO schema_migrations (version) VALUES ('20150212125111');

INSERT INTO schema_migrations (version) VALUES ('20150213091223');

INSERT INTO schema_migrations (version) VALUES ('20150213092629');

INSERT INTO schema_migrations (version) VALUES ('20150213094110');

INSERT INTO schema_migrations (version) VALUES ('20150224140913');

INSERT INTO schema_migrations (version) VALUES ('20150225081656');

INSERT INTO schema_migrations (version) VALUES ('20150225082144');

INSERT INTO schema_migrations (version) VALUES ('20150225122608');

INSERT INTO schema_migrations (version) VALUES ('20150226124214');

INSERT INTO schema_migrations (version) VALUES ('20150226130928');

INSERT INTO schema_migrations (version) VALUES ('20150226131628');

INSERT INTO schema_migrations (version) VALUES ('20150303134630');

INSERT INTO schema_migrations (version) VALUES ('20150303140556');

INSERT INTO schema_migrations (version) VALUES ('20150304074313');

INSERT INTO schema_migrations (version) VALUES ('20150304084451');

INSERT INTO schema_migrations (version) VALUES ('20150311073502');

INSERT INTO schema_migrations (version) VALUES ('20150311100232');

INSERT INTO schema_migrations (version) VALUES ('20150311111824');

INSERT INTO schema_migrations (version) VALUES ('20150311113118');

INSERT INTO schema_migrations (version) VALUES ('20150316084339');

INSERT INTO schema_migrations (version) VALUES ('20150316135852');

INSERT INTO schema_migrations (version) VALUES ('20150316140016');

INSERT INTO schema_migrations (version) VALUES ('20150316140637');

INSERT INTO schema_migrations (version) VALUES ('20150316151552');

INSERT INTO schema_migrations (version) VALUES ('20150316173800');

INSERT INTO schema_migrations (version) VALUES ('20150317080017');

INSERT INTO schema_migrations (version) VALUES ('20150317122824');

INSERT INTO schema_migrations (version) VALUES ('20150317142931');

INSERT INTO schema_migrations (version) VALUES ('20150319121616');

INSERT INTO schema_migrations (version) VALUES ('20150320091305');

INSERT INTO schema_migrations (version) VALUES ('20150320144657');

INSERT INTO schema_migrations (version) VALUES ('20150323085034');

INSERT INTO schema_migrations (version) VALUES ('20150323152147');

INSERT INTO schema_migrations (version) VALUES ('20150324072928');

INSERT INTO schema_migrations (version) VALUES ('20150324112018');

INSERT INTO schema_migrations (version) VALUES ('20150324112042');

INSERT INTO schema_migrations (version) VALUES ('20150324112053');

INSERT INTO schema_migrations (version) VALUES ('20150324112658');

INSERT INTO schema_migrations (version) VALUES ('20150324114726');

INSERT INTO schema_migrations (version) VALUES ('20150325164209');

INSERT INTO schema_migrations (version) VALUES ('20150327075649');

INSERT INTO schema_migrations (version) VALUES ('20150330072934');

INSERT INTO schema_migrations (version) VALUES ('20150330093441');

INSERT INTO schema_migrations (version) VALUES ('20150330094735');

INSERT INTO schema_migrations (version) VALUES ('20150331103317');

INSERT INTO schema_migrations (version) VALUES ('20150331105616');

INSERT INTO schema_migrations (version) VALUES ('20150331112417');

INSERT INTO schema_migrations (version) VALUES ('20150401071256');

INSERT INTO schema_migrations (version) VALUES ('20150401072129');

INSERT INTO schema_migrations (version) VALUES ('20150401140830');

INSERT INTO schema_migrations (version) VALUES ('20150402090934');

INSERT INTO schema_migrations (version) VALUES ('20150402111115');

INSERT INTO schema_migrations (version) VALUES ('20150403101215');

INSERT INTO schema_migrations (version) VALUES ('20150407123639');

INSERT INTO schema_migrations (version) VALUES ('20150407124816');

INSERT INTO schema_migrations (version) VALUES ('20150407130810');

INSERT INTO schema_migrations (version) VALUES ('20150407131139');

INSERT INTO schema_migrations (version) VALUES ('20150413104519');

INSERT INTO schema_migrations (version) VALUES ('20150413134627');

INSERT INTO schema_migrations (version) VALUES ('20150415092447');

INSERT INTO schema_migrations (version) VALUES ('20150416112541');

INSERT INTO schema_migrations (version) VALUES ('20150416134422');

INSERT INTO schema_migrations (version) VALUES ('20150420072530');

INSERT INTO schema_migrations (version) VALUES ('20150420083201');

INSERT INTO schema_migrations (version) VALUES ('20150426113955');

INSERT INTO schema_migrations (version) VALUES ('20150429155804');

INSERT INTO schema_migrations (version) VALUES ('20150507082447');

INSERT INTO schema_migrations (version) VALUES ('20150507084754');

INSERT INTO schema_migrations (version) VALUES ('20150507165715');

INSERT INTO schema_migrations (version) VALUES ('20150508141500');

INSERT INTO schema_migrations (version) VALUES ('20150512082544');

INSERT INTO schema_migrations (version) VALUES ('20150512083212');

INSERT INTO schema_migrations (version) VALUES ('20150512083411');

INSERT INTO schema_migrations (version) VALUES ('20150512083842');

INSERT INTO schema_migrations (version) VALUES ('20150518120830');

INSERT INTO schema_migrations (version) VALUES ('20150518123758');

INSERT INTO schema_migrations (version) VALUES ('20150519124846');

INSERT INTO schema_migrations (version) VALUES ('20150520104604');

INSERT INTO schema_migrations (version) VALUES ('20150520130243');

INSERT INTO schema_migrations (version) VALUES ('20150520131057');

INSERT INTO schema_migrations (version) VALUES ('20150527091815');

INSERT INTO schema_migrations (version) VALUES ('20150527133928');

INSERT INTO schema_migrations (version) VALUES ('20150528120338');

INSERT INTO schema_migrations (version) VALUES ('20150528120717');

INSERT INTO schema_migrations (version) VALUES ('20150608135024');

INSERT INTO schema_migrations (version) VALUES ('20150608140024');

INSERT INTO schema_migrations (version) VALUES ('20150608144130');

INSERT INTO schema_migrations (version) VALUES ('20150609084012');

INSERT INTO schema_migrations (version) VALUES ('20150612104320');

INSERT INTO schema_migrations (version) VALUES ('20150622080657');

INSERT INTO schema_migrations (version) VALUES ('20150630082932');

INSERT INTO schema_migrations (version) VALUES ('20150630122552');

INSERT INTO schema_migrations (version) VALUES ('20150729062045');

INSERT INTO schema_migrations (version) VALUES ('20150729062215');

INSERT INTO schema_migrations (version) VALUES ('20150731115141');

INSERT INTO schema_migrations (version) VALUES ('20150731115426');

INSERT INTO schema_migrations (version) VALUES ('20150731115742');

INSERT INTO schema_migrations (version) VALUES ('20150804113139');

INSERT INTO schema_migrations (version) VALUES ('20150804114651');

INSERT INTO schema_migrations (version) VALUES ('20150805084232');

INSERT INTO schema_migrations (version) VALUES ('20150806114405');

INSERT INTO schema_migrations (version) VALUES ('20150806114717');

INSERT INTO schema_migrations (version) VALUES ('20150807141947');

INSERT INTO schema_migrations (version) VALUES ('20150821131310');

INSERT INTO schema_migrations (version) VALUES ('20150821131616');

INSERT INTO schema_migrations (version) VALUES ('20150825120916');

INSERT INTO schema_migrations (version) VALUES ('20150825121715');

INSERT INTO schema_migrations (version) VALUES ('20150825122606');

INSERT INTO schema_migrations (version) VALUES ('20150828094836');

INSERT INTO schema_migrations (version) VALUES ('20150902090425');

INSERT INTO schema_migrations (version) VALUES ('20150902103231');

INSERT INTO schema_migrations (version) VALUES ('20151008090106');

INSERT INTO schema_migrations (version) VALUES ('20151008130725');

INSERT INTO schema_migrations (version) VALUES ('20151022180225');

INSERT INTO schema_migrations (version) VALUES ('20151022180242');

INSERT INTO schema_migrations (version) VALUES ('20151022183133');

INSERT INTO schema_migrations (version) VALUES ('20151102084029');

INSERT INTO schema_migrations (version) VALUES ('20151202062609');

INSERT INTO schema_migrations (version) VALUES ('20151204083028');

INSERT INTO schema_migrations (version) VALUES ('20151209102951');

INSERT INTO schema_migrations (version) VALUES ('20151215071150');

INSERT INTO schema_migrations (version) VALUES ('20151230071554');

INSERT INTO schema_migrations (version) VALUES ('20151230095128');

INSERT INTO schema_migrations (version) VALUES ('20151231083524');

INSERT INTO schema_migrations (version) VALUES ('20160119092239');

INSERT INTO schema_migrations (version) VALUES ('20160119092534');

INSERT INTO schema_migrations (version) VALUES ('20160120112839');

INSERT INTO schema_migrations (version) VALUES ('20160126134509');

INSERT INTO schema_migrations (version) VALUES ('20160126141249');

INSERT INTO schema_migrations (version) VALUES ('20160209172619');

INSERT INTO schema_migrations (version) VALUES ('20160209183917');

INSERT INTO schema_migrations (version) VALUES ('20160216084624');

INSERT INTO schema_migrations (version) VALUES ('20160223083004');

INSERT INTO schema_migrations (version) VALUES ('20160223084741');

INSERT INTO schema_migrations (version) VALUES ('20160229114242');

INSERT INTO schema_migrations (version) VALUES ('20160311070106');

INSERT INTO schema_migrations (version) VALUES ('20160322103154');

INSERT INTO schema_migrations (version) VALUES ('20160322103155');

INSERT INTO schema_migrations (version) VALUES ('20160322103156');

INSERT INTO schema_migrations (version) VALUES ('20160407103437');

INSERT INTO schema_migrations (version) VALUES ('20160407132641');

INSERT INTO schema_migrations (version) VALUES ('20160408061218');

INSERT INTO schema_migrations (version) VALUES ('20160408070000');

INSERT INTO schema_migrations (version) VALUES ('20160408070005');

INSERT INTO schema_migrations (version) VALUES ('20160420100304');

INSERT INTO schema_migrations (version) VALUES ('20160420200020');

INSERT INTO schema_migrations (version) VALUES ('20160420200030');

INSERT INTO schema_migrations (version) VALUES ('20160420200040');

INSERT INTO schema_migrations (version) VALUES ('20160420200050');

INSERT INTO schema_migrations (version) VALUES ('20160420200060');

INSERT INTO schema_migrations (version) VALUES ('20160420200065');

INSERT INTO schema_migrations (version) VALUES ('20160420200066');

INSERT INTO schema_migrations (version) VALUES ('20160420200080');

INSERT INTO schema_migrations (version) VALUES ('20160420200090');

INSERT INTO schema_migrations (version) VALUES ('20160420200100');

INSERT INTO schema_migrations (version) VALUES ('20160420200110');

INSERT INTO schema_migrations (version) VALUES ('20160422074608');

INSERT INTO schema_migrations (version) VALUES ('20160422075215');

INSERT INTO schema_migrations (version) VALUES ('20160422094212');

INSERT INTO schema_migrations (version) VALUES ('20160422094431');

INSERT INTO schema_migrations (version) VALUES ('20160422094536');

INSERT INTO schema_migrations (version) VALUES ('20160422114240');

INSERT INTO schema_migrations (version) VALUES ('20160422114747');

INSERT INTO schema_migrations (version) VALUES ('20160422123125');

INSERT INTO schema_migrations (version) VALUES ('20160422123211');

INSERT INTO schema_migrations (version) VALUES ('20160425144703');

INSERT INTO schema_migrations (version) VALUES ('20160427113446');

INSERT INTO schema_migrations (version) VALUES ('20160509111922');

INSERT INTO schema_migrations (version) VALUES ('20160511130006');

INSERT INTO schema_migrations (version) VALUES ('20160518060235');

INSERT INTO schema_migrations (version) VALUES ('20160608130531');

INSERT INTO schema_migrations (version) VALUES ('20160609070256');

INSERT INTO schema_migrations (version) VALUES ('20160609080700');

INSERT INTO schema_migrations (version) VALUES ('20160609081158');

INSERT INTO schema_migrations (version) VALUES ('20160614071055');

INSERT INTO schema_migrations (version) VALUES ('20160615145518');

INSERT INTO schema_migrations (version) VALUES ('20160627063918');

INSERT INTO schema_migrations (version) VALUES ('20160708084933');

INSERT INTO schema_migrations (version) VALUES ('20160728102918');

INSERT INTO schema_migrations (version) VALUES ('20160728130503');

INSERT INTO schema_migrations (version) VALUES ('20160816083020');

INSERT INTO schema_migrations (version) VALUES ('20160816083028');

INSERT INTO schema_migrations (version) VALUES ('20160816083349');

INSERT INTO schema_migrations (version) VALUES ('20160816083607');

INSERT INTO schema_migrations (version) VALUES ('20160816123633');

INSERT INTO schema_migrations (version) VALUES ('20160817130729');

INSERT INTO schema_migrations (version) VALUES ('20160817140558');

INSERT INTO schema_migrations (version) VALUES ('20160818090814');

INSERT INTO schema_migrations (version) VALUES ('20160818110351');

INSERT INTO schema_migrations (version) VALUES ('20160818111044');

INSERT INTO schema_migrations (version) VALUES ('20160818111724');

INSERT INTO schema_migrations (version) VALUES ('20160823073938');

INSERT INTO schema_migrations (version) VALUES ('20160823115429');

INSERT INTO schema_migrations (version) VALUES ('20160823120425');

INSERT INTO schema_migrations (version) VALUES ('20160823120704');

INSERT INTO schema_migrations (version) VALUES ('20160823120845');

INSERT INTO schema_migrations (version) VALUES ('20160831054404');

INSERT INTO schema_migrations (version) VALUES ('20160831054544');

INSERT INTO schema_migrations (version) VALUES ('20160831054909');

INSERT INTO schema_migrations (version) VALUES ('20160831054910');

INSERT INTO schema_migrations (version) VALUES ('20160902103712');

INSERT INTO schema_migrations (version) VALUES ('20160902104733');

INSERT INTO schema_migrations (version) VALUES ('20160907095103');

INSERT INTO schema_migrations (version) VALUES ('20160908091353');

INSERT INTO schema_migrations (version) VALUES ('20160913110411');

INSERT INTO schema_migrations (version) VALUES ('20160913112734');

INSERT INTO schema_migrations (version) VALUES ('20160914070509');

INSERT INTO schema_migrations (version) VALUES ('20160914071634');

INSERT INTO schema_migrations (version) VALUES ('20160914072428');

INSERT INTO schema_migrations (version) VALUES ('20160914072601');

INSERT INTO schema_migrations (version) VALUES ('20160920081409');

INSERT INTO schema_migrations (version) VALUES ('20160920102506');

INSERT INTO schema_migrations (version) VALUES ('20160920102507');

INSERT INTO schema_migrations (version) VALUES ('20160920103321');

INSERT INTO schema_migrations (version) VALUES ('20160921130544');

INSERT INTO schema_migrations (version) VALUES ('20160926111847');

INSERT INTO schema_migrations (version) VALUES ('20160928080048');

INSERT INTO schema_migrations (version) VALUES ('20160928080819');

INSERT INTO schema_migrations (version) VALUES ('20160929114326');

INSERT INTO schema_migrations (version) VALUES ('20160929124124');

INSERT INTO schema_migrations (version) VALUES ('20160930070122');

INSERT INTO schema_migrations (version) VALUES ('20161004141208');

INSERT INTO schema_migrations (version) VALUES ('20161006074506');

INSERT INTO schema_migrations (version) VALUES ('20161012132850');

INSERT INTO schema_migrations (version) VALUES ('20161018090313');

INSERT INTO schema_migrations (version) VALUES ('20161018090314');

INSERT INTO schema_migrations (version) VALUES ('20161018090517');

INSERT INTO schema_migrations (version) VALUES ('20161018093208');

INSERT INTO schema_migrations (version) VALUES ('20161018100657');

INSERT INTO schema_migrations (version) VALUES ('20161018105036');

INSERT INTO schema_migrations (version) VALUES ('20161018105521');

INSERT INTO schema_migrations (version) VALUES ('20161019125057');

INSERT INTO schema_migrations (version) VALUES ('20161023074355');


CREATE TABLE `conversations` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(255) default NULL,
  `listing_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `favors` (
  `id` int(11) NOT NULL auto_increment,
  `owner_id` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `description` text,
  `payment` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `status` varchar(255) default 'enabled',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

CREATE TABLE `feedbacks` (
  `id` int(11) NOT NULL auto_increment,
  `content` text,
  `author_id` varchar(255) default NULL,
  `url` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `filters` (
  `id` int(11) NOT NULL auto_increment,
  `person_id` varchar(255) default NULL,
  `keywords` text,
  `category` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `items` (
  `id` int(11) NOT NULL auto_increment,
  `owner_id` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `payment` int(11) default NULL,
  `status` varchar(255) default 'enabled',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

CREATE TABLE `kassi_events` (
  `id` int(11) NOT NULL auto_increment,
  `receiver_id` varchar(255) default NULL,
  `realizer_id` varchar(255) default NULL,
  `eventable_id` int(11) default NULL,
  `eventable_type` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `kassi_events_people` (
  `person_id` varchar(255) default NULL,
  `kassi_event_id` varchar(255) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `listing_comments` (
  `id` int(11) NOT NULL auto_increment,
  `author_id` varchar(255) default NULL,
  `listing_id` int(11) default NULL,
  `content` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `is_read` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `listings` (
  `id` int(11) NOT NULL auto_increment,
  `author_id` varchar(255) default NULL,
  `category` varchar(255) default NULL,
  `title` varchar(255) default NULL,
  `content` text,
  `good_thru` date default NULL,
  `times_viewed` int(11) default NULL,
  `status` varchar(255) default NULL,
  `value_cc` int(11) default NULL,
  `value_other` varchar(255) default NULL,
  `language` varchar(255) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

CREATE TABLE `messages` (
  `id` int(11) NOT NULL auto_increment,
  `sender_id` varchar(255) default NULL,
  `content` text,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `conversation_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `people` (
  `id` varchar(22) NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `is_admin` int(11) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `person_comments` (
  `id` int(11) NOT NULL auto_increment,
  `author_id` varchar(255) default NULL,
  `target_person_id` varchar(255) default NULL,
  `text_content` text,
  `grade` int(11) default NULL,
  `task_type` varchar(255) default NULL,
  `task_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `kassi_event_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `person_conversations` (
  `id` int(11) NOT NULL auto_increment,
  `person_id` varchar(255) default NULL,
  `conversation_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `is_read` int(11) default '0',
  `last_sent_at` datetime default NULL,
  `last_received_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `person_interesting_listings` (
  `id` int(11) NOT NULL auto_increment,
  `person_id` varchar(255) default NULL,
  `listing_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `person_read_listings` (
  `id` int(11) NOT NULL auto_increment,
  `person_id` varchar(255) default NULL,
  `listing_id` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `transactions` (
  `id` int(11) NOT NULL auto_increment,
  `sender_id` varchar(255) default NULL,
  `receiver_id` varchar(255) default NULL,
  `listing_id` int(11) default NULL,
  `amount` int(11) default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO schema_migrations (version) VALUES ('20080806070738');

INSERT INTO schema_migrations (version) VALUES ('20080807071903');

INSERT INTO schema_migrations (version) VALUES ('20080807080513');

INSERT INTO schema_migrations (version) VALUES ('20080808095031');

INSERT INTO schema_migrations (version) VALUES ('20080814135006');

INSERT INTO schema_migrations (version) VALUES ('20080815075550');

INSERT INTO schema_migrations (version) VALUES ('20080818091109');

INSERT INTO schema_migrations (version) VALUES ('20080818092139');

INSERT INTO schema_migrations (version) VALUES ('20080821103835');

INSERT INTO schema_migrations (version) VALUES ('20080821105542');

INSERT INTO schema_migrations (version) VALUES ('20080825064927');

INSERT INTO schema_migrations (version) VALUES ('20080825114546');

INSERT INTO schema_migrations (version) VALUES ('20080827084204');

INSERT INTO schema_migrations (version) VALUES ('20080828090629');

INSERT INTO schema_migrations (version) VALUES ('20080828104013');

INSERT INTO schema_migrations (version) VALUES ('20080828104239');

INSERT INTO schema_migrations (version) VALUES ('20080912072148');

INSERT INTO schema_migrations (version) VALUES ('20080912072238');

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
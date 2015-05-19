require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)
class RemoveUnstandardizedCustomLanguages < ActiveRecord::Migration
  include LoggingHelper

  LANGUAGE_MAP = {
    "de-bl" => "de",
    "de-rc" => "de",
    "en-bd" => "en",
    "en-bf" => "en",
    "en-bl" => "en",
    "en-cf" => "en",
    "en-rc" => "en",
    "en-sb" => "en",
    "en-ul" => "sv",
    "en-un" => "fr",
    "en-vg" => "en",
    "es-rc" => "es",
    "fr-bd" => "fr",
    "fr-rc" => "fr"
  }

  UNSTANDARD_LANGUAGES = LANGUAGE_MAP.keys.to_set

  def up
    communities = communities_w_unstandard_locales

    progress = ProgressReporter.new(communities.size)

    puts ""
    puts "-- Removing unstandard locales"
    puts ""

    ActiveRecord::Base.transaction do
      communities.each do |(c, all_unstandard_locales)|

        all_unstandard_locales.each do |unstandard_locale|
          fallback = LANGUAGE_MAP[unstandard_locale]

            # Set up the fallback locale (if it's not already there)
            if !c.locales.include?(fallback)
              change_locale(community: c, from: unstandard_locale, to: fallback)

              replace_locale_settings(community: c, from: unstandard_locale, to: fallback)
            else
              puts "-- WARNING: Community #{c.ident} has unstandard locale #{unstandard_locale}, but it already has the fallback locale #{fallback}"

              remove_locale_settings(community: c, locale: unstandard_locale)
            end
        end

        print_dot
        progress.next
      end
    end
  end

  def down
    # noop
  end

  private

  def communities_w_unstandard_locales
    community_w_unstandard_locale = []

    puts ""
    puts "-- Searching communities with unstandard locales"
    puts ""

    progress = ProgressReporter.new(Community.count, 200)

    Community.find_each do |c|
      unstandard_locales = c.locales.to_set.intersection(UNSTANDARD_LANGUAGES)
      if !unstandard_locales.empty?
        community_w_unstandard_locale << [c, unstandard_locales]
      end

      print_dot
      progress.next
    end

    community_w_unstandard_locale
  end

  def change_locale(community:, from:, to:)
    [
      community.categories.flat_map(&:translations),
      community.community_customizations,
      community.custom_fields.flat_map(&:names),
      community.custom_fields.flat_map(&:options).flat_map(&:titles),
      community.menu_links.flat_map(&:translations)
    ].map do |models|
      models.select { |m| m.locale == from }
    end.each do |models|
      change_model_locale(models, to)
    end

    CommunityTranslation.where(community_id: community.id, locale: from).update_all(locale: to)
    Rails.cache.delete("/translation_service/community/#{community.id}")
  end

  def change_model_locale(models, new_locale)
    models.each { |m|
      m.update_attribute(:locale, new_locale)
    }
  end

  def remove_locale_settings(community:, locale:)
    community.settings["locales"] = community.settings["locales"] - [locale]
    community.save!
  end

  def replace_locale_settings(community:, from:, to:)
    community.settings["locales"] = community.settings["locales"].map { |l|
      if l == from
        to
      else
        l
      end
    }
    community.save!
  end
end

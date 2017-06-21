class RemoveMoreUnstandardLocales < ActiveRecord::Migration

  # Redefine all Active Record models, so that the migration doesn't depend on the version of code
  module MigrationModel
    class Community < ApplicationRecord
      has_many :categories, class_name: "::RemoveMoreUnstandardLocales::MigrationModel::Category"
      has_many :community_customizations, class_name: "::RemoveMoreUnstandardLocales::MigrationModel::CommunityCustomization"
      has_many :custom_fields, class_name: "::RemoveMoreUnstandardLocales::MigrationModel::CustomField"
      has_many :menu_links, class_name: "::RemoveMoreUnstandardLocales::MigrationModel::MenuLink"
      serialize :settings, Hash

      def locales
        Maybe(settings)["locales"].or_else([])
      end
    end

    class Category < ApplicationRecord
      has_many :translations, class_name: "::RemoveMoreUnstandardLocales::MigrationModel::CategoryTranslation"
    end

    class CategoryTranslation < ApplicationRecord
      belongs_to :category, touch: true, class_name: "::RemoveMoreUnstandardLocales::MigrationModel::Category"
    end

    class CommunityCustomization < ApplicationRecord
    end

    class CustomField < ApplicationRecord
      has_many :names, class_name: "::RemoveMoreUnstandardLocales::MigrationModel::CustomFieldName"
      has_many :options, class_name: "::RemoveMoreUnstandardLocales::MigrationModel::CustomFieldOption"

      # Ignore STI and 'type' column
      self.inheritance_column = nil
    end

    class CustomFieldName < ApplicationRecord
      belongs_to :custom_field, touch: true, class_name: "::RemoveMoreUnstandardLocales::MigrationModel::CustomField"
    end

    class CustomFieldOption < ApplicationRecord
      has_many :titles, :foreign_key => "custom_field_option_id", class_name: "::RemoveMoreUnstandardLocales::MigrationModel::CustomFieldOptionTitle"
    end

    class CustomFieldOptionTitle < ApplicationRecord
      belongs_to :custom_field_option, touch: true, class_name: "::RemoveMoreUnstandardLocales::MigrationModel::CustomFieldOption"
    end

    class MenuLink < ApplicationRecord
      has_many :translations, class_name: "::RemoveMoreUnstandardLocales::MigrationModel::MenuLinkTranslation"
    end

    class MenuLinkTranslation < ApplicationRecord
      belongs_to :menu_link, touch: true, class_name: "::RemoveMoreUnstandardLocales::MigrationModel::MenuLink"
    end

    class CommunityTranslation < ApplicationRecord
    end
  end

  LANGUAGE_MAP = {
    "en-qr" => "en",
    "en-at" => "en",
    "fr-at" => "fr"
  }

  UNSTANDARD_LANGUAGES = LANGUAGE_MAP.keys.to_set

  def up
    communities = communities_w_unstandard_locales(UNSTANDARD_LANGUAGES)

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

          puts "Changed locale from: #{unstandard_locale} to: #{fallback} for community: #{c.ident}"
        end
      end
    end
  end

  def down
    # noop
  end

  private

  def communities_w_unstandard_locales(unstandard_locales)
    comms_w_unstandard_locale = []

    puts ""
    puts "-- Searching communities with unstandard locales"
    puts ""

    where_unstandard_locales(MigrationModel::Community, unstandard_locales).each do |c|
      intersection = c.locales.to_set.intersection(unstandard_locales)
      if !intersection.empty?
        comms_w_unstandard_locale << [c, intersection]
      end
    end

    comms_w_unstandard_locale
  end

  def where_unstandard_locales(community_model, unstandard_locales)
    query = unstandard_locales.map { |l|
      "settings LIKE '%#{l}%'"
    }.join(" OR ")

    community_model.where(query)
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

    MigrationModel::CommunityTranslation.where(community_id: community.id, locale: from).update_all(locale: to)
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

# coding: utf-8
class OldNightUnitToCustomUnit < ActiveRecord::Migration

  class Community < ApplicationRecord
    serialize :settings, Hash

    def locales
     if settings && !settings["locales"].blank?
        settings["locales"]
      else
        # if locales not set, return the short locales from the default list
        available_locales
      end
    end
  end

  def up
    # 1. Transactions that need change:
    transaction_res =
      execute("
        SELECT tx.community_id, tx.id FROM transactions tx
        LEFT JOIN bookings ON bookings.transaction_id = tx.id
        WHERE tx.unit_type = 'night' AND bookings.id IS NULL
      ")

    transaction_res_array = transaction_res.to_a
    community_ids = transaction_res_array.map(&:first).uniq

    # Languages in use from community
    translation_data = Community.where(id: community_ids).map { |c|
      unit_tr_key = SecureRandom.uuid
      unit_selector_tr_key = SecureRandom.uuid

      [c.id, {
         unit_tr_key: unit_tr_key,
         unit_selector_tr_key: unit_selector_tr_key,
         locales: c.locales.map(&:to_s)
       }]
    }.to_h

    # Create data for new rows to `community_translations`
    new_translation_data = translation_data.flat_map { |(community_id, tr_data)|

      tr_data[:locales].flat_map { |l|
        [
          {
            community_id: community_id,
            locale: l,
            translation_key: tr_data[:unit_tr_key],
            translation: night_unit_translations[l.to_s]
          },
          {
            community_id: community_id,
            locale: l,
            translation_key: tr_data[:unit_selector_tr_key],
            translation: night_selector_translations[l.to_s]
          }
        ]
      }
    }

    insert_into_values = new_translation_data.map { |tr_data|
      "(#{tr_data[:community_id]}, '#{tr_data[:locale]}', '#{tr_data[:translation_key]}', '#{tr_data[:translation]}', NOW(), NOW())"
    }

    new_translations_sql =
      if !insert_into_values.empty?
        "INSERT INTO community_translations (community_id, locale, translation_key, translation, created_at, updated_at) VALUES #{insert_into_values.join(', ')}"
      else
        nil
      end

    tx_ids_by_community = transaction_res_array.reduce({}) { |memo, (community_id, tx_id)|
      memo[community_id] ||= []
      memo[community_id].push(tx_id)
      memo
    }

    update_tx_sql_statements = tx_ids_by_community.map { |community_id, tx_ids|
      unit_tr_key = translation_data[community_id][:unit_tr_key]
      unit_selector_tr_key = translation_data[community_id][:unit_selector_tr_key]

      "UPDATE transactions SET unit_type = 'custom', unit_tr_key = '#{unit_tr_key}', unit_selector_tr_key = '#{unit_selector_tr_key}' WHERE transactions.id IN (#{tx_ids.join(',')}) AND transactions.community_id = #{community_id}"
    }

    ActiveRecord::Base.transaction do
      exec_update("UPDATE transactions SET old_unit_type = unit_type", "Save old unit type for rollback", [])

      if !new_translations_sql.blank?
        exec_insert(new_translations_sql, "Add new translations", [])
      end

      update_tx_sql_statements.each { |update_tx|
        exec_update(update_tx, "Update transactions' unit to custom", [])
      }
    end

    # Invalidate cache
    community_ids.map { |(community_id)|
      Rails.cache.delete("/translation_service/community/#{community_id}")
    }
  end

  def down
    transactions_to_change = exec_query(
      "SELECT id, unit_tr_key, unit_selector_tr_key FROM transactions WHERE old_unit_type = 'night' AND unit_type = 'custom'",
      "Select transactions to rollback",
      []
    ).to_a

    return if transactions_to_change.empty?

    ActiveRecord::Base.transaction do
      tx_ids = transactions_to_change.map { |row| row["id"] }
      exec_update(
        "UPDATE transactions SET unit_type = 'night', unit_tr_key = NULL, unit_selector_tr_key = NULL WHERE id IN (#{tx_ids.join(',')})",
        "Rollback old unit type",
        []
      )

      tr_keys = transactions_to_change.flat_map { |row| ["'#{row["unit_tr_key"]}'", "'#{row["unit_selector_tr_key"]}'"] }.uniq
      exec_delete(
        "DELETE FROM community_translations WHERE translation_key IN (#{tr_keys.join(',')})",
        "Rollback translations",
        []
      )

      exec_update("UPDATE transactions SET old_unit_type = NULL", "Empty old unit type", [])
    end
  end

  def available_locales
    Set.new([
      "da-DK",
      "de",
      "el",
      "en",
      "en-AU",
      "en-GB",
      "es-ES",
      "es",
      "fi",
      "fr",
      "fr-CA",
      "it",
      "ja",
      "nb",
      "nl",
      "pt-BR",
      "ru",
      "sv",
      "tr-TR",
      "zh",
      "pt-PT",
      "ca",
      "en-NZ",
      "et",
      "hr",
      "id",
      "is",
      "km-KH",
      "ms-MY",
      "pl",
      "ro",
      "sw",
      "vi",
      "hu",
      "cs",
      "th-TH",
      "bg",
      "mn",
      "zh-TW",
      "zh-HK",
      "ka",
      "sl",
      "sk-SK"
    ])

  end

  def night_unit_translations
    {
      "da-DK"=>"nat",
      "de"=>"Nacht",
      "el"=>"night",
      "en"=>"night",
      "en-AU"=>"night",
      "en-GB"=>"night",
      "es-ES"=>"noche",
      "es"=>"noche",
      "fi"=>"yö",
      "fr"=>"nuit",
      "fr-CA"=>"nuit",
      "it"=>"notte",
      "ja"=>"夜",
      "nb"=>"natt",
      "nl"=>"nacht",
      "pt-BR"=>"noite",
      "ru"=>"ночь",
      "sv"=>"natt",
      "tr-TR"=>"gecelik",
      "zh"=>"晚",
      "pt-PT"=>"noite",
      "ca"=>"night",
      "en-NZ"=>"night",
      "et"=>"night",
      "hr"=>"night",
      "id"=>"night",
      "is"=>"night",
      "km-KH"=>"night",
      "ms-MY"=>"night",
      "pl"=>"night",
      "ro"=>"night",
      "sw"=>"night",
      "vi"=>"night",
      "hu"=>"éjszaka",
      "cs"=>"noc",
      "th-TH"=>"night",
      "bg"=>"night",
      "mn"=>"night",
      "zh-TW"=>"晚",
      "zh-HK"=>"晚",
      "ka"=>"ღამე",
      "sl"=>"night",
      "sk-SK"=>"noc"
    }
  end

  def night_selector_translations
    {
      "da-DK"=>"Antal nætter:",
      "de"=>"Anzahl Nächte:",
      "el"=>"Number of nights:",
      "en"=>"Number of nights:",
      "en-AU"=>"Number of nights:",
      "en-GB"=>"Number of nights:",
      "es-ES"=>"Número de noches:",
      "es"=>"Número de noches:",
      "fi"=>"Öiden määrä:",
      "fr"=>"Nombre de nuits : ",
      "fr-CA"=>"Nombre de nuits : ",
      "it"=>"Numero di notti:",
      "ja"=>"宿泊日数：",
      "nb"=>"Antall netter:",
      "nl"=>"Number of nights:",
      "pt-BR"=>"Número de noites:",
      "ru"=>"Количество недель:",
      "sv"=>"Antal nätter:",
      "tr-TR"=>"Number of nights:",
      "zh"=>"夜晚数量:",
      "pt-PT"=>"Número de noites:",
      "ca"=>"Number of nights:",
      "en-NZ"=>"Number of nights:",
      "et"=>"Number of nights:",
      "hr"=>"Number of nights:",
      "id"=>"Number of nights:",
      "is"=>"Number of nights:",
      "km-KH"=>"Number of nights:",
      "ms-MY"=>"Number of nights:",
      "pl"=>"Number of nights:",
      "ro"=>"Number of nights:",
      "sw"=>"Number of nights:",
      "vi"=>"Number of nights:",
      "hu"=>"Éjszakák száma:",
      "cs"=>"Počet nocí:",
      "th-TH"=>"Number of nights:",
      "bg"=>"Number of nights:",
      "mn"=>"Number of nights:",
      "zh-TW"=>"夜晚数量:",
      "zh-HK"=>"晚：",
      "ka"=>"ღამეების რაოდენობა:",
      "sl"=>"Number of nights:",
      "sk-SK"=>"Počet nocí:"
    }
  end
end

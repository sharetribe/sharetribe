class HandleMoreRemovedPersonLocales < ActiveRecord::Migration
  LANGUAGE_MAP = {
    "en-qr" => "en",
    "en-at" => "en",
    "fr-at" => "fr"
  }

  class Person < ApplicationRecord
  end

  def up
    LANGUAGE_MAP.each do |locale, fallback|
      count = Person.where(locale: locale).count

      Person.where(locale: locale).update_all(locale: fallback)

      puts "Changed language of #{count} people from: #{locale} to: #{fallback}"
    end
  end

  def down
    # noop
  end
end

class HandleRemovedPersonLocales < ActiveRecord::Migration
  LANGUAGE_MAP = {
    "de-bl" => "de",
    "de-rc" => "de",
    "en-bd" => "en",
    "en-bf" => "en",
    "en-bl" => "en",
    "en-cf" => "en",
    "en-rc" => "en",
    "en-sb" => "en",
    "en-ul" => "en",
    "en-un" => "en",
    "en-vg" => "en",
    "es-rc" => "es",
    "fr-bd" => "fr",
    "fr-rc" => "fr"
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

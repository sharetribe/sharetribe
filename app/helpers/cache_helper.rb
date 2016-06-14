# encoding: utf-8

# This is included to ApplicationController
# Contains helper methods for cache handling
module CacheHelper

  # Constants for expire times

  # used for things that are stored completely on Sharetribe db
  KASSI_DATA_CACHE_EXPIRE_TIME = 4.hours

  # used to ensure "soft changes" e.g. translation updates propagate to cached fragments eventually
  FRAGMENT_CACHE_EXPIRE_TIME = 4.hours

  def self.favors_last_changed
    Rails.cache.fetch("favors_last_changed", :expires_in => KASSI_DATA_CACHE_EXPIRE_TIME) {Time.now.to_i}
  end

  def self.update_favors_last_changed
    update_time_based_cache_key("favors_last_changed")
  end

  def self.items_last_changed
    Rails.cache.fetch("items_last_changed", :expires_in => KASSI_DATA_CACHE_EXPIRE_TIME) {Time.now.to_i}
  end

  def self.update_items_last_changed
    update_time_based_cache_key("items_last_changed")
  end

  def self.listings_last_changed
    Rails.cache.fetch("listings_last_changed", :expires_in => KASSI_DATA_CACHE_EXPIRE_TIME) {Time.now.to_i}
  end

  def self.update_listings_last_changed
    update_time_based_cache_key("listings_last_changed")
  end

  def self.frontpage_last_changed
    Rails.cache.fetch("frontpage_last_changed", :expires_in => KASSI_DATA_CACHE_EXPIRE_TIME) {Time.now.to_i}
  end

  def self.update_kassi_events_last_changed
    update_time_based_cache_key("kassi_events_last_changed")
  end

  def self.notifications_last_changed_for(id)
    Rails.cache.fetch("notifications_last_changed/for#{id}", :expires_in => KASSI_DATA_CACHE_EXPIRE_TIME) {Time.now.to_i}
  end

  def self.update_notifications_last_changed_for(id)
    Rails.cache.write("notifications_last_changed/for#{id}", Time.now.to_i, :expires_in => KASSI_DATA_CACHE_EXPIRE_TIME)
  end

  def update_caches_dependent_on_groups(person)
    # I18n.available_locales.each do |locale|
    #   Rails.cache.delete("items_list/#{locale.to_s}/#{items_last_changed}/#{person.id}")
    #  end

    # SHOULD USE SOMETHING LIKE ABOVE
    # this one below clears all the caches, so it slows the system down unnecessarily.

     CacheHelper.update_favors_last_changed
     CacheHelper.update_items_last_changed
     CacheHelper.update_listings_last_changed
  end

  # * people_last_changed (Time.now.to_i) tästä ei voi olla varmaa tietoa, joten oltava myös expire-aika
  # * groups_last_changed (Time.now.to_i) tästä ei voi olla varmaa tietoa, joten oltava myös expire-aika

  def frontpage_fragment_cache(type, listing, &block)
    listings_i18n_digest = Rails.cache.fetch(["listings_i18n", @current_community, I18n.locale], :expires_in => 5.minutes) { Digest::MD5.hexdigest I18n.t(["listings"]).to_s }
    cache([type, listings_i18n_digest, @current_community, listing, listing.author, MoneyRails::Configuration.no_cents_if_whole], :expires_in => FRAGMENT_CACHE_EXPIRE_TIME, &block)
  end

  # Cache helper for React components
  #
  # Params:
  #
  # - `name`: the name of the component (string)
  # - `props`: props (hash)
  # - `rails_context_keys`: list of values in railsContext that should
  #                         invalidate the cache
  # - `extra_keys`: anything extra that should invalidate the cache
  #
  # Note about `rails_context_keys`: In order to properly invalidate
  # the cache, you need to list here all keys in the railsContext hash
  # that should invalidate the cache. You don't need to include keys
  # if they don't affect to the server rendered output of the
  # component.
  #
  # Please note that if you turn on caching in development but do not run
  # assets:precompile, the cache will not be invalidated because the server bundle
  # filename doesn't change.
  #
  def react_component_cache(name:, props:, rails_context_keys: [], extra_keys: [], &block)
    if controller.perform_caching && !digest_assets
      Rails.logger.warn(
        "'perform_caching' is turned on but the assets do not have digest. " \
        "react_component_cache will not be invalidated correctly")
    end

    bundle_file = asset_path(ReactOnRails.configuration.server_bundle_js_file)

    default_rails_context_keys = [
      :i18nLocale,
      :i18nDefaultLocale
    ]

    # Pick the rails context values that will affect to the rendering of
    # this particular component
    rails_context_subset = rails_context(server_side: false)
                           .slice(*(rails_context_keys + default_rails_context_keys))

    # All values in rails context extension will invalidate the
    # cache, if the values change
    rails_context_extension = RailsContextExtension.custom_context(self)

    keys = [
      'react_component_cache_v2',
      name,
      props,
      locale,
      bundle_file,
      rails_context_extension,
      rails_context_subset
    ]

    # We can skip the digest because we don't care if the .haml template changes.
    cache(keys + extra_keys, {skip_digest: true}, &block)
  end

  private

  def self.update_time_based_cache_key(key)

     new_value = Time.now.to_f

      Rails.cache.write(key, new_value, :expires_in => KASSI_DATA_CACHE_EXPIRE_TIME)

      # Because currently every update in cache control affects frontpage, update that value too
      #puts  "Clearing the front page cache, because: #{key}, NEW VALUE IS #{new_value}"
      Rails.cache.write("frontpage_last_changed", new_value, :expires_in => KASSI_DATA_CACHE_EXPIRE_TIME)

  end
end

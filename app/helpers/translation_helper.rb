module TranslationHelper

  def ts(key, opts = {})
    community = @current_community || opts[:community]
    @community_translations ||= TranslationService::API::Api.translations.get(community.id)[:data]
    TranslationServiceHelper.pick_translation(key, @community_translations, community.locales, I18n.locale, opts.except(:community))
  end

end

module MailUtils
  # Refactoring needed. This is an ugly method that sets
  #
  # DEPRECATED! Do not use this anymore! See TransactionMailer.transaction_created how you can live without calling
  # this method
  def set_up_urls(recipient, community, ref="email")
    @community = community
    @current_community = community
    @url_params = {}
    @url_params[:host] = community.full_domain
    @url_params[:ref] = ref
    if recipient
      @recipient = recipient
      @url_params[:locale] = @recipient.locale
    end
  end

  def with_locale(recipient_locale, community_id = nil, &block)
    set_locale(recipient_locale) {
      set_community(community_id) {
        block.call
      }
    }
  end

  def premailer(message)
    if message.body.parts.present?
      message.text_part.body = Premailer.new(message.text_part.body.to_s, with_html_string: true).to_plain_text
      message.html_part.body = Premailer.new(message.html_part.body.to_s, with_html_string: true).to_inline_css
    else
      message.body = Premailer.new(message.body.to_s, with_html_string: true).to_inline_css
    end
  end

  # private

  def set_locale(new_locale, &block)
    old_locale = I18n.locale

    if old_locale.to_sym != new_locale.to_sym
      I18n.locale = new_locale
      begin
        block.call
      ensure
        I18n.locale = old_locale
      end
    else
      block.call
    end
  end

  def set_community(new_community_id, &block)
    community_backend = I18n::Backend::CommunityBackend.instance
    old_community_id = community_backend.community_id

    if old_community_id != new_community_id
      community_backend.set_community!(new_community_id, clear: false)
      community_translations = TranslationService::API::Api.translations.get(new_community_id)[:data]
      TranslationServiceHelper.community_translations_for_i18n_backend(community_translations).each { |locale, data|
        # Store community translations to I18n backend.
        #
        # Since the data in data hash is already flatten, we don't want to
        # escape the separators (. dots) in the key
        community_backend.store_translations(locale, data, escape: false)
      }
      begin
        block.call
      ensure
        community_backend.set_community!(old_community_id, clear: false)
      end
    else
      block.call
    end
  end

  module_function

  def community_specific_sender(community)
    if community && community.custom_email_from_address
      community.custom_email_from_address
    else
      APP_CONFIG.sharetribe_mail_from_address
    end
  end
end

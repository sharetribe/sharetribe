module MailUtils
  # Refactoring needed. This is an ugly method that sets a lot of global state
  #
  # Avoid adding more state to instance variables. Instead, pass the data to
  # the `render` method in `locals` hash.
  #
  # If the data is used in the layout, you can make an exception and set it to instance variable
  def set_up_layout_variables(recipient, community, ref="email")
    @community = community
    @current_community = community
    @url_params = {}
    @url_params[:host] = community.full_domain
    @url_params[:ref] = ref
    @show_branding_info = !PlanService::API::Api.plans.get_current(community_id: community.id).data[:features][:whitelabel]
    if recipient
      @recipient = recipient
      @unsubscribe_token = AuthToken.create_unsubscribe_token(person_id: @recipient.id).token
      @url_params[:locale] = @recipient.locale
    end
  end

  def with_locale(recipient_locale, community_locales, community_id = nil, &block)
    set_locale(recipient_locale) {
      set_community(community_id, community_locales) {
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

  def set_community(new_community_id, community_locales, &block)
    community_backend = I18n::Backend::CommunityBackend.instance
    old_community = community_backend.set_community!(new_community_id, community_locales, clear: false)

    if old_community[:community_id] != new_community_id
      community_translations = TranslationService::API::Api.translations.get(new_community_id)[:data]
      TranslationServiceHelper.community_translations_for_i18n_backend(community_translations).each { |locale, data|
        # Store community translations to I18n backend.
        #
        # Since the data in data hash is already flatten, we don't want to
        # escape the separators (. dots) in the key
        community_backend.store_translations(locale, data, escape: false)
      }
    end

    begin
      block.call
    ensure
      community_backend.set_community!(old_community[:community_id], old_community[:locales_in_use], clear: false)
    end
  end

  module_function

  def community_specific_sender(community)
    cid = Maybe(community).id.or_else(nil)
    EmailService::API::Api.addresses.get_sender(community_id: cid).data[:smtp_format]
  end
end

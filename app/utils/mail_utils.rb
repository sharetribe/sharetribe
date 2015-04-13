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

  def with_setup(recipient_locale, community_id = nil, &block)
    with_locale(mail_locale) {
      with_community(community_id) {
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

  def with_locale(new_locale, &block)
    old_locale = I18n.locale

    if old_locale.to_sym != new_locale.to_sym
      I18n.locale = new_locale
      # TODO store_translations here
      block.call
      I18n.locale = old_locale
    else
      block.call
    end
  end

  def with_community(new_community_id)
    old_community_id = I18n::Backend::CommunityBackend.community_id

    if old_community_id != new_community_id
      I18n::Backend::CommunityBackend.community_id = new_community_id
      block.call
      I18n::Backend::CommunityBackend.community_id = old_community_id
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

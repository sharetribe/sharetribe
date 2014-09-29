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
      set_locale @recipient.locale
    end
  end

  def premailer(message)
    if message.body.parts.present?
      message.text_part.body = Premailer.new(message.text_part.body.to_s, with_html_string: true).to_plain_text
      message.html_part.body = Premailer.new(message.html_part.body.to_s, with_html_string: true).to_inline_css
    else
      message.body = Premailer.new(message.body.to_s, with_html_string: true).to_inline_css
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

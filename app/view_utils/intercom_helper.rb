# coding: utf-8
module IntercomHelper

  # Copied from
  #
  # https://github.com/intercom/intercom-rails/blob/1a077474f33c2629de1d1a46ff67f97c0b9a0264/lib/intercom-rails/shutdown_helper.rb
  #
  # ...with modifications.
  #
  module ShutdownHelper

    LOGOUT_KEY = :prepare_intercom_shutdown

    # This function imitates Intercom JavaScript library and how it
    # defines the cookie domain. This regexp was found from the minified
    # Intercom JavaScript library.
    #
    # The original JavaScript code:
    #
    # ```js
    # var n = /[^.]*\.([^.]*|..\...|...\...)$/,
    # o = /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;
    #
    # findDomain: function(e) {
    #   var t = e.match(o);
    #   if (!t && (t = e.match(n))) {
    #     var r = t[0];
    #     return r = r.split(":")[0], "." + r
    #   }
    # }
    # ```
    #
    # The regexp `o` is omitted. (It seems to be IP matcher)
    #
    def self.find_domain(host_with_port)
      domain_regexp = /[^.]*\.([^.]*|..\...|...\...)$/

      match = domain_regexp.match(host_with_port)

      ".#{match[0].split(":")[0]}"
    end

    def self.intercom_shutdown(session, cookies, host_with_port)
      domain = find_domain(host_with_port)
      cookies.delete("intercom-session-#{IntercomHelper.admin_intercom_app_id}".to_sym, domain: domain)
    end
  end

  CONSOLE_CHECK = "\u{2705} "
  CONSOLE_CROSS = "\u{274c} "
  CONSOLE_WARNING = "\u{26A0} "
  HTML_CHECK = "\u{2705}&nbsp;"
  HTML_CROSS = "\u{274c}&nbsp;"
  HTML_WARNING = "\u{26A0}&nbsp;"

  CONSOLE_ICONS = {
    check: CONSOLE_CHECK,
    warning: CONSOLE_WARNING,
    cross: CONSOLE_CROSS
  }

  HTML_ICONS = {
    check: HTML_CHECK,
    warning: HTML_WARNING,
    cross: HTML_CROSS
  }

  module_function

  # Create a user_hash for Secure mode
  # https://docs.intercom.com/configure-intercom-for-your-product-or-site/staying-secure/enable-secure-mode-on-your-web-product
  def user_hash(user_id)
    secret = APP_CONFIG.admin_intercom_secure_mode_secret
    OpenSSL::HMAC.hexdigest('sha256', secret, user_id) if secret.present?
  end

  def admin_intercom_respond_enabled?
    APP_CONFIG.admin_intercom_respond_enabled.to_s.casecmp("true").zero?
  end

  def admin_intercom_app_id
    APP_CONFIG.admin_intercom_app_id
  end

  def email(user_model)
    (user_model.primary_email || user_model.emails.first).address
  end

  def identity_information(user_model)
    marketplace = user_model.community

    {
      info_user_id_old: user_model.id,
      info_marketplace_id: marketplace.uuid_object.to_s,
      info_marketplace_id_old: marketplace.id,
      info_marketplace_url: marketplace.full_url,
      info_email_confirmed: user_model.primary_email.present?
    }
  end

  def verify(conversation_id)
    token = APP_CONFIG.admin_intercom_access_token
    admin_id = APP_CONFIG.admin_intercom_admin_id
    intercom = Intercom::Client.new(token: token)

    conversation = intercom.conversations.find(id: conversation_id)

    if conversation
      puts "#{CONSOLE_CHECK} Found conversation"
    else
      puts "#{CONSOLE_CROSS} Could not find conversation"
      return :error
    end

    intercom_user = intercom.users.load(conversation.user)

    if intercom_user
      puts "#{CONSOLE_CHECK} Found user from Intercom"
    else
      puts "#{CONSOLE_CROSS} Could not find user from Intercom"
      return :error
    end

    user_model = find_user_by_uuid(intercom_user.user_id)

    if user_model
      puts "#{CONSOLE_CHECK} Found user from database"
    else
      puts "#{CONSOLE_CROSS} Could not find user from database"
      return :error
    end

    verification_result = do_verification(intercom_user, user_model)
    puts "#{CONSOLE_CHECK} Verification done"

    intercom.conversations.reply(id: conversation_id, type: 'admin', admin_id: admin_id, message_type: 'note', body: format_result_html(verification_result))
    puts "#{CONSOLE_CHECK} Verification note sent"

    puts ""
    puts format_result_console(verification_result)

    return verification_result[:result]
  end

  def format_result_console(verification_result)
    format_result_array(verification_result, CONSOLE_ICONS).join("\n")
  end

  def format_result_html(verification_result)
    format_result_array(verification_result, HTML_ICONS).join("<br />")
  end

  def format_result_array(verification_result, icons)
    result =
      if verification_result[:result] == :passed
        "#{icons[:check]} Identity verification PASSED"
      elsif verification_result[:result] == :warning
        "#{icons[:warning]} Identity verification PASSED, with WARNINGS"
      else
        "#{icons[:cross]} Identity verification FAILED"
      end

    messages = verification_result[:results].map { |res|
      result_msg =

        if res[:passed] == :passed
          "#{icons[:check]} #{res[:field_name]}: #{res[:intercom_value]}"
        elsif res[:passed] == :warning
          "#{icons[:warning]} #{res[:field_name]}: #{res[:intercom_value]}"
        else
          "#{icons[:cross]} #{res[:field_name]}: #{res[:intercom_value]}"
        end

      db_diff =
        if res[:database_value] != res[:intercom_value]
          "(in database: #{res[:database_value]})"
        end

      [result_msg, db_diff].compact.join(" ")
    }

    [result, ""] + messages
  end

  def find_user_by_uuid(uuid)
    user_uuid_object = UUIDTools::UUID.parse(uuid)
    user_uuid_raw = UUIDUtils.raw(user_uuid_object)

    Person.find_by(uuid: user_uuid_raw)
  end

  def do_verification(intercom_user, user_model)
    db_user_email = email(user_model)
    db_identity_information = identity_information(user_model)

    verification_results = [
      verify_email(intercom_user, user_model),
      verify_email_confirmation(intercom_user, db_identity_information[:info_email_confirmed])
    ] + verify_identity_information(intercom_user, db_identity_information.except(:info_email_confirmed))

    {
      result: verification_results.reduce(:passed) { |a, e| new_overall_result(a, e[:passed]) },
      results: verification_results
    }
  end

  def new_overall_result(overall_res, current_res)
    order = [
      :passed,
      :warning,
      :failed
    ]

    if order.index(overall_res) < order.index(current_res)
      current_res
    else
      overall_res
    end
  end

  def verify_email(intercom_user, user_model)
    db_user_email = email(user_model)

    {
      passed: intercom_user.email == db_user_email ? :passed : :failed,
      field_name: :email,
      intercom_value: intercom_user.email,
      database_value: db_user_email
    }
  end

  def verify_email_confirmation(intercom_user, db_email_confirmed)
    custom_attributes = intercom_user.custom_attributes

    verify_custom_attribute(:info_email_confirmed, db_email_confirmed, custom_attributes) { |db_value, intercom_value|
      case [db_value, intercom_value]
      when [true, true]
        :passed
      when [true, false]
        :warning
      when [false, true]
        :failed
      when [false, false]
        :warning
      end
    }
  end

  def verify_identity_information(intercom_user, db_identity_information)
    custom_attributes = intercom_user.custom_attributes

    db_identity_information.map { |key, db_value|
      verify_custom_attribute(key, db_value, custom_attributes)
    }
  end

  def verify_custom_attribute(key, db_value, custom_attributes, &block)
    passed_lambda = block || ->(a, b) { a == b ? :passed : :failed }

    intercom_value = custom_attributes[key]
    {
      passed: passed_lambda.call(db_value, intercom_value),
      field_name: key,
      intercom_value: intercom_value,
      database_value: db_value
    }
  end
end

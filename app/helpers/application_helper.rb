# rubocop:disable Metrics/ModuleLength
module ApplicationHelper

  # Removes whitespaces from HAML expressions
  # if you add two elements on two lines; the white space creates a space between the elements (in some browsers)
  def one_line_for_html_safe_content(&block)
    haml_concat capture_haml(&block).gsub("\n", '').html_safe
  end

  # Returns a human friendly format of the time stamp
  # Origin: http://snippets.dzone.com/posts/show/6229
  def time_ago(from_time, to_time = Time.now)
    return "" if from_time.nil?

    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round
    time = case distance_in_minutes
      when 0..1           then (distance_in_seconds < 60) ? t('timestamps.seconds_ago', :count => distance_in_seconds) : t('timestamps.minute_ago', :count => 1)
      when 2..59          then t('timestamps.minutes_ago', :count => distance_in_minutes)
      when 60..90         then t('timestamps.hour_ago', :count => 1)
      when 90..1440       then t('timestamps.hours_ago', :count => (distance_in_minutes.to_f / 60.0).round)
      when 1440..2160     then t('timestamps.day_ago', :count => 1) # 1-1.5 days
      when 2160..2880     then t('timestamps.days_ago', :count => (distance_in_minutes.to_f / 1440.0).round) # 1.5-2 days
      #else from_time.strftime(t('date.formats.default'))
    end
    if distance_in_minutes > 2880
      distance_in_days = (distance_in_minutes/1440.0).round
      time = case distance_in_days
        when 0..30    then t('timestamps.days_ago', :count => distance_in_days)
        when 31..50   then t('timestamps.month_ago', :count => 1)
        when 51..364  then t('timestamps.months_ago', :count => (distance_in_days.to_f / 30.0).round)
        else               t('timestamps.years_ago', :count => (distance_in_days.to_f / 365.24).round)
      end
    end

    return time
  end

  def translate_time_to(unit, count)
    t("timestamps.time_to.#{unit}", count: count)
  end

  # used to escape strings to URL friendly format
  def self.escape_for_url(str)
     URI.escape(str, Regexp.new("[^-_!~*()a-zA-Z\\d]")) # rubocop:disable Lint/UriEscapeUnescape
  end

  # Changes line breaks to <br>-tags and transforms URLs to links
  def text_with_line_breaks_html_safe(&block)
    haml_concat add_p_tags(capture_haml(&block)).html_safe
  end

  # Changes line breaks to <br>-tags and transforms URLs to links
  def text_with_line_breaks(&block)
    haml_concat add_links_and_br_tags(capture_haml(&block)).html_safe
  end

  # Changes line breaks to <br>-tags and transforms URLs to links
  def text_with_line_breaks_for_email(&block)
    haml_concat add_links_and_br_tags_for_email(capture_haml(&block)).html_safe
  end

  #  Transforms URLs to links
  def text_with_url_links(&block)
    haml_concat add_links(capture_haml(&block)).html_safe
  end

  def small_avatar_thumb(person, avatar_html_options={})
    avatar_thumb(:thumb, person, avatar_html_options)
  end

  def medium_avatar_thumb(person, avatar_html_options={})
    avatar_thumb(:small, person, avatar_html_options)
  end

  def avatar_thumb(size, person, avatar_html_options={})
    return "" if person.nil?

    image_url = person.image.present? ? person.image.url(size) : missing_avatar(size)

    link_to_unless(person.deleted?, image_tag(image_url, avatar_html_options), person)
  end

  def large_avatar_thumb(person, options={})
    image_url = person.image.present? ? person.image.url(:medium) : missing_avatar(:medium)

    image_tag image_url, { :alt => PersonViewUtils.person_display_name(person, @current_community) }.merge(options)
  end

  def huge_avatar_thumb(person, options={})
    # FIXME! Need a new picture size: :large

    image_url = person.image.present? ? person.image.url(:medium) : missing_avatar(:medium)

    image_tag image_url, { :alt => PersonViewUtils.person_display_name(person, @current_community) }.merge(options)
  end

  def missing_avatar(size = :medium)
    case size.to_sym
    when :small
      image_path("profile_image/small/missing.png")
    when :thumb
      image_path("profile_image/thumb/missing.png")
    else
      # default to medium size
      image_path("profile_image/medium/missing.png")
    end
  end

  def pageless(total_pages, target_id, url=nil, loader_message='Loading more results', current_page = 1)

    opts = {
      :currentPage => current_page,
      :totalPages => total_pages,
      :url => url,
      :loaderMsg => loader_message,
      :targetDiv => target_id # extra parameter for jquery.pageless.js patch
    }

    content_for :extra_javascript do
      javascript_tag("$('#{target_id}').pageless(#{opts.to_json});")
    end
  end

  # Class is selected if conversation type is currently selected
  def get_profile_extras_tab_class(tab_name)
    "inbox_tab_#{controller_name.eql?(tab_name) ? 'selected' : 'unselected'}"
  end

  def available_locales
    locales =
      if @current_community
        @current_community.locales
          .map { |loc| Sharetribe::AVAILABLE_LOCALES.find { |app_loc| app_loc[:ident] == loc } }
      else
        Sharetribe::AVAILABLE_LOCALES
      end

    locales.map { |loc| [loc[:name], loc[:ident]] }
  end

  def local_name(locale)
    available_locales.detect { |p| p[1] == locale.to_s }&.first
  end

  def self.send_error_notification(message, error_class="Special Error", parameters={})
    if APP_CONFIG.use_airbrake
      Airbrake.notify(
        :error_class => error_class,
        :error_message => message,
        :backtrace => $@,
        :environment_name => ENV['RAILS_ENV'],
        :parameters => parameters)
    end
    Rails.logger.error "#{error_class}: #{message}"
  end

  # Checks if HTTP_REFERER or HTTP_ORIGIN exists and returns only the domain part with protocol
  # This was first used to return user to original community from login domain.
  # Now the domain is included in the params, so this is used only in error cases to redirect back
  def self.pick_referer_domain_part_from_request(request)
    return request.headers["HTTP_ORIGIN"] if request.headers["HTTP_ORIGIN"].present?
    return request.headers["HTTP_REFERER"][/(^[^\/]*(\/\/)?[^\/]+)/,1] if request.headers["HTTP_REFERER"]

    return ""
  end

  def on_admin?
    controller.class.name.split("::").first=="Admin"
  end

  def on_admin2?
    controller.class.name.split("::").first=="Admin2"
  end

  def facebook_like(recommend=false)
    "<div class=\"fb-like\" data-send=\"true\" data-layout=\"button_count\" data-width=\"200\" data-show-faces=\"false\" #{recommend ? 'data-action="recommend"' : ''}></div>".html_safe
  end

  def self.random_sting(length=6)
    chars = ("a".."z").to_a + ("0".."9").to_a
    random_string = ""
    1.upto(length) { |i| random_string << chars[rand(chars.size-1)] }
    return random_string
  end

  def username_label
    (@current_community && @current_community.label.eql?("okl")) ? t("okl.member_id") : t("common.username")
  end

  def username_or_email_label
    (@current_community && @current_community.label.eql?("okl")) ? t("okl.member_id_or_email") : t("common.username_or_email")
  end

  def service_name
    if @current_community
      @current_community.name(I18n.locale)
    else
      APP_CONFIG.global_service_name || "Sharetribe"
    end
  end

  def email_not_accepted_message
    if @current_community && @current_community.allowed_emails.present?
      t("people.new.email_is_in_use_or_not_allowed")
    else
      t("people.new.email_is_in_use")
    end
  end
  # Class methods to access the service_name stored in the thread to work with I18N and DelayedJob etc async stuff.
  def self.store_community_service_name_to_thread(name)
    Thread.current[:current_community_service_name] = name
  end

  def self.store_community_service_name_to_thread_from_community_id(community_id=nil)
    community = nil
    if community_id.present?
      community = Community.find_by_id(community_id)
    end
    store_community_service_name_to_thread_from_community(community)
  end

  def self.store_community_service_name_to_thread_from_community(community=nil)
    ser_name = APP_CONFIG.global_service_name || "Sharetribe"

    # if community has it's own setting, dig it out here
    if community
      # TODO: To make sure that we always show the community name in correct locale,
      # we should pass the right locale instead of using the first locale. An alternative
      # fix would be to stop supporting having community name in multiple locales.
      ser_name = community.name(community.locales.first)
    end

    store_community_service_name_to_thread(ser_name)
  end

  def self.fetch_community_service_name_from_thread
    Thread.current[:current_community_service_name] || APP_CONFIG.global_service_name || "Sharetribe"
  end

  # Helper method for javascript. Return "undefined"
  # if tribe has no location.
  def tribe_latitude
    @current_community.location ? @current_community.location.latitude : "undefined"
  end

  # Helper method for javascript. Return "undefined"
  # if tribe has no location.
  def tribe_longitude
    @current_community.location ? @current_community.location.longitude : "undefined"
  end

  def add_p_tags(text)
    text.gsub(/\n/, "</p><p>")
  end

  def add_links(text)
    pattern = /[\.)]*$/
    text.gsub(/\b(https?:\/\/|www\.)\S+/i) do |link_url|
      site_url = (link_url.starts_with?("www.") ? "http://" + link_url : link_url)
      link_to(link_url.gsub(pattern,""), site_url.gsub(pattern,""), class: "truncated-link") + link_url.match(pattern)[0]
    end
  end

  # general method for making urls as links and line breaks as <br /> tags
  def add_links_and_br_tags(text)
    text = add_links(text)
    lines = ArrayUtils.trim(text.split(/\n/))
    lines.map { |line| "<p>#{line}</p>" }.join
  end

  # general method for making urls as links and line breaks as <br /> tags
  def add_links_and_br_tags_for_email(text)
    pattern = /[\.)]*$/
    text.gsub(/https?:\/\/\S+/) { |link_url| link_to(truncate(link_url.gsub(pattern,""), :length => 50, :omission => "..."), link_url.gsub(pattern,""), :style => "color:#d25427;text-decoration:none;") + link_url.match(pattern)[0]}.gsub(/\n/, "<br />")
  end

  def atom_feed_url(params={})
    url = "#{request.protocol}#{request.host_with_port}/listings.atom?locale=#{I18n.locale}"
    params.each do |key, value|
      url += "&#{key}=#{value}"
    end
    return url
  end

  # About view left hand navigation content
  def about_links
    links = [
      {
        :text => t('layouts.infos.about'),
        :icon_class => icon_class("information"),
        :path => about_infos_path,
        :name => "about"
      }
    ]
    links << {
      :text => t('layouts.infos.how_to_use'),
      :icon_class => icon_class("how_to_use"),
      :path => how_to_use_infos_path,
      :name => "how_to_use"
    }
    links << {
      :text => t('layouts.infos.register_details'),
      :icon_class => icon_class("privacy"),
      :path => privacy_infos_path,
      :name => "privacy"
    }
    links << {
      :text => t('layouts.infos.terms'),
      :icon_class => icon_class("terms"),
      :path => terms_infos_path,
      :name => "terms"
    }
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # Admin view left hand navigation content
  def admin_links_for(community)
    links = [
      {
        :topic => :general,
        :text => t("admin.communities.getting_started.getting_started"),
        :icon_class => icon_class("openbook"),
        :path => admin_getting_started_guide_path,
        :name => "getting_started_guide"
      },
      {
        :id => "admin-help-center-link",
        :topic => :general,
        :text => t("admin.left_hand_navigation.help_center"),
        :icon_class => icon_class("help"),
        :path => "#{APP_CONFIG.knowledge_base_url}/?utm_source=marketplaceadminpanel&utm_medium=referral&utm_campaign=leftnavi",
        :name => "help_center",
        :target => "_blank"
      },
      {
        :id => "admin-academy-link",
        :topic => :general,
        :text => t("admin.left_hand_navigation.academy"),
        :icon_class => icon_class("academy"),
        :path => "https://www.sharetribe.com/academy/guide/?utm_source=marketplaceadminpanel&utm_medium=referral&utm_campaign=leftnavi",
        :name => "academy",
        :target => "_blank"
      }
    ]

    if APP_CONFIG.external_plan_service_in_use
      links << {
        :topic => :general,
        :text => t("admin.left_hand_navigation.subscription"),
        :icon_class => icon_class("credit_card"),
        :path => admin_plan_path,
        :name => "plan"
      }
    end

    links << {
      :topic => :general,
      :text => t("admin.left_hand_navigation.whats_new"),
      :icon_class => icon_class("rocket"),
      :path => "https://www.sharetribe.com/updates.html",
      :name => "whats_new",
      :target => "_blank"
    }

    links << {
      :topic => :general,
      :text => t("admin.left_hand_navigation.preview"),
      :icon_class => icon_class("eye"),
      :path => homepage_without_locale_path(big_cover_photo: true, locale: nil),
      :name => "preview",
      :target => "_blank"
    }

    links += [
      {
        :topic => :manage,
        :text => t("admin.communities.manage_members.manage_members"),
        :icon_class => icon_class("community"),
        :path => admin_community_community_memberships_path(@current_community, sort: "join_date", direction: "desc"),
        :name => "manage_members"
      },
      {
        :topic => :manage,
        :text => t("admin.communities.listings.listings"),
        :icon_class => icon_class("thumbnails"),
        :path => admin_community_listings_path(@current_community, sort: "updated"),
        :name => "listings"
      },
      {
        :topic => :manage,
        :text => t("admin.communities.transactions.transactions"),
        :icon_class => icon_class("coins"),
        :path => admin_community_transactions_path(@current_community, sort: "last_activity", direction: "desc"),
        :name => "transactions"
      },
      {
        :topic => :manage,
        :text => t("admin.communities.conversations.conversations"),
        :icon_class => icon_class("chat_bubble"),
        :path => admin_community_conversations_path(@current_community, sort: "last_activity", direction: "desc"),
        :name => "conversations"
      },
      {
        :topic => :manage,
        :text => t("admin.communities.testimonials.testimonials"),
        :icon_class => icon_class("like"),
        :path => admin_community_testimonials_path(@current_community),
        :name => "testimonials"
      },
      {
        :topic => :manage,
        :text => t("admin.emails.new.send_email_to_members"),
        :icon_class => icon_class("send"),
        :path => new_admin_community_email_path(:community_id => @current_community.id),
        :name => "email_members"
      },
      {
        :topic => :manage,
        :text => t("admin.communities.invitations.invitations"),
        :icon_class => icon_class("invitations"),
        :path => admin_community_invitations_path(@current_community),
        :name => "invitations"
      },
      {
        :topic => :configure,
        :text => t("admin.communities.edit_details.community_details"),
        :icon_class => icon_class("details"),
        :path => admin_details_edit_path,
        :name => "tribe_details"
      },
      {
        :topic => :configure,
        :text => t("admin.communities.edit_details.community_look_and_feel"),
        :icon_class => icon_class("looknfeel"),
        :path => admin_look_and_feel_edit_path,
        :name => "tribe_look_and_feel"
      },
      {
        :topic => :configure,
        :text => t("admin.communities.domain.domain"),
        :icon_class => icon_class("domain"),
        :path => admin_domain_path,
        :name => "domain"
      },
      {
        :topic => :configure,
        :text => t("admin.communities.new_layout.new_layout"),
        :icon_class => icon_class("layout"),
        :path => admin_new_layout_path,
        :name => "new_layout"
      }
    ]

    links += [
      {
        :topic => :configure,
        :text => t("admin.communities.topbar.topbar"),
        :icon_class => icon_class("topbar_menu"),
        :path => admin_topbar_edit_path,
        :name => "topbar"
      }
    ]

    links += [
      {
        :topic => :configure,
        :text => t("admin.communities.footer.footer"),
        :icon_class => icon_class("footer_menu"),
        :path => admin_footer_edit_path,
        :name => "footer"
      }
    ]

    if APP_CONFIG.show_landing_page_admin
      links << {
        :topic => :configure,
        :text => t("admin.landing_page.landing_page"),
        :icon_class => icon_class("home"),
        :path => FeatureFlagHelper.feature_enabled?(:clp_editor) ? admin_landing_page_versions_path : admin_landing_page_path,
        :name => "landing_page"
      }
    end

    links += [
      {
        :topic => :configure,
        :text => t("admin.communities.user_fields.user_fields"),
        :icon_class => icon_class("user_edit"),
        :path => admin_person_custom_fields_path,
        :name => "user_fields"
      }
    ]

    links += [
      {
        :topic => :configure,
        :text => t("admin.categories.index.listing_categories"),
        :icon_class => icon_class("list"),
        :path => admin_categories_path,
        :name => "listing_categories"
      },
      {
        :topic => :configure,
        :text => t("admin.custom_fields.index.listing_fields"),
        :icon_class => icon_class("form"),
        :path => admin_custom_fields_path,
        :name => "listing_fields"
      }
    ]

    links << {
      :topic => :configure,
      :text => t("admin.listing_shapes.index.listing_shapes"),
      :icon_class => icon_class("order_types"),
      :path => admin_listing_shapes_path,
      :name => "listing_shapes"
    }

    if PaypalHelper.paypal_active?(@current_community.id) || StripeHelper.stripe_provisioned?(@current_community.id)
      links << {
        :topic => :configure,
        :text => t("admin.communities.settings.payment_preferences"),
        :icon_class => icon_class("payments"),
        :path => admin_payment_preferences_path(),
        :name => "payment_preferences"
      }
    end

    links << {
      :topic => :configure,
      :text => t("admin.communities.social_media.social_media"),
      :icon_class => icon_class("social_media"),
      :path => social_media_admin_community_path(@current_community),
      :name => "social_media"
    }

    links << {
      :topic => :configure,
      :text => t("admin.communities.seo_settings.seo"),
      :icon_class => icon_class("seo"),
      :path => admin_community_seo_settings_path,
      :name => "seo"
    }

    links << {
      :topic => :configure,
      :text => t("admin.communities.analytics.analytics"),
      :icon_class => icon_class("analytics"),
      :path => analytics_admin_community_path(@current_community),
      :name => "analytics"
    }

    links << {
      :topic => :configure,
      :text => t("admin.communities.edit_text_instructions.edit_text_instructions"),
      :icon_class => icon_class("edit"),
      :path => edit_text_instructions_admin_community_path(@current_community),
      :name => "text_instructions"
    }
    links << {
      :topic => :configure,
      :text => t("admin.left_hand_navigation.emails_title"),
      :icon_class => icon_class("mail"),
      :path => edit_welcome_email_admin_community_path(@current_community),
      :name => "welcome_email"
    }
    links << {
      :topic => :configure,
      :text => t("admin.communities.settings.settings"),
      :icon_class => icon_class("settings"),
      :path => admin_setting_path,
      :name => "admin_settings"
    }

    links
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  # Settings view left hand navigation content
  def settings_links_for(person, community=nil, restrict_for_admin=false)
    links = [
      {
        :id => "settings-tab-profile",
        :text => t("layouts.settings.profile"),
        :icon_class => icon_class("profile"),
        :path => person_settings_path(person),
        :name => "profile"
      }
    ]
    unless restrict_for_admin
      links +=
        [
          {
            :id => "settings-tab-listings",
            :text => t("layouts.settings.listings"),
            :icon_class => icon_class("thumbnails"),
            :path => listings_person_settings_path(person, sort: "updated"),
            :name => "listings"
          },
          {
            :id => "settings-tab-transactions",
            :text => t("layouts.settings.transactions"),
            :icon_class => icon_class("coins"),
            :path => transactions_person_settings_path(person, sort: "last_activity", direction: "desc"),
            :name => "transactions"
          },
          {
            :id => "settings-tab-account",
            :text => t("layouts.settings.account"),
            :icon_class => icon_class("account_settings"),
            :path => account_person_settings_path(person) ,
            :name => "account"
          },
          {
            :id => "settings-tab-notifications",
            :text => t("layouts.settings.notifications"),
            :icon_class => icon_class("notification_settings"),
            :path => notifications_person_settings_path(person),
            :name => "notifications"
          }
        ]
    end

    paypal_ready = PaypalHelper.community_ready_for_payments?(@current_community.id)
    stripe_ready = StripeHelper.community_ready_for_payments?(@current_community.id)

    if !restrict_for_admin && (paypal_ready || stripe_ready)
      links << {
        :id => "settings-tab-payments",
        :text => t("layouts.settings.payments"),
        :icon_class => icon_class("payments"),
        :path => person_payment_settings_path(@current_user),
        :name => "payments"
      }
    end

    return links
  end

  # returns either "http://" or "https://" based on configuration settings
  def default_protocol
    APP_CONFIG.always_use_ssl ? "https://" : "http://"
  end

  # Return the right notification "badge" size depending
  # on the number of new notifications
  def get_badge_class(count)
    case count
    when 1..9
      ""
    when 10..99
      "big-badge"
    else
      "huge-badge"
    end
  end

  def self.use_s3?
    APP_CONFIG.s3_bucket_name && ApplicationHelper.has_aws_keys?
  end

  def self.use_upload_s3?
    APP_CONFIG.s3_upload_bucket_name && ApplicationHelper.has_aws_keys?
  end

  def self.has_aws_keys?
    APP_CONFIG.aws_access_key_id && APP_CONFIG.aws_secret_access_key
  end

  def community_slogan
    if @community_customization  && !@community_customization.slogan.blank?
      @community_customization.slogan
    else
      if @current_community.slogan && !@current_community.slogan.blank?
        @current_community.slogan
      else
        t("common.default_community_slogan")
      end
    end
  end

  def community_description(truncate=true)
    if @community_customization && !@community_customization.description.blank?
      truncate ? truncate_html(@community_customization.description, length: 140, omission: "...") : @community_customization.description
    elsif @current_community.description && !@current_community.description.blank?
      truncate ? truncate_html(@current_community.description, length: 140, omission: "...") : @current_community.description
    else
      truncate ? truncate_html(t("common.default_community_description"), length: 125, omission: "...") : t("common.default_community_description")
    end
  end

  def email_link_style
    "color:#d96e21; text-decoration: none;"
  end

  def community_blank_slate
    @community_customization && !@community_customization.blank_slate.blank? ? @community_customization.blank_slate : t("homepage.index.no_listings_notification", :add_listing_link => link_to(t("homepage.index.add_listing_link_text"), new_listing_path)).html_safe
  end

  # Return a link to the listing author
  def author_link(listing)
    link_to(PersonViewUtils.person_display_name(listing.author, @current_community),
            listing.author,
            {:title => PersonViewUtils.person_display_name(listing.author, @current_community)})
  end

  def with_invite_link(&block)
    if @current_user && (@current_user.has_admin_rights?(@current_community) || @current_community.users_can_invite_new_users)
      block.call()
    end
  end

  def sort_link_direction(column)
    params[:sort].eql?(column) && params[:direction].eql?("asc") ? "desc" : "asc"
  end

  def search_path(opts = {})
    current_marketplace = request.env[:current_marketplace]
    PathHelpers.search_path(
      community_id: current_marketplace.id,
      logged_in: @current_user.present?,
      locale_param: params[:locale],
      default_locale: current_marketplace.default_locale,
      opts: opts)
  end

  def search_url(opts = {})
    PathHelpers.search_url(
      community_id: @current_community.id,
      opts: opts)
  end

  def search_mode
    FeatureFlagHelper.location_search_available ? @current_community.configuration&.main_search&.to_sym : :keyword
  end

  def landing_page_path
    PathHelpers.landing_page_path(
      community_id: @current_community.id,
      logged_in: @current_user.present?,
      default_locale: @current_community.default_locale,
      locale_param: params[:locale])
  end

  # Give an array of translation keys you need in JavaScript. The keys will be loaded and ready to be used in JS
  # with `ST.t` function
  def js_t(keys, run_js_immediately=false)
    js = javascript_tag("ST.loadTranslations(#{JSTranslations.load(keys).to_json})")
    if run_js_immediately
      js
    else
      content_for :extra_javascript do js end
    end
  end

  def format_local_date(value)
    format = t("datepicker.format").gsub(/([md])[md]+/, '%\1').gsub(/yyyy/, '%Y')
    value.present? ? value.strftime(format) : nil
  end

  def regex_definition_to_js(string)
    string.gsub('\A', '^').gsub('\z', '$').gsub('\\', '\\\\')
  end

  SOCIAL_LINKS = {
    facebook: {
      name: "Facebook",
      placeholder: "https://www.facebook.com/CHANGEME"
    },
    twitter: {
      name: "Twitter",
      placeholder: "https://www.twitter.com/CHANGEME"
    },
    instagram: {
      name: "Instagram",
      placeholder: "https://www.instagram.com/CHANGEME"
    },
    youtube: {
      name: "YouTube",
      placeholder: "https://www.youtube.com/channel/CHANGEME"
    },
    googleplus: {
      name: "Google",
      placeholder: "https://www.google.com/CHANGEME"
    },
    linkedin: {
      name: "LinkedIn",
      placeholder: "https://www.linkedin.com/company/CHANGEME"
    },
    pinterest: {
      name: "Pinterest",
      placeholder: "https://www.pinterest.com/CHANGEME"
    },
    soundcloud: {
      name: "SoundCloud",
      placeholder: "https://soundcloud.com/CHANGEME"
    }
  }.freeze

  def social_link_name(provider)
    SOCIAL_LINKS[provider.to_sym][:name]
  end

  def social_link_placeholder(provider)
    SOCIAL_LINKS[provider.to_sym][:placeholder]
  end
end
# rubocop:enable Metrics/ModuleLength

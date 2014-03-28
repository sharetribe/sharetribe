# encoding: utf-8
module ApplicationHelper

  ICON_PACK = APP_CONFIG.icon_pack || "font-awesome"

  ICONS = {
    "ss-pika" => {

      # Default UI icons
      "map" => "ss-maplocation",
      "thumbnails" => "ss-thumbnails",
      "grid" => "ss-thumbnails",
      "new_listing" => "ss-addfile",
      "search"  => "ss-search",
      "list" => "ss-list",
      "home" => "ss-home",
      "community" =>"ss-usergroup",
      "help" => "ss-help",
      "admin" => "ss-wrench",
      "directup" => "ss-directup",
      "directdown" => "ss-dropdown",
      "dropdown" => "ss-dropdown",
      "mail" => "ss-mail",
      "notifications" => "ss-earth",
      "login" => "ss-login",
      "logout" => "ss-logout",
      "feedback" => "ss-megaphone",
      "user" => "ss-user",
      "settings" => "ss-settings",
      "facebook" => "ss-facebook ss-icon ss-social",
      "information" => "ss-info",
      "alert" => "ss-alert",
      "how_to_use" => "ss-signpost",
      "privacy" => "ss-lockfile",
      "terms" => "ss-textfile",
      "testimonial" => "ss-star",
      "like" => "ss-like",
      "dislike" => "ss-dislike",
      "calendar" => "ss-calendar",
      "phone" => "ss-phone",
      "clock" => "ss-alarmclock",
      "eye" => "ss-view",
      "cross" => "ss-delete",
      "chat_bubble" => "ss-chat",
      "tag" => "ss-tag",
      "pricetag" => "ss-pricetag",
      "lock" => "ss-lock",
      "unlock" => "ss-unlock",
      "edit" => "ss-draw",
      "profile" => "ss-userfile",
      "payments" => "ss-moneybag",
      "notification_settings" => "ss-callbell",
      "account_settings" => "ss-lockfile",
      "rows" => "ss-rows",
      "check" => "ss-check",
      "invite" => "ss-adduser",
      "loading" => "ss-loading",
      "connect" => "ss-connection",
      "" => "",

      # Default category & share type icons
      "offer" => "ss-share",
      "request" => "ss-tip",
      "item" => "ss-box",
      "favor" => "ss-heart",
      "rideshare" => "ss-car",
      "housing" => "ss-warehouse",
      "other" => "ss-file",
      "tools" => "ss-wrench",
      "sports" => "ss-tabletennis",
      "music" => "ss-music",
      "books" => "ss-book",
      "games" => "ss-fourdie",
      "furniture" => "ss-lodging",
      "outdoors" => "ss-campfire",
      "food" => "ss-sidedish",
      "electronics" => "ss-smartphone",
      "pets" => "ss-tropicalfish",
      "film" => "ss-moviefolder",
      "clothes" => "ss-hanger",
      "garden" => "ss-tree",
      "travel" => "ss-departure",
      "give_away" => "ss-gift",
      "share_for_free" => "ss-gift",
      "accept_for_free" => "ss-gift",
      "lend" => "ss-flowertag",
      "borrow" => "ss-flowertag",
      "offer_to_swap" => "ss-reload",
      "request_to_swap" => "ss-reload",
      "buy" => "ss-moneybag",
      "sell" => "ss-moneybag",
      "rent" => "ss-pricetag",
      "rent_out" => "ss-pricetag",

      # Custom category & share type icons
      "job" => "ss-briefcase",
      "announcement" => "ss-newspaper",
      "news" => "ss-newspaper",
      "wood_based_materials" => "ss-tree",
      "plastic_and_rubber" => "ss-disc",
      "metal" => "ss-handbag",
      "concrete_and_brick" => "ss-form",
      "glass_and_porcelain" => "ss-fragile",
      "textile_and_leather" => "ss-hanger",
      "soil_materials" => "ss-cloud",
      "liquid_materials" => "ss-droplet",
      "manufacturing_error_materials" => "ss-wrench",
      "misc_material" => "ss-box",
      "clothing" => "ss-hanger",
      "accessories" => "ss-handbag",
      "designers" => "ss-star",
      "mealsharing" => "ss-sidedish",
      "activities" => "ss-usergroup",
      "accommodation" => "ss-lodging",
      "search_material" => "ss-search",
      "sell_material" => "ss-moneybag",
      "give_away_material" => "ss-gift",
      "beekeeping_and_honey" => "ss-waterbottle",
      "eggs" => "ss-colander",
      "produce" => "ss-carrot",
      "other_food_item" => "ss-platter",
      "food_related_supply" => "ss-cookingutensils",
      "livestock" => "ss-bird",
      "seeds_and_starts" => "ss-leaf",
      "food_related_classes" => "ss-bookmark",
      "bike" => "ss-bike",
      "peat" => "ss-cloud",
      "clay" => "ss-cloud",
      "silt" => "ss-cloud",
      "fine_moraine" => "ss-cloud",
      "coarse_moraine" => "ss-cloud",
      "sand" => "ss-cloud",
      "gravel" => "ss-cloud",
      "rock" => "ss-cloud",
      "friend_for_languages_or_games" => "ss-users",
      "location" => "ss-location",
      "offer_job" => "ss-briefcase",
      "internship" => "ss-users",
      "volunteering" => "ss-heart",
      "parking" => "ss-garage",
      "meeting_spot" => "ss-usergroup",
      "work_spot" => "ss-briefcase",
      "cars" => "ss-car",
      "raclette_grill" => "ss-cookingutensils",
    },
    "font-awesome" => {
      "map" => "icon-map-marker",
      "thumbnails" => "icon-th",
      "new_listing" => "icon-plus-sign-alt",

      "search"  => "icon-search",
      "list" => "icon-reorder",

      "home" => "icon-home",
      "community" =>"icon-group",
      "help" => "icon-question-sign",
      "admin" => "icon-wrench",

      "directup" => "icon-sort-up",
      "directdown" => "icon-sort-down",
      "dropdown" => "icon-caret-down",
      "mail" => "icon-envelope",
      "notifications" => "icon-globe",
      "login" => "icon-signin",
      "logout" => "icon-signout",
      "feedback" => "icon-bullhorn",
      "user" => "icon-user",
      "settings" => " icon-cog",
      "facebook" => "icon-facebook",
      "invite" => "icon-users",

      "information" => "icon-info-sign",
      "alert" => "icon-warning-sign",
      "how_to_use" => "icon-book",
      "privacy" => "icon-lock",
      "terms" => "icon-file-alt",

      "offer" => "icon-share",
      "request" => "icon-lightbulb",
      "item" => "icon-briefcase",
      "favor" => "icon-heart",
      "rideshare" => "icon-truck",
      "housing" => "icon-building",
      "other" => "icon-file",
      "tools" => "icon-wrench",
      "sports" => "icon-trophy",
      "music" => "icon-music",
      "books" => "icon-book",
      "games" => "icon-magic",
      "furniture" => "icon-picture",
      "outdoors" => "icon-fire",
      "food" => "icon-food",
      "electronics" => "icon-mobile-phone",
      "pets" => "icon-github-alt",
      "film" => "icon-film",
      "clothes" => "icon-headphones",
      "garden" => "icon-leaf",
      "travel" => "icon-plane",
      "give_away" => "icon-gift",
      "share_for_free" => "icon-gift",
      "accept_for_free" => "icon-gift",
      "lend" => "icon-gift",
      "borrow" => "icon-gift",
      "offer_to_swap" => "icon-exchange",
      "request_to_swap" => "icon-exchange",
      "buy" => "icon-money",
      "sell" => "icon-money",
      "rent" => "icon-money",
      "rent_out" => "icon-money",
      "job" => "icon-briefcase",

      "testimonial" => "icon-star",
      "like" => "icon-thumbs-up",
      "dislike" => "icon-thumbs-down",
      "calendar" => "icon-calendar",
      "phone" => "icon-phone",
      "clock" => "icon-time",
      "eye" => "icon-eye-open",
      "cross" => "icon-remove",
      "chat_bubble" => "icon-comment",
      "tag" => "icon-tag",
      "lock" => "icon-lock",
      "unlock" => "icon-unlock",
      "edit" => "icon-edit",
      "profile" => "ss-user"
    }
  }

  def icon_tag(icon_name, additional_classes=[])
    classes_string = [icon_class(icon_name)].concat(additional_classes).join(" ")
    return "<i class=\"#{classes_string}\"></i>".html_safe
  end

  def icon_class(icon_name)
    icon = ICONS[ICON_PACK][icon_name]
    if icon.nil?
      icon = (ICON_PACK == "font-awesome" ? "icon-circle-blank" : "ss-record")
    end
    return icon
  end

  def self.icon_specified?(icon_name)
    ICONS[ICON_PACK][icon_name].present?
  end

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
    case distance_in_minutes
      when 0..1           then time = (distance_in_seconds < 60) ? t('timestamps.seconds_ago', :count => distance_in_seconds) : t('timestamps.minute_ago', :count => 1)
      when 2..59          then time = t('timestamps.minutes_ago', :count => distance_in_minutes)
      when 60..90         then time = t('timestamps.hour_ago', :count => 1)
      when 90..1440       then time = t('timestamps.hours_ago', :count => (distance_in_minutes.to_f / 60.0).round)
      when 1440..2160     then time = t('timestamps.day_ago', :count => 1) # 1-1.5 days
      when 2160..2880     then time = t('timestamps.days_ago', :count => (distance_in_minutes.to_f / 1440.0).round) # 1.5-2 days
      #else time = from_time.strftime(t('date.formats.default'))
    end
    if distance_in_minutes > 2880
      distance_in_days = (distance_in_minutes/1440.0).round
      case distance_in_days
        when 0..30    then time = t('timestamps.days_ago', :count => distance_in_days)
        when 31..50   then time = t('timestamps.month_ago', :count => 1)
        when 51..364  then time = t('timestamps.months_ago', :count => (distance_in_days.to_f / 30.0).round)
        else               time = t('timestamps.years_ago', :count => (distance_in_days.to_f / 365.24).round)
      end
    end

    return time
  end

  def time_difference_in_days(from_time, to_time = Time.now)
    return nil if from_time.nil?
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = ((((to_time - from_time).abs)/60)/1440.0).round
  end

  # used to escape strings to URL friendly format
  def self.escape_for_url(str)
     URI.escape(str, Regexp.new("[^-_!~*()a-zA-Z\\d]"))
  end

  def self.shorten_url(url)
    if APP_CONFIG.bitly_username && APP_CONFIG.bitly_key
      begin
        bit_ly_query = "http://api.bit.ly/shorten/?version=2.0.1&login=#{APP_CONFIG.bitly_username}&longUrl=#{escape_for_url(url)}&apiKey=#{APP_CONFIG.bitly_key}"
        return JSON.parse(RestClient.get(bit_ly_query))["results"][url]["shortUrl"]
      rescue => e
        return url
      end
    else
      return url
    end
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

  def small_avatar_thumb(person, avatar_html_options={})
    avatar_thumb(:thumb, person, avatar_html_options)
  end

  def medium_avatar_thumb(person, avatar_html_options={})
    avatar_thumb(:small, person, avatar_html_options)
  end

  def avatar_thumb(size, person, avatar_html_options={})
    return "" if person.nil?
    link_to((image_tag person.image.url(size), avatar_html_options), person)
  end

  def large_avatar_thumb(person)
    image_tag person.image.url(:medium), :alt => person.name(@current_community)
  end

  def huge_avatar_thumb(person)
    # FIXME! Need a new picture size: :large
    image_tag person.image.url(:medium), :alt => person.name(@current_community)
  end

  def pageless(total_pages, target_id, url=nil, loader_message='Loading more results')

    opts = {
      :totalPages => total_pages,
      :url        => url,
      :loaderMsg  => loader_message,
      :div1       => target_id
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
    if @current_community
      # use the ordered list from community settings, but replace the short locales with ["English", "en"] like arrays from APP_CONFIG
      return @current_community.locales.collect{|loc| Kassi::Application.config.AVAILABLE_LOCALES.select{|app_loc| app_loc[1] == loc }[0]}
    else
      return Kassi::Application.config.AVAILABLE_LOCALES
    end
  end

  def get_full_locale_name(locale)
    Kassi::Application.config.AVAILABLE_LOCALES.each do |l|
      if l[1].to_s == locale.to_s
        return l[0]
      end
    end
    return locale # return the short string if no match found for longer name
  end

  def self.send_error_notification(message, error_class="Special Error", parameters={})
    if APP_CONFIG.use_airbrake
      Airbrake.notify(
        :error_class      => error_class,
        :error_message    => message,
        :backtrace        => $@,
        :environment_name => ENV['RAILS_ENV'],
        :parameters       => parameters)
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

  # If we are not in a single community defined by a subdomain,
  # we are on dashboard
  def on_dashboard?
    ["", "www","dashboardtranslate"].include?(request.subdomain) && APP_CONFIG.domain.include?(request.domain)
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

  def service_name(form=nil)
    if @current_community
      service_name = @current_community.service_name
    else
      service_name = APP_CONFIG.global_service_name || "Sharetribe"
    end
    if form #check if special form of the name is required
      service_name = ApplicationHelper.service_name_other_forms(service_name)[form.to_sym]
    end
    return service_name
  end

  def service_name_illative
    ApplicationHelper.service_name_other_forms
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

  # Class methods to access the service_name stored in the thread to work with I18N and DelayedJob etc async stuff.
  # If called without host information, set's the server default
  def self.store_community_service_name_to_thread_from_host(host=nil)
    community = nil
    if host.present?
      community_domain = host.split(".")[0] #pick the subdomain part to search primarily with that
      community = Community.find_by_domain(community_domain) || Community.find_by_domain(host)
    end
    store_community_service_name_to_thread_from_community(community)
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
    if community && community.settings && community.settings["service_name"].present?
      ser_name = community.settings["service_name"]
    end

    store_community_service_name_to_thread(ser_name)
  end

  def self.fetch_community_service_name_from_thread
    Thread.current[:current_community_service_name] || APP_CONFIG.global_service_name || "Sharetribe"
  end

  def self.service_name_other_forms(name)
    forms_hash = case name
      when "Sharetribe" then {
        :illative => "Sharetribeen",
        :genetive => "Sharetriben",
        :inessive => "Sharetribessa",
        :elative => "Sharetribesta",
        :partitive => "Sharetribea"
        }
      when "Kassi" then {
        :illative => "Kassiin",
        :genetive => "Kassin",
        :inessive => "Kassissa",
        :elative => "Kassista",
        :partitive => "Kassia"
        }
      when "Omakotitori" then {
        :illative => "Omakotitorille",
        :genetive => "Omakotitorin",
        :inessive => "Omakotitorilla",
        :elative => "Omakotitorilta",
        :partitive => "Omakotitoria"
        }
      when "Pakilan tori" then {
        :illative => "Pakilan torille",
        :genetive => "Pakilan torin",
        :inessive => "Pakilan torilla",
        :elative => "Pakilan torilta",
        :partitive => "Pakilan toria"
        }
      when "Materiaalipankki" then {
         :illative => "Materiaalipankkiin",
         :genetive => "Materiaalipankin",
         :inessive => "Materiaalipankissa",
         :elative => "Materiaalipankista",
         :partitive => "Materiaalipankkia"
         }
      when "Larun tori" then {
        :illative => "Larun torille",
        :genetive => "Larun torin",
        :inessive => "Larun torilla",
        :elative => "Larun torilta",
        :partitive => "Larun toria"
        }
      when "Massainfo" then {
        :illative => "Massainfoon",
        :genetive => "Massainfon",
        :inessive => "Massainfossa",
        :elative => "Massainfosta",
        :partitive => "Massainfoa"
      }
      when "University of Helsinki Marketplace" then {
        :illative => "University of Helsinki Marketplaceen",
        :genetive => "University of Helsinki Marketplacen",
        :inessive => "University of Helsinki Marketplacessa",
        :elative => "University of Helsinki Marketplacesta",
        :partitive => "University of Helsinki Marketplacea"
      }
      when "Autopaikkapörssi" then {
        :illative => "Autopaikkapörssiin",
        :genetive => "Autopaikkapörssin",
        :inessive => "Autopaikkapörssissä",
        :elative => "Autopaikkapörssistä",
        :partitive => "Autopaikkapörssiä"
      }
      when "Työpooli" then {
        :illative => "Työpooliin",
        :genetive => "Työpoolin",
        :inessive => "Työpoolissa",
        :elative => "Työpoolista",
        :partitive => "Työpoolia"
      }
    when "Lovebirds" then {
        :illative =>  "Lovebirdsiin",
        :genetive =>  "Lovebirdsin",
        :inessive =>  "Lovebirdsissa",
        :elative  =>  "Lovebirdsista",
        :partitive => "Lovebirdsia"
      }

      else nil
    end
  end

  # returns the locale part from url.
  # e.g. from "kassi.eu/es/listings" returns es
  def exctract_locale_from_url(url)
    url[/^([^\/]*\/\/)?[^\/]+\/(\w{2})(\/.*)?/,2]
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

  def community_email_restricted?
    ["university", "company"].include? session[:community_category]
  end

  def add_p_tags(text)
    text.gsub(/\n/, "</p><p>")
  end

  # general method for making urls as links and line breaks as <br /> tags
  def add_links_and_br_tags(text)
    pattern = /[\.)]*$/
    text = text.gsub(/https?:\/\/\S+/) { |link_url| link_to(truncate(link_url.gsub(pattern,""), :length => 50, :omission => "..."), link_url.gsub(pattern,"")) + link_url.match(pattern)[0]}.gsub(/\n/, "</p><p>")
    "<p>#{text}</p>"
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
    if @community_customization && !@community_customization.how_to_use_page_content.blank?
      links << {
        :text => t('layouts.infos.how_to_use'),
        :icon_class => icon_class("how_to_use"),
        :path => how_to_use_infos_path,
        :name => "how_to_use"
      }
    end
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

  # Admin view left hand navigation content
  def admin_links_for(community)
    links = [
      {
        :text => t("admin.communities.edit_details.community_details"),
        :icon_class => "ss-page",
        :path => edit_details_admin_community_path(community),
        :name => "tribe_details"
      },
      {
        :text => t("admin.communities.edit_details.community_look_and_feel"),
        :icon_class => "ss-paintroller",
        :path => edit_look_and_feel_admin_community_path(community),
        :name => "tribe_look_and_feel"
      },
      {
        :text => t("admin.emails.new.send_email_to_members"),
        :icon_class => icon_class("mail"),
        :path => new_admin_community_email_path(:community_id => @current_community.id),
        :name => "email_members"
      },
      {
        :text => t("admin.communities.edit_details.invite_people"),
        :icon_class => "ss-adduser",
        :path => new_invitation_path,
        :name => "invite_people"
      },
      {
        :text => t("admin.communities.edit_welcome_email.welcome_email_content"),
        :icon_class => icon_class("edit"),
        :path => edit_welcome_email_admin_community_path(community),
        :name => "welcome_email"
      },
      {
        :text => t("admin.communities.manage_members.manage_members"),
        :icon_class => icon_class("community"),
        :path => manage_members_admin_community_path(community),
        :name => "manage_members"
      },
      {
        :text => t("admin.communities.settings.settings"),
        :icon_class => icon_class("settings"),
        :path => settings_admin_community_path(community),
        :name => "admin_settings"
      },
      {
        :text => t("admin.communities.integrations.integrations"),
        :icon_class => icon_class("connect"),
        :path => integrations_admin_community_path(community),
        :name => "integrations"
      }
    ]

    # Only super admins
    if category_editing_allowed?
      links << {
        :text => t("admin.categories.index.listing_categories"),
        :icon_class => icon_class("list"),
        :path => admin_categories_path,
        :name => "listing_categories"
      }
    end

    if community.custom_fields_allowed
      links << {
        :text => t("admin.custom_fields.index.listing_fields"),
        :icon_class => icon_class("list"),
        :path => admin_custom_fields_path,
        :name => "listing_fields"
      }
    end

    links
  end

  # Inbox view left hand navigation content
  def inbox_links_for(person)
    [
      {
        :text => t("layouts.conversations.messages"),
        :icon_class => icon_class("mail"),
        :path => received_person_messages_path(:person_id => person.id.to_s),
        :name => "messages"
      },
      {
        :text => t("layouts.conversations.notifications"),
        :icon_class => icon_class("notifications"),
        :path => notifications_person_messages_path(:person_id => person.id.to_s),
        :name => "notifications"
      }
    ]
  end

  # Settings view left hand navigation content
  def settings_links_for(person, community=nil)
    links = [
      {
        :id => "settings-tab-profile",
        :text => t("layouts.settings.profile"),
        :icon_class => icon_class("profile"),
        :path => profile_person_settings_path(:person_id => person.id.to_s),
        :name => "profile"
      },
      {
        :id => "settings-tab-account",
        :text => t("layouts.settings.account"),
        :icon_class => icon_class("account_settings"),
        :path => account_person_settings_path(:person_id => person.id.to_s) ,
        :name => "account"
      },
      {
        :id => "settings-tab-notifications",
        :text => t("layouts.settings.notifications"),
        :icon_class => icon_class("notification_settings"),
        :path => notifications_person_settings_path(:person_id => person.id.to_s),
        :name => "notifications"
      }
    ]
    if community && community.payments_in_use?
      links << {
        :id => "settings-tab-payments",
        :text => t("layouts.settings.payments"),
        :icon_class => icon_class("payments"),
        :path => @current_community.payment_gateway.settings_path(person, params[:locale]),
        :name => "payments"
      }

    end

    return links
  end

  def dashboard_link(args)
    locale_part = ""
    selected_locale = args[:locale].to_s
    if selected_locale.present? && selected_locale != "en"
      Kassi::Application.config.AVAILABLE_DASHBOARD_LOCALES.each do |name, loc|
        locale_part = "/#{selected_locale}" and break if loc == selected_locale
      end
    end
    return "#{default_protocol}www.#{APP_CONFIG.domain}#{locale_part}#{args[:ref] ? "?ref=#{args[:ref]}" : ""}"
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

  def facebook_connect_in_use?
    APP_CONFIG.fb_connect_id && ! @facebook_merge && @current_community && @current_community.facebook_connect_enabled?
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
      truncate ? truncate(@community_customization.description, :length => 140, :omission => "...").html_safe : @community_customization.description.html_safe
    else
      if @current_community.description && !@current_community.description.blank?
        truncate ? truncate(@current_community.description, :length => 140, :omission => "...") : @current_community.description
      else
        truncate ? truncate(t("common.default_community_description"), :length => 125, :omission => "...").html_safe : t("common.default_community_description").html_safe
      end
    end
  end

  def email_link_style
    "color:#d96e21; text-decoration: none;"
  end

  def community_blank_slate
    @community_customization && !@community_customization.blank_slate.blank? ? @community_customization.blank_slate : t(".no_listings_notification", :add_listing_link => link_to(t(".add_listing_link_text"), new_listing_path)).html_safe
  end

  def fb_image
    if @listing && action_name.eql?("show") && !@listing.listing_images.empty?
      @listing.listing_images.first.image.url(:medium)
    elsif @current_community.logo?
      @current_community.logo.url(:original)
    else
      "https://s3.amazonaws.com/sharetribe/assets/sharetribe_icon.png"
    end
  end

  # Return a link to the listing author
  def author_link(listing)
    link_to(listing.author.name(@current_community), listing.author, {:title => listing.author.name(@current_community)})
  end

  def with_available_locales(&block)
    if available_locales.size > 1
      block.call(available_locales)
    end
  end

  def with_invite_link(&block)
    if @current_user.has_admin_rights_in?(@current_community) || @current_community.users_can_invite_new_users
      block.call()
    end
  end

  def with_stylesheet_url(community, &block)
    stylesheet_url = if community.has_customizations?
      community.custom_stylesheet_url
    else
      'application'
    end

    block.call(stylesheet_url)
  end

  # Render block only if big cover photo should be shown
  def with_big_cover_photo(&block)
    block.call if show_big_cover_photo?
  end

  # Render block only if small cover photo should be shown
  def with_small_cover_photo(&block)
    block.call unless show_big_cover_photo?
  end

  def show_big_cover_photo?
    @homepage && (!@current_user || params[:big_cover_photo])
  end

  def sum_with_currency(sum, currency)
    humanized_money_with_symbol(Money.new(sum*100, (currency || "EUR")))
  end

  def category_editing_allowed?
    if @current_user
      if @current_user.is_admin?
        logger.info ""
        return true
      elsif @current_community.category_change_allowed? && @current_user.has_admin_rights_in?(@current_community)
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def sort_link(column)
    title = t(".#{column}")
    css_class = params[:sort].eql?(column) ? "sort-arrow-#{member_sort_direction}" : nil
    direction = (params[:sort].eql?(column) && member_sort_direction.eql?("asc")) ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction, :page => (params[:page] || 1)}, {:class => css_class}
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
end

module ApplicationHelper
  
  # Removes whitespaces from HAML expressions
  # if you add two elements on two lines; the white space creates a space between the elements (in some browsers)
  def one_line_for_html_safe_content(&block)
    haml_concat capture_haml(&block).gsub("\n", '').html_safe
  end
  
  # Returns a human friendly format of the time stamp
  # Origin: http://snippets.dzone.com/posts/show/6229
  def time_ago(from_time, to_time = Time.now)
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
        when 31..364  then time = t('timestamps.months_ago', :count => (distance_in_days.to_f / 30.0).round)
        else               time = t('timestamps.years_ago', :count => (distance_in_days.to_f / 365.24).round)
      end
    end
    
    return time
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
      rescue Exception => e
        return url
      end
    else
      return url
    end
  end
  
  # Changes line breaks to <br>-tags and transforms URLs to links
  def text_with_line_breaks(&block)
    haml_concat add_links_and_br_tags(capture_haml(&block)).html_safe
  end
  
  # Changes line breaks to <br>-tags and transforms URLs to links
  def text_with_line_breaks_for_email(&block)
    haml_concat add_links_and_br_tags_for_email(capture_haml(&block)).html_safe
  end
  
  def small_avatar_thumb(person)
    link_to((image_tag person.image.url(:thumb), :width => 50, :height => 50), person)
  end
  
  def medium_avatar_thumb(person)
    link_to((image_tag person.image.url(:thumb), :width => 70, :height => 70), person)
  end
  
  def large_avatar_thumb(person)
    image_tag person.image.url(:medium), :width => 218, :alt => person.name(session[:cookie])
  end

  def pageless(total_pages, target_id, url=nil, loader_message='Loading more results', two_div_update=false)

    opts = {
      :totalPages => total_pages,
      :url        => url,
      :loaderMsg  => loader_message,
      :div1       => target_id
    }
    
    if two_div_update
      opts.merge!( {
        :div1         => "#recent_requests",
        :div2         => "#recent_offers",
        :split_string => "<!--SPLIT_req-off-->"
      })
    end
    
    javascript_tag("$('#{target_id}').pageless(#{opts.to_json});")
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
  
  def community_file(type, with_locale=false)
    locale_string = with_locale ? ".#{I18n.locale}" : ""
    file_path = "communities/#{@current_community.domain}/#{type}/#{type}#{locale_string}"
    if File.exists?("#{file_path}.haml")
      file_path
    elsif File.exists?("communities/default/#{type}/#{type}#{locale_string}.haml")
      # This should match usually since locale string is blank if no locale in use
      "communities/default/#{type}/#{type}#{locale_string}"
    else
      # However, we fallback to non-locale default if there is such
      "communities/default/#{type}/#{type}"
    end
  end
  
  def community_file?(type, with_locale=false)
    locale_string = with_locale ? ".#{I18n.locale}" : ""
    file_path = "communities/#{@current_community.domain}/#{type}/#{type}#{locale_string}.haml"
    File.exists?(file_path)
  end
  
  # If we are not in a single community defined by a subdomain,
  # we are on dashboard
  def on_dashboard?
    ["", "www","dashboardtranslate"].include?(request.subdomain)
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
    if @current_community && @current_community.settings && @current_community.settings["service_name"].present?
      service_name = @current_community.settings["service_name"]
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
      ser_name = APP_CONFIG.global_service_name || "Sharetribe"
      
      if host.present?
        community_domain = host.split(".")[0] #pick the subdomain part
        community = Community.find_by_domain(community_domain)
      
        # if community has it's own setting, dig it out here
        if community && community.settings && community.settings["service_name"].present?
          ser_name = community.settings["service_name"]
        end
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
  
  def get_url_for(community)
    "http://#{with_subdomain(community.domain)}/#{I18n.locale}"
  end
  
  # general method for making urls as links and line breaks as <br /> tags
  def add_links_and_br_tags(text)
    pattern = /[\.)]*$/
    text.gsub(/https?:\/\/\S+/) { |link_url| link_to(truncate(link_url.gsub(pattern,""), :length => 50, :omission => "..."), link_url.gsub(pattern,"")) + link_url.match(pattern)[0]}.gsub(/\n/, "<br />")
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
  
  
end

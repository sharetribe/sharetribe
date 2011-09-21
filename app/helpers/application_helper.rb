module ApplicationHelper
  
  # Removes whitespaces from HAML expressions
  def one_line(&block)
    haml_concat capture_haml(&block).gsub("\n", '')
  end
  
  # Returns a human friendly format of the time stamp
  # Origin: http://snippets.dzone.com/posts/show/6229
  def time_ago(from_time, to_time = Time.now)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round
    case distance_in_minutes
      when 0..1           then time = (distance_in_seconds < 60) ? "#{distance_in_seconds} #{t('timestamps.seconds_ago')}" : "1 #{t('timestamps.minute_ago')}"
      when 2..59          then time = "#{distance_in_minutes} #{t('timestamps.minutes_ago')}"
      when 60..90         then time = "1 #{t('timestamps.hour_ago')}"
      when 90..1440       then time = "#{(distance_in_minutes.to_f / 60.0).round} #{t('timestamps.hours_ago')}"
      when 1440..2160     then time = "1 #{t('timestamps.day_ago')}" # 1-1.5 days
      when 2160..2880     then time = "#{(distance_in_minutes.to_f / 1440.0).round} #{t('timestamps.days_ago')}" # 1.5-2 days
      #else time = from_time.strftime(t('date.formats.default'))
    end
    if distance_in_minutes > 2880
      distance_in_days = (distance_in_minutes/1440.0).round
      case distance_in_days
        when 0..30    then time = "#{distance_in_days} #{t('timestamps.days_ago')}"
        when 31..364  then time = "#{(distance_in_days.to_f / 30.0).round} #{t('timestamps.months_ago')}"
        else               time = "#{(distance_in_days.to_f / 365.24).round} #{t('timestamps.years_ago')}"
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
    pattern = /[\.)]*$/
    haml_concat capture_haml(&block).gsub(/https?:\/\/\S+/) { |link_url| link_to(truncate(link_url.gsub(pattern,""), :length => 50, :omission => "..."), link_url.gsub(pattern,"")) +  link_url.match(pattern)[0]}.gsub(/\n/, "<br />")
  end
  
  def small_avatar_thumb(person)    
    link_to (image_tag APP_CONFIG.asi_url + "/people/" + person.id + "/@avatar/small_thumbnail", :width => 50, :height => 50), person
  end
  
  def large_avatar_thumb(person)
    image_tag APP_CONFIG.asi_url + "/people/" + person.id + "/@avatar/large_thumbnail", :width => 218, :alt => person.name(session[:cookie])
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
      return @current_community.locales.collect{|loc| APP_CONFIG.available_locales.select{|app_loc| app_loc[1] == loc }[0]}
    else
      return APP_CONFIG.available_locales
    end
  end
  
  def self.send_error_notification(message, error_class="Special Error", parameters={})
    if APP_CONFIG.use_hoptoad
      HoptoadNotifier.notify(:error_class => error_class, :error_message => message, :parameters => parameters)
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
    file_path = "communities/#{@current_community.domain}/#{type}/#{type}#{locale_string}.haml"
    if File.exists?(file_path)
      file_path
    elsif File.exists?("communities/default/#{type}/#{type}#{locale_string}.haml")
      # This should match usually since locale string is blank if no locale in use
      "communities/default/#{type}/#{type}#{locale_string}.haml"
    else
      # However, we fallback to non-locale default if there is such
      "communities/default/#{type}/#{type}.haml"
    end
  end
  
  def facebook_like
    content_tag :iframe, nil, :src => "http://www.facebook.com/plugins/like.php?locale=#{I18n.locale}_#{I18n.locale.to_s.upcase}&href=#{CGI::escape(request.url)}&layout=button_count&show_faces=true&width=150&action=recommend&font=arial&colorscheme=light&height=20", :scrolling => 'no', :frameborder => '0', :allowtransparency => true, :id => :facebook_like, :width => 120, :height => 20
  end
  
  def self.random_sting(length=6)
    chars = ("a".."z").to_a + ("0".."9").to_a
    random_string = ""
    1.upto(length) { |i| random_string << chars[rand(chars.size-1)] }
    return random_string
  end
  
end

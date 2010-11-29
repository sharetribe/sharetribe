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
  
  def self.send_error_notification(message)
    if APP_CONFIG.use_hoptoad
      HoptoadNotifier.notify(:error_class => "Special Error", :error_message => message 
               )
    end
  end
  
end

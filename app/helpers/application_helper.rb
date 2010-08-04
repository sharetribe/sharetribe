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
        else               time = "{(distance_in_days.to_f / 365.24).round} #{t('timestamps.years_ago')}"
      end
    end
    
    return time
  end
  
  # Changes line breaks to <br>-tags and transforms URLs to links
  def text_with_line_breaks(&block)
    pattern = /[\.)]*$/
    haml_concat capture_haml(&block).gsub(/https?:\/\/\S+/) { |link_url| link_to(link_url.gsub(pattern,""), link_url.gsub(pattern,"")) +  link_url.match(pattern)[0]}.gsub(/\n/, "<br />")
  end
  
  def small_avatar_thumb(person)    
    link_to (image_tag APP_CONFIG.asi_url + "/people/" + person.id + "/@avatar/small_thumbnail", :width => 50, :height => 50), "#"
  end
  
  def pageless(total_pages, target_id, url=nil, loader_message='Loading more results')
    opts = {
      :totalPages => total_pages,
      :url        => url,
      :loaderMsg  => loader_message
    }
    
    javascript_tag("$('#{target_id}').pageless(#{opts.to_json});")
  end
  
end

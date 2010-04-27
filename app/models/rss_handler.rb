require 'rss'

class RssHandler
  
  KASSI_FEED_URL = "http://otasizzle.wordpress.com/?tag=kassi&feed=rss2"
  KASSI_NEWS_URL = "http://otasizzle.wordpress.com/tag/kassi"
  
  # Return the RSS fetched from the OtaSizzle blog
  # from articles tagged "kassi"
  def self.get_kassi_feed
    begin
       return Rails.cache.fetch("kassi_news_rss", :expires_in => 24.hours) {RSS::Parser.parse(open(KASSI_FEED_URL).read, false)} 
    rescue Timeout::Error => e
      return nil
    end
  end
  
  # Return the URL for OtaSizzle blog articles tagged "kassi"
  def self.get_kassi_news_url
    KASSI_NEWS_URL
  end
  
end
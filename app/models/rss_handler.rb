require 'rss'

class RssHandler
  
  KASSI_FEED_URL = "http://otasizzle.wordpress.com/?tag=kassi&feed=rss2"
  KASSI_NEWS_URL = "http://otasizzle.wordpress.com/tag/kassi"
  
  # 
  def self.get_kassi_feed
    RSS::Parser.parse(open(KASSI_FEED_URL).read, false)
  end
  
  # Return the URL for 
  def self.get_kassi_news_url
    KASSI_NEWS_URL
  end
  
end
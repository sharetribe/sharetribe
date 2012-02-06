class InfosController < ApplicationController
  
  skip_filter :check_email_confirmation
  
  def news
    @news_items = @current_community.news_items.order("created_at DESC")
    if @current_community.all_users_can_add_news?
      @news_item = NewsItem.new 
      @path = admin_news_items_path
    end
  end
  
  def about
  end
  
  def how_to_use
  end

  def terms
  end
  
  def register_details
  end

end

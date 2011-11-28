class InfosController < ApplicationController
  
  skip_filter :check_email_confirmation
  
  def news
    @news_items = @current_community.news_items.order("created_at DESC")
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

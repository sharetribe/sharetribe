class Admin::NewsItemsController < ApplicationController
  
  layout "layouts/admin"
  
  def index
    @news_items = @current_community.news_items
  end
  
  def new
    @news_item = NewsItem.new
  end
  
  def create
    @news_item = NewsItem.new(params[:news_item])
    if @news_item.save
      notice = "news_item_created"
    else
      notice = "creation_of_news_item_failed"
    end
  end
  
  def destroy
    @news_item.destroy
  end
  
end
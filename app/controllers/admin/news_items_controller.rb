class Admin::NewsItemsController < ApplicationController
  
  layout "layouts/admin"
  
  def index
    @news_items = @current_community.news_items.order("created_at DESC")
  end
  
  def new
    @news_item = NewsItem.new
    @path = admin_news_items_path
  end
  
  def create
    @news_item = NewsItem.new(params[:news_item])
    if @news_item.save
      flash[:notice] = "news_item_created"
      if params[:info_view]
        redirect_to news_infos_path
      else
        redirect_to admin_news_items_path(:type => "news")
      end
    else
      flash[:error] = "news_item_creation_failed"
      render :action => :new
    end
  end
  
  def edit
    @news_item = NewsItem.find(params[:id])
    @path = admin_news_item_path(:id => @news_item.id.to_s)
    render :action => :new
  end
  
  def update
    @news_item = NewsItem.find(params[:id])
    if @news_item.update_attributes(params[:news_item])
      flash[:notice] = "news_item_updated"
      redirect_to admin_news_items_path(:type => "news")    
    else
      flash[:error] = "news_item_update_failed"
      @path = admin_news_item_path(:id => @news_item.id.to_s)
      render :action => :new
    end
  end
  
  def destroy
    NewsItem.find(params[:id]).destroy
    flash[:notice] = "news_item_deleted"
    redirect_to admin_news_items_path(:type => "news")
  end
  
end
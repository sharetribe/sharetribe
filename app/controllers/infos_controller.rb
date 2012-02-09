class InfosController < ApplicationController
  
  skip_filter :check_email_confirmation
  
  def news
    redirect_to about_infos_path unless @current_community.news_enabled
    params[:page] = 1 unless request.xhr?
    @news_items = @current_community.news_items.order("created_at DESC").paginate(:per_page => 10, :page => params[:page])
    if @current_community.all_users_can_add_news?
      @news_item = NewsItem.new 
      @path = admin_news_items_path
    end
    request.xhr? ? (render :partial => "additional_news_items") : render
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

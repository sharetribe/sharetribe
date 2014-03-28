class NewsItemsController < ApplicationController

  layout "layouts/infos"

  before_filter :only => [ :create, :destroy ] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_add_news_item")
  end

  skip_filter :dashboard_only

  def index
    redirect_to about_infos_path and return
    # Comment out the line below as none of the communities currently has news enabled. So always redirect.
    # redirect_to about_infos_path and return unless @current_community.news_enabled
    if params[:news_form] && !logged_in?
      session[:return_to] = request.fullpath
      flash[:warning] = t("layouts.notifications.you_must_log_in_to_add_news_item")
      redirect_to login_path and return
    end
    params[:page] = 1 unless request.xhr?
    @news_items = @current_community.news_items.order("created_at DESC").paginate(:per_page => 10, :page => params[:page])
    if @current_community.all_users_can_add_news?
      @news_item = NewsItem.new
      @path = news_items_path
    end
    request.xhr? ? (render :partial => "additional_news_items") : render
  end

  def create
    redirect_to root and return unless @current_community.all_users_can_add_news?
    @news_item = NewsItem.new(params[:news_item])
    if @news_item.save
      flash[:notice] = t("layouts.notifications.news_item_created")
      redirect_to news_items_path
    else
      flash[:error] = t("layouts.notifications.news_item_creation_failed")
      redirect_to news_items_path(:news_form => true)
    end
  end

  def destroy
    news_item = NewsItem.find(params[:id])
    redirect_to news_items_path and return unless current_user?(news_item.author) || @current_user.has_admin_rights_in?(@current_community)
    news_item.destroy
    flash[:notice] = t("layouts.notifications.news_item_deleted")
    redirect_to news_items_path
  end

end

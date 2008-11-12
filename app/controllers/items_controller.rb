class ItemsController < ApplicationController
  
  before_filter :logged_in, :only => [ :create, :destroy ]
  
  def index
    fetch_items
  end
  
  def show
    @title = params[:id]
    @items = Item.find(:all, :conditions => "title = '" + params[:id].capitalize + "'")
    fetch_items
    render :action => :index
  end
  
  def search
    save_navi_state(['items', 'search_items'])
  end
  
  def create
    @item = Item.new(params[:item])
    if @item.save
      flash[:notice] = :item_added  
      respond_to do |format|
        format.html { redirect_to @current_user }
        format.js  
      end
    else 
      flash[:error] = :item_could_not_be_added 
      redirect_to @current_user
    end
  end  
  
  def destroy
    Item.find(params[:id]).destroy
    flash[:notice] = :item_removed
    redirect_to @current_user
  end
  
  private
  
  def fetch_items
    save_navi_state(['items','browse_items','',''])
    @item_titles = Item.find(:all, :select => "DISTINCT title", :order => 'title ASC').collect(&:title)
  end
  
end

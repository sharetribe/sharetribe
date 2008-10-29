class ItemsController < ApplicationController
  
  before_filter :logged_in, :only => [ :create, :destroy ]
  
  def index
    save_navi_state(['items','browse_items','',''])
    @title =  :all_items  
    @items_all = Item.find :all, :order => 'title ASC'
    
    @item_titles = Item.find(:all, :select => "title", :order => 'title ASC').collect(&:title).uniq
    
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
  
end

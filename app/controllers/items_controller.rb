class ItemsController < ApplicationController
  
  def index
    save_navi_state(['items','browse_items','',''])
    @title =  :all_items  
    @items_all = Item.find :all, :order => 'title ASC'
    
    @item_titles = Item.find(:all, :select => "title").collect(&:title).uniq
    
  end
  
  def search
    save_navi_state(['items', 'search_items'])
  end
  
end

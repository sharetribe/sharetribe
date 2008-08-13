class ItemsController < ApplicationController
  
  def index
    save_navi_state(['items','browse_items','',''])
  end
  
  def search
    save_navi_state(['items', 'search_items'])
  end
  
end

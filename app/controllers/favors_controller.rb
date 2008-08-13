class FavorsController < ApplicationController
  def index
    save_navi_state(['favors','browse_favors'])
  end
  
  def search
    save_navi_state(['favors', 'search_favors'])
    @title = :search_favors_title
  end
  
end

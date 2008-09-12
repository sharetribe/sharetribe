class FavorsController < ApplicationController
  def index
    save_navi_state(['favors','browse_favors'])
    @title = :all_favors
    @favors_all = Favor.find :all, :order => 'title ASC'
    @favor_titles = Favor.find(:all, :select => "title", :order => 'title ASC').collect(&:title)
  end
  
  def search
    save_navi_state(['favors', 'search_favors'])
    @title = :search_favors_title
  end
  
end

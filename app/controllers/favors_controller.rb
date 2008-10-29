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
  
  def create
    @favor = Favor.new(params[:favor])
    if @favor.save
      flash[:notice] = :favor_added  
      respond_to do |format|
        format.html { redirect_to @current_user }
        format.js  
      end
    else 
      flash[:error] = :favor_could_not_be_added 
      redirect_to @current_user
    end
  end
  
  def destroy
    Favor.find(params[:id]).destroy
    flash[:notice] = :favor_removed
    redirect_to @current_user
  end
  
end

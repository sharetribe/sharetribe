class FriendsController < ApplicationController
  
  before_filter :logged_in
  
  def index
    @person = Person.find(params[:person_id])
    session[:profile_navi] = 'friends'
    save_navi_state(['own', 'friends']) if current_user?(@person)
    ids = Array.new
    @person.get_friends(session[:cookie])["entry"].each do |person|
      ids << person["id"]
    end
    @friends = Person.find(ids).paginate :page => params[:page], :per_page => per_page
  end

  def create
    begin
      @current_user.add_as_friend(params[:person_id], session[:cookie])
      flash[:notice] = :friend_requested
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = :friend_request_failed
    end
    redirect_to :back
  end
  
  def destroy
    begin
      @current_user.remove_from_friends(params[:id], session[:cookie])
      flash[:notice] = :friend_removed
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = :removing_friend_failed
    end
    redirect_to :back
  end

end

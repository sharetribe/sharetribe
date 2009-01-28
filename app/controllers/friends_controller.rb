class FriendsController < ApplicationController
  
  before_filter :logged_in
  
  def index
    @person = Person.find(params[:person_id])
    session[:profile_navi] = 'friends'
    save_navi_state(['own', 'friends']) if current_user?(@person)
    @friends = @person.get_friends
  end

  def create
    @friend = Person.find(params[:person_id])
    begin
      @current_user.add_as_friend(@friend.id, session[:cookie])
      flash[:notice] = :friend_requested
    rescue ActiveResource::ResourceNotFound => e
      flash[:error] = e.response.body
    end
    redirect_to :back
  end
  
  def destroy
    
  end

end

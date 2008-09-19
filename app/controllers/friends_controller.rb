class FriendsController < ApplicationController
  def index
    save_navi_state(['own', 'friends']) if params[:person_id].eql?(@current_user.id)
    @title = :friends
  end

  def add
  end

end

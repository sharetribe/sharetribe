class FriendsController < ApplicationController
  def index
    save_navi_state(['own', 'friends'])
    @title = :friends
  end

  def add
  end

end

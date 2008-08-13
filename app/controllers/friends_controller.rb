class FriendsController < ApplicationController
  def index
    save_navi_state(['people', 'friends'])
    @title = :friends
  end

  def add
  end

end

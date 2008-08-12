class FavorsController < ApplicationController
  def index
    save_navi_state(['favors','browse_favors','',''])
  end
end

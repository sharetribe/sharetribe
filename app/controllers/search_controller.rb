class SearchController < ApplicationController

  skip_filter :dashboard_only

  def show
    redirect_to root
  end

end

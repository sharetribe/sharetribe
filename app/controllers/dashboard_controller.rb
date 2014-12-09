class DashboardController < ApplicationController

  include CommunitiesHelper

  layout "dashboard"

  skip_filter :fetch_community, :only => :api

  def index
  end

end

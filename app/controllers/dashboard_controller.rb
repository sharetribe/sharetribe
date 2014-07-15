class DashboardController < ApplicationController

  include CommunitiesHelper

  layout "dashboard"

  skip_filter :single_community_only
  skip_filter :dashboard_only, :only => :api
  skip_filter :fetch_community, :only => :api

  def index
    @contact_request = session[:contact_request_sent] ? ContactRequest.find(session[:contact_request_sent]) : ContactRequest.new
  end

end
